#!/usr/bin/env python3
import sys
import time
import numpy as np
from pathlib import Path
from decimal import Decimal, getcontext

def read_matrix(path):
    """
    Read a numeric matrix from a text file.

    This assumes comma-separated values (CSV). Change `delimiter` if needed.
    """
    try:
        data = np.loadtxt(path, delimiter=",", dtype=np.float64)
    except Exception as e:
        raise RuntimeError(f"Failed to read matrix from {path}: {e}")

    if data.ndim != 2:
        raise RuntimeError("File does not contain a 2D matrix")
    if data.shape[0] != data.shape[1]:
        raise RuntimeError(f"Matrix is not square: {data.shape}")

    return data


def det_log_form(A):
    """
    Return (log|det A|, sign(det A)), matching the Julia logabsdet convention.
    NumPy's slogdet returns (sign, logabsdet), so we swap order.
    """
    sign, logabsdet = np.linalg.slogdet(A)
    return logabsdet, sign


def pretty_det(logabs, sign, prec=100):
    """
    Approximate det(A) as sign * exp(logabs) using a high-precision Decimal.

    Note: the precision is still fundamentally limited by the original
    float64 `logabs`, but this avoids overflow and prints a huge number.
    """
    getcontext().prec = prec
    # Convert via string to avoid binary → decimal quirks
    x = Decimal(str(logabs))
    mag = x.exp()  # exp in base e, like Julia's exp(BigFloat(logabs))
    return Decimal(sign) * mag


def main():
    if len(sys.argv) < 2:
        print("Usage: det_matrix_big.py <matrixfile.csv>")
        sys.exit(1)

    t0_overall = time.time()
    infile = Path(sys.argv[1])

    print(f"Reading matrix from {infile} ...")

    try:
        A = read_matrix(infile)
    except RuntimeError as e:
        print(e)
        sys.exit(1)

    n = A.shape[0]
    print(f"Matrix size: {n} x {n}")

    # Time slogdet (LU + logabsdet internally)
    t0 = time.time()
    logabs, sign = det_log_form(A)
    t1 = time.time()

    print("\nSign(det)   =", sign)
    print("log|det|    =", logabs)
    print("time (s)    =", t1 - t0)

    # Optional: print gigantic approximate determinant
    print("\napprox determinant = ", f"{pretty_det(logabs, sign):16.15e}")

    t1_overall = time.time()
    print("overall (s) = ",t1_overall-t0_overall)

if __name__ == "__main__":
    main()