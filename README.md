# Code for my piece on the comparison of the performance of five implementations of the calculation of the determinant of a matrix

This repository contains the source code for my piece on [Re-learning something about scientific computing](https://moldrup-dalum.dk/per/output/2025-11-30--1000x1000.html) on the comparison of the performance of five implementations of the calculation of the determinant of a matrix, a.k.a. just having some fun…

## Installation

The scripts utilize the following programs:

- `wolframscript`. If you don't have a license for Wolfram products, just install the free [Wolfram Engine](https://www.wolfram.com/engine/)

- [Julia](https://julialang.org/) with the `LinearAlgebra`, `DelimitedFiles`, and `Printf` packages

- [Python](https://www.python.org/) with the `sys`, `time`, `numpy`, `pathlib`, and `decimal` package

- JavaScript engine, e.g., [node.js](https://nodejs.org/) with the `nlapack` and `decimal.js` npm packages.

- Fortran compiler, e.g., [gfortran](https://gcc.gnu.org/fortran/). This one also relies on the `lapack` package.

To use the JavaScript package `nlapack`, you need the `lapack` system library, and to compile the FORTRAN program, you in addition need the `blas` library. Om macOS, that can be installed by Homebrew:

    brew install gfortran lapack blas

## Usage

To generate matrices of any size, use either the Wolfram script or the JavaScript

    > ./make-matrix.wls 1000 1000.dat
    > ./make_random_matrix.js 1000 > 1000.dat

Then use of of the scripts to run the computation in FORTRAN, JavaScript, Python or Julia

    ./det-matrix-big.wls 1000.dat

## Comparisons

The `det-all.sh` script runs all the comparison scripts and produce this output

    Compare the result of log|det|
    wsl         1716.8975572250192
    julia       1716.8975572250195
    python      1716.8975572250201
    javascript  1716.8975572250201
    fortran     1716.8975572250192

    Compare the calculation time for log|det|
    wsl         0.015226
    julia       0.22920989990234375
    python      0.016331911087036133
    javascript  0.19198841600000002
    fortran     0.009711

    Compare the result of approximating the determinant
    wsl         4.356473694513e745
    julia       4.356473694513937e+745
    python      4.356473694516749e+745
    javascript  4.356473694516749e+745
    fortran     Infinity

    Compare the overall run time minus start-up time
    wsl         2.887176`6.912018248209303
    julia       0.9917140007019043
    python      0.3019130229949951
    javascript  0.413815292
    fortran     0.804573
