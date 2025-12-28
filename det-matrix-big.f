      PROGRAM DETMATBIG
C     ================================================================
C     Compute determinant of large matrix using LU decomposition
C     with log-based arithmetic to avoid overflow/underflow
C
C     Compile with gfortran -o det-matrix-big det-matrix-big.f -llapack -lblas
C     ================================================================
      IMPLICIT NONE
      INTEGER MAXN
      PARAMETER (MAXN=10000)

      DOUBLE PRECISION A(MAXN,MAXN)
      INTEGER IPIV(MAXN)
      INTEGER N, INFO, I
      CHARACTER*256 FNAME
      DOUBLE PRECISION LOGABS, SIGN, T0, T1, T0_overall, T1_overall, DET
C     start overall time counter
      CALL CPU_TIME(T0_overall)

C     Get command line argument
      CALL GETARG(1, FNAME)
      IF (FNAME .EQ. ' ') THEN
         WRITE(*,*) 'Usage: det-matrix-big <matrixfile.dat>'
         STOP 1
      ENDIF

C     Read matrix from file
      WRITE(*,'(A,A)') 'Reading matrix from ', TRIM(FNAME)
      CALL RDMAT(FNAME, A, MAXN, N)
      WRITE(*,'(A,I0,A,I0)') 'Matrix size: ', N, ' x ', N

C     Time LU decomposition
      CALL CPU_TIME(T0)

C     Perform LU factorization using LAPACK
      CALL DGETRF(N, N, A, MAXN, IPIV, INFO)

      IF (INFO .NE. 0) THEN
         WRITE(*,*) 'Error: DGETRF failed with INFO =', INFO
         STOP 1
      ENDIF

C     Compute log(|det|) and sign from LU factors
      CALL DETLOG(A, MAXN, N, IPIV, LOGABS, SIGN)

      CALL CPU_TIME(T1)

C     Print results
      WRITE(*,*)
      WRITE(*,'(A,F4.1)') 'Sign(det)   = ', SIGN
C      WRITE(*,'(A,E25.15)') 'log|det|    = ', LOGABS
      WRITE(*,'(A,F18.13)') 'log|det|    = ', LOGABS
      WRITE(*,'(A,F8.6)') 'time (s)    = ', T1-T0

C     Print approximate determinant (overflow-safe scientific)
      WRITE(*,*)
      CALL PRINT_PRETTY_DET(LOGABS, SIGN)
      
      CALL CPU_TIME(T1_overall)
      WRITE(*, '(A,F12.6)') 'overall (s) = ',T1_overall-T0_overall
      END PROGRAM DETMATBIG


C     ================================================================
C     Read matrix from comma-separated file
C     ================================================================
      SUBROUTINE RDMAT(FNAME, A, MAXN, N)
      IMPLICIT NONE
      CHARACTER*(*) FNAME
      INTEGER MAXN, N
      DOUBLE PRECISION A(MAXN,MAXN)

      INTEGER I, J, IOS
      CHARACTER*20000 LINE
      INTEGER NREAD

C     Open file
      OPEN(UNIT=10, FILE=FNAME, STATUS='OLD', IOSTAT=IOS)
      IF (IOS .NE. 0) THEN
         WRITE(*,*) 'Error opening file: ', TRIM(FNAME)
         STOP 1
      ENDIF

C     Count rows
      N = 0
      DO WHILE (.TRUE.)
         READ(10, '(A)', IOSTAT=IOS) LINE
         IF (IOS .NE. 0) EXIT
         IF (LEN_TRIM(LINE) .GT. 0) N = N + 1
      ENDDO
      REWIND(10)

C     Read matrix values
      DO I = 1, N
         READ(10, '(A)') LINE
         CALL PARSELINE(LINE, A, MAXN, I, NREAD)
         IF (I .EQ. 1 .AND. NREAD .NE. N) THEN
            WRITE(*,*) 'Warning: Matrix not square'
            WRITE(*,*) 'Rows:', N, 'Cols:', NREAD
         ENDIF
      ENDDO

      CLOSE(10)

      RETURN
      END


C     ================================================================
C     Parse comma-separated line into array
C     ================================================================
      SUBROUTINE PARSELINE(LINE, A, MAXN, IROW, NCOL)
      IMPLICIT NONE
      CHARACTER*(*) LINE
      INTEGER MAXN, IROW, NCOL
      DOUBLE PRECISION A(MAXN,*)

      INTEGER J, START, COMMAPOS, LLEN
      CHARACTER*100 TOKEN

      LLEN = LEN_TRIM(LINE)
      START = 1
      J = 0

      DO WHILE (START .LE. LLEN)
         J = J + 1
         IF (J .GT. MAXN) EXIT

C        Find next comma starting from START position
         COMMAPOS = INDEX(LINE(START:LLEN), ',')

         IF (COMMAPOS .EQ. 0) THEN
C           No more commas - read to end of line
            TOKEN = LINE(START:LLEN)
            READ(TOKEN, *) A(IROW,J)
            EXIT
         ELSE
C           Extract value before comma
C           COMMAPOS is relative to START, so absolute position is START+COMMAPOS-1
            TOKEN = LINE(START:START+COMMAPOS-2)
            READ(TOKEN, *) A(IROW,J)
C           Move past the comma
            START = START + COMMAPOS
         ENDIF
      ENDDO

      NCOL = J

      RETURN
      END


C     ================================================================
C     Compute log(|det|) and sign from LU factorization
C     ================================================================
      SUBROUTINE DETLOG(A, LDA, N, IPIV, LOGABS, SIGN)
      IMPLICIT NONE
      INTEGER LDA, N
      DOUBLE PRECISION A(LDA,N)
      INTEGER IPIV(N)
      DOUBLE PRECISION LOGABS, SIGN

      INTEGER I, NSWAPS
      DOUBLE PRECISION DIAG

C     Initialize
      LOGABS = 0.0D0
      SIGN = 1.0D0

C     Product of diagonal elements gives determinant
      DO I = 1, N
         DIAG = A(I,I)

C        Track sign
         IF (DIAG .LT. 0.0D0) THEN
            SIGN = -SIGN
            DIAG = -DIAG
         ENDIF

C        Add to log sum
         IF (DIAG .GT. 0.0D0) THEN
            LOGABS = LOGABS + LOG(DIAG)
         ELSE
            WRITE(*,*) 'Warning: zero diagonal element'
            LOGABS = -1.0D30
            RETURN
         ENDIF
      ENDDO

C     Account for row swaps in pivot vector
      NSWAPS = 0
      DO I = 1, N
         IF (IPIV(I) .NE. I) THEN
            NSWAPS = NSWAPS + 1
         ENDIF
      ENDDO

C     Each swap changes sign
      IF (MOD(NSWAPS, 2) .EQ. 1) THEN
         SIGN = -SIGN
      ENDIF

      RETURN
      END

C=======================================================================
C  Print sign * exp(logabs) in scientific notation without overflow
C  det = sign * mant * 10^e, with mant in [1,10)
C=======================================================================
      SUBROUTINE PRINT_PRETTY_DET(LOGABS, SIGN)
      IMPLICIT NONE
      DOUBLE PRECISION LOGABS, SIGN
      DOUBLE PRECISION LN10, INVLN10, LOG10ABS
      DOUBLE PRECISION E, F, MANT

      LN10 = LOG(10.0D0)

C     Handle singular / invalid
      IF (SIGN .EQ. 0.0D0) THEN
         WRITE(*,'(A)') 'approx determinant = 0.000000000000000e+00'
         RETURN
      ENDIF
      IF (LOGABS .LT. -1.0D200) THEN
         WRITE(*,'(A)') 'approx determinant = 0.000000000000000e+00'
         RETURN
      ENDIF

      INVLN10 = 1.0D0 / LN10
      LOG10ABS = LOGABS * INVLN10

C     e = floor(log10abs) for double precision
      E = AINT(LOG10ABS)
      IF (LOG10ABS .LT. 0.0D0 .AND. LOG10ABS .NE. E) THEN
         E = E - 1.0D0
      ENDIF
      F = LOG10ABS - E

      MANT = 10.0D0 ** F
      IF (SIGN .LT. 0.0D0) MANT = -MANT

C     Print like: mantissa with 15 digits, exponent as integer
      WRITE(*,100) MANT, INT(E)
  100 FORMAT('approx determinant = ',F20.15,'e',SP,I12)

      RETURN
      END
