#!/usr/bin/env node
/* eslint-disable no-console */
/*
 brew install lapack
 npm install nlapack decimal.js
*/

const fs = require('fs');
const path = require('path');
const { performance } = require('perf_hooks');
const lapack = require('nlapack');
const Decimal = require('decimal.js');

// ---------- I/O ----------
function readMatrix(filePath) {
  const text = fs.readFileSync(filePath, 'utf8');
  const lines = text
    .split(/\r?\n/)
    .map(l => l.trim())
    .filter(l => l.length > 0);

  if (lines.length === 0) {
    throw new Error('File is empty');
  }

  const rows = lines.map(line => {
    // simple CSV, comma-separated
    const parts = line.split(',');
      return parts.map(p => {
        const x = parseFloat(p.trim());
        if (!Number.isFinite(x)) {
            throw new Error(`Non-numeric entry '${p}' in line '${line}'`);
        }
        return x;
    });
  });

  const nRows = rows.length;
  const nCols = rows[0].length;

  // Ensure rectangular
  for (const r of rows) {
    if (r.length !== nCols) {
      throw new Error(
        `Matrix is not rectangular: first row has ${nCols} entries, another has ${r.length}`
      );
    }
  }

  if (nRows !== nCols) {
    throw new Error(`Matrix is not square: ${nRows} x ${nCols}`);
  }

  const n = nRows;

  // LAPACK expects column-major; pack into Float64Array as column-major
  const A = new Float64Array(n * n);
  const lda = n;

  // A(i,j) -> A[j*lda + i], 0-based i=row, j=col
  for (let i = 0; i < n; i += 1) {
    for (let j = 0; j < n; j += 1) {
      A[j * lda + i] = rows[i][j];
    }
  }

  return { A, n, lda };
}

// ---------- LAPACK-based slogdet ----------
// Compute sign(det(A)) and log(|det(A)|) from LU (DGETRF).
function detLogForm(A, n, lda) {
  // ipiv is length min(m, n) in LAPACK; here m=n
  const ipiv = new Int32Array(n);

  // dgetrf(m, n, a, lda, ipiv)
  // Overwrites A with L+U in-place; ipiv holds pivot indices (1-based).
  const info = lapack.dgetrf(n, n, A, lda, ipiv);
  if (info < 0) {
    throw new Error(`dgetrf: argument ${-info} had an illegal value`);
  }
  if (info > 0) {
    // U(ii) is exactly zero -> singular -> det = 0
    return { logabs: -Infinity, sign: 0 };
  }

  // Permutation sign from ipiv (LAPACK pivot format).
  // Start with identity permutation of rows, apply swaps described by ipiv.
  let permSign = 1;
  const perm = new Int32Array(n);
  for (let i = 0; i < n; i += 1) {
    perm[i] = i;
  }

  for (let i = 0; i < n; i += 1) {
    const j = ipiv[i] - 1; // ipiv is 1-based
    if (j !== i) {
      const tmp = perm[i];
      perm[i] = perm[j];
      perm[j] = tmp;
      permSign *= -1;
    }
  }

  // Now determinant = permSign * product diag(U).
  // U diagonal entries are A[i + i*lda] in column-major.
  let logabs = 0.0;
  let sign = permSign;

  for (let i = 0; i < n; i += 1) {
    const uii = A[i * lda + i]; // same as A[i + i*lda]

    if (uii === 0) {
      return { logabs: -Infinity, sign: 0 };
    }

    const s = Math.sign(uii);
    sign *= s;
    logabs += Math.log(Math.abs(uii));
  }

  // If sign ended up zero (shouldn't happen unless weird data), treat as singular.
  if (sign === 0) {
    return { logabs: -Infinity, sign: 0 };
  }

  return { logabs, sign };
}

// ---------- High-precision pretty determinant ----------
function prettyDet(logabs, sign, prec = 100) {
  if (!Number.isFinite(logabs) || sign === 0) {
    return new Decimal(0);
  }

  Decimal.set({ precision: prec });

  // Convert via string to avoid binary → decimal surprises
  const x = new Decimal(logabs.toString());
  const mag = x.exp(); // exp in base e
  return new Decimal(sign).times(mag);
}

// ---------- main ----------
function main() {
  if (process.argv.length < 3) {
    console.error('Usage: det_matrix_big.js <matrixfile.csv>');
    process.exit(1);
  }

  const infile = path.resolve(process.argv[2]);
  console.log(`Reading matrix from ${infile} ...`);

  let Apacked;
  let n;
  let lda;

  const t0_read = performance.now();
  try {
    const res = readMatrix(infile);
    Apacked = res.A;
    n = res.n;
    lda = res.lda;
  } catch (err) {
    console.error(String(err.message || err));
    process.exit(1);
  }
  const t1_read = performance.now();

  console.log(`Matrix size: ${n} x ${n}`);

  // Time LU + log|det|
  const t0_det = performance.now();
  let logabs;
  let sign;
  try {
    const out = detLogForm(Apacked, n, lda);
    logabs = out.logabs;
    sign = out.sign;
  } catch (err) {
    console.error(`Error in LAPACK det computation: ${String(err.message || err)}`);
    process.exit(1);
  }
  const t1_det = performance.now();

  console.log('\nSign(det)   =', sign);
  console.log('log|det|    =', logabs);

  console.log('\napprox');
  const t0_pretty_det = performance.now();
  const detApprox = prettyDet(logabs, sign, 100);
  const t1_pretty_det = performance.now();

  // Format as scientific notation with 15 digits after the decimal,
  // similar to Python's "{:.15e}".
  console.log('determinant =', detApprox.toExponential(15));
  console.log('I/O (s):    ', (t1_read - t0_read) / 1000);
  console.log('LAPACK (s): ', (t1_det - t0_det) / 1000);
  console.log('Big exp (s):', (t1_pretty_det - t0_pretty_det) / 1000);
}

if (require.main === module) {
  main();
}
