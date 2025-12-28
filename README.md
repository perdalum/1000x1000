# Code for my piece on the comparison of the performance of five implementations of the calculation of the determinant of a matrix

This repository contains the source code for my piece on [Re-learning something about scientific computing](https://moldrup-dalum.dk/per/output/2025-11-30--1000x1000.html) on the comparison of the performance of five implementations of the calculation of the determinant of a matrix, a.k.a. just having some fun…

## Installation

The scripts utilize the following programs:

- `wolframscript`. If you don't have a license for Wolfram products, just install the free [Wolfram Engine](https://www.wolfram.com/engine/)

- [Julia](https://julialang.org/) with the `LinearAlgebra`, `DelimitedFiles`, and `Printf` packages

- [Python](https://www.python.org/) with the `sys`, `time`, `numpy`, `pathlib`, and `decimal` package

- JavaScript engine, e.g., [node.js](https://nodejs.org/) with the `nlapack` and `decimal.js` npm packages.

- Fortran compiler, e.g., [gfortran](https://gcc.gnu.org/fortran/). This one also relies on the `lapack` package.

- C compiler, fx clang on macOS. This one also relies on the `lapack` package.

To use the JavaScript package `nlapack`, you need the `lapack` system library, and to compile the FORTRAN and C programs, you in addition need the `blas` library. Om macOS, that can be installed by Homebrew:

    brew install gfortran lapack blas

## Usage

To generate matrices of any size, use either the Wolfram script or the JavaScript

    > ./make-matrix.wls 1000 1000.dat
    > ./make_random_matrix.js 1000 > 1000.dat

Then use the scripts to run the computation in C, FORTRAN, JavaScript, Python or Julia

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

### MacBook Pro M1 Max, 32GB RAM, 2025-12-28

    >: ./det-all.sh matrix-1000.dat       
    Compare the result of log|det|
    wsl	 1716.8975572250192
    julia	 1716.8975572250183
    python	 1716.8975572250201
    javascript	 1716.8975572250201
    fortran	 1716.8975572250192
    C	 1716.8975572250192

    Compare the calculation time for log|det|
    wsl	0.009941
    julia	0.14061784744262695
    python	0.016119003295898438
    javascript	0.154275416
    fortran	0.020821
    C	0.018572

    Compare the result of approximating the determinant
    wsl	 4.356473694513e745
    julia	 4.356473694508985e+745
    python	 4.356473694516749e+745
    javascript	 4.356473694516749e+745
    fortran	 4.356473694512254e+745
    C	 4.356473694512254e+745

    Compare the overall run time minus start-up time
    wsl	2.355909`6.823703494390263
    julia	0.7916049957275391
    python	0.2501208782196045
    javascript	0.27083329100000003
    fortran	0.670018
    C	0.091895
