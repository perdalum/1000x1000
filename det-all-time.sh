#!/bin/zsh

INPUT=$1

echo -n "wsl\t";        ./det-matrix-big.wls $INPUT | grep "time (s) " | sed 's/time .*= //'
echo -n "julia\t";      ./det-matrix-big.jl  $INPUT | grep "time (s) " | sed 's/time .*= //'
echo -n "python\t";     ./det-matrix-big.py  $INPUT | grep "time (s) " | sed 's/time .*= //'
echo -n "javascript\t"; ./det-matrix-big.js  $INPUT | grep "time (s) " | sed 's/time .*= //'
echo -n "fortran\t";    ./det-matrix-big     $INPUT | grep "time (s) " | sed 's/time .*= //'