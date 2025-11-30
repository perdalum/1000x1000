#!/bin/zsh

INPUT=$1

echo -n "wsl\t";        ./det-matrix-big.wls $INPUT | grep "approx" | sed 's/approx determinant .*=//'
echo -n "julia\t";      ./det-matrix-big.jl  $INPUT | grep "approx" | sed 's/approx determinant .*=//'
echo -n "python\t";     ./det-matrix-big.py  $INPUT | grep "approx" | sed 's/approx determinant .*=//'
echo -n "javascript\t"; ./det-matrix-big.js  $INPUT | grep "approx" | sed 's/approx determinant .*=//'
echo -n "fortran\t";    ./det-matrix-big     $INPUT | grep "approx" | sed 's/approx determinant .*=//'