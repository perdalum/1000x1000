/* det_matrix.c  (ANSI C / C89)
 *
 * Reads a square CSV matrix, computes sign(det(A)) and log(|det(A)|)
 * using LAPACK DGETRF (LU with partial pivoting), and prints a
 * “pretty” determinant in scientific notation without overflow.
 *
 * macOS build examples:
 *   1) Using Accelerate (recommended on macOS):
 *      clang -std=c89 -O2 det_matrix.c -o det_matrix -framework Accelerate -lm
 *
 *   2) Using Homebrew lapack / openblas:
 *      clang -std=c89 -O2 det_matrix.c -o det_matrix -llapack -lblas -lm
 *
 * Usage:
 *   ./det_matrix matrix.csv
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

/* Fortran LAPACK symbol. Most macOS / Homebrew builds expose dgetrf_ */
extern void dgetrf_(int *m, int *n, double *a, int *lda, int *ipiv, int *info);

static void die(const char *msg) {
  fprintf(stderr, "%s\n", msg);
  exit(1);
}

static char *trim(char *s) {
  char *end;
  while (*s && isspace((unsigned char)*s)) s++;
  if (*s == 0) return s;
  end = s + strlen(s) - 1;
  while (end > s && isspace((unsigned char)*end)) end--;
  end[1] = '\0';
  return s;
}

static int parse_csv_line(const char *line, double **out_vals, int *out_n) {
  /* Simple CSV: comma-separated, no quotes. */
  int cap = 16, n = 0;
  double *vals = (double *)malloc((size_t)cap * sizeof(double));
  char *buf, *tok, *saveptr;
  char *endptr;

  if (!vals) return 0;

  buf = (char *)malloc(strlen(line) + 1);
  if (!buf) { free(vals); return 0; }
  strcpy(buf, line);

  tok = strtok_r(buf, ",", &saveptr);
  while (tok) {
    double x;
    char *t = trim(tok);

    if (n >= cap) {
      double *nv;
      cap *= 2;
      nv = (double *)realloc(vals, (size_t)cap * sizeof(double));
      if (!nv) { free(vals); free(buf); return 0; }
      vals = nv;
    }

    endptr = NULL;
    x = strtod(t, &endptr);
    if (endptr == t || (endptr && *trim(endptr) != '\0') || !isfinite(x)) {
      free(vals);
      free(buf);
      return 0;
    }

    vals[n++] = x;
    tok = strtok_r(NULL, ",", &saveptr);
  }

  free(buf);
  *out_vals = vals;
  *out_n = n;
  return 1;
}

static int read_matrix_csv(const char *path, double **A_out, int *n_out, int *lda_out) {
  FILE *fp = fopen(path, "r");
  char line[1 << 16];
  int nrows = 0, ncols = -1;
  int rows_cap = 64;
  double **rows = NULL;
  int *row_len = NULL;
  int i, j;
  double *A;

  if (!fp) return 0;

  rows = (double **)malloc((size_t)rows_cap * sizeof(double *));
  row_len = (int *)malloc((size_t)rows_cap * sizeof(int));
  if (!rows || !row_len) { fclose(fp); return 0; }

  while (fgets(line, (int)sizeof(line), fp)) {
    char *t = trim(line);
    double *vals = NULL;
    int k = 0;

    if (t[0] == '\0') continue; /* skip blank lines */

    if (!parse_csv_line(t, &vals, &k)) {
      fclose(fp);
      return 0;
    }

    if (ncols < 0) ncols = k;
    if (k != ncols) {
      fclose(fp);
      return 0;
    }

    if (nrows >= rows_cap) {
      int newcap = rows_cap * 2;
      double **nr = (double **)realloc(rows, (size_t)newcap * sizeof(double *));
      int *nl = (int *)realloc(row_len, (size_t)newcap * sizeof(int));
      if (!nr || !nl) { fclose(fp); return 0; }
      rows = nr; row_len = nl; rows_cap = newcap;
    }

    rows[nrows] = vals;
    row_len[nrows] = k;
    nrows++;
  }

  fclose(fp);

  if (nrows <= 0 || ncols <= 0) return 0;
  if (nrows != ncols) return 0;

  /* Pack column-major for LAPACK: A[j*lda + i] */
  A = (double *)malloc((size_t)nrows * (size_t)ncols * sizeof(double));
  if (!A) return 0;

  for (i = 0; i < nrows; i++) {
    for (j = 0; j < ncols; j++) {
      A[j * nrows + i] = rows[i][j];
    }
  }

  for (i = 0; i < nrows; i++) free(rows[i]);
  free(rows);
  free(row_len);

  *A_out = A;
  *n_out = nrows;
  *lda_out = nrows;
  return 1;
}

static void det_log_form(double *A, int n, int lda, double *logabs_out, int *sign_out) {
  int *ipiv = (int *)malloc((size_t)n * sizeof(int));
  int info = 0;
  int m = n, nn = n;
  int i;
  int permSign = 1;
  int sign = 1;
  double logabs = 0.0;

  if (!ipiv) die("Out of memory (ipiv)");

  dgetrf_(&m, &nn, A, &lda, ipiv, &info);

  if (info < 0) die("dgetrf: illegal argument");
  if (info > 0) {
    *logabs_out = -INFINITY;
    *sign_out = 0;
    free(ipiv);
    return;
  }

  /* Pivot sign: flip each time ipiv[i] != i+1 (LAPACK is 1-based) */
  for (i = 0; i < n; i++) {
    int j = ipiv[i]; /* 1..n */
    if (j != i + 1) permSign = -permSign;
  }

  sign = permSign;
  for (i = 0; i < n; i++) {
    double uii = A[i * lda + i]; /* diagonal of U in packed LU */
    if (uii == 0.0) {
      *logabs_out = -INFINITY;
      *sign_out = 0;
      free(ipiv);
      return;
    }
    sign *= (uii > 0.0) ? 1 : -1;
    logabs += log(fabs(uii));
  }

  *logabs_out = logabs;
  *sign_out = (sign == 0) ? 0 : sign;
  free(ipiv);
}

static void print_pretty_det(double logabs, int sign) {
  /* Print sign * exp(logabs) as scientific without overflow:
     let log10(|det|) = logabs / ln(10) = e + f, where e=floor, f in [0,1).
     mantissa = 10^f in [1,10). */
  if (!isfinite(logabs) || sign == 0) {
    printf("\napprox determinant = 0.000000000000000e+00\n");
    return;
  } else {
    const double invln10 = 1.0 / log(10.0);
    double log10abs = logabs * invln10;
    double e = floor(log10abs);
    double f = log10abs - e;
    double mant = pow(10.0, f);

    if (sign < 0) mant = -mant;

    /* Match JS-ish: mantissa with 15 digits after decimal */
    printf("\napprox determinant = %.15fe%+0.0f\n", mant, e);
  }
}

int main(int argc, char **argv) {
  const char *infile;
  double *A = NULL;
  int n = 0, lda = 0;
  double logabs = 0.0;
  int sign = 0;

  clock_t t0_overall, t0_det, t1_det, t1_overall;
  double sec_overall, sec_det;

  if (argc < 2) {
    fprintf(stderr, "Usage: %s <matrixfile.csv>\n", argv[0]);
    return 1;
  }

  infile = argv[1];
  printf("Reading matrix from %s ...\n", infile);

  t0_overall = clock();

  if (!read_matrix_csv(infile, &A, &n, &lda)) {
    die("Failed to read a square numeric rectangular CSV matrix.");
  }

  printf("Matrix size: %d x %d\n", n, n);

  t0_det = clock();
  det_log_form(A, n, lda, &logabs, &sign);
  t1_det = clock();

  sec_det = (double)(t1_det - t0_det) / (double)CLOCKS_PER_SEC;

  printf("\nSign(det)   = %d\n", sign);
  printf("log|det|      = %.17g\n", logabs);
  printf("time (s)      = %.6f\n", sec_det);

  print_pretty_det(logabs, sign);

  t1_overall = clock();
  sec_overall = (double)(t1_overall - t0_overall) / (double)CLOCKS_PER_SEC;
  printf("overall (s) =  %.6f\n", sec_overall);

  free(A);
  return 0;
}
