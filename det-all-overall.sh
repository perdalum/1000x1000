#!/bin/zsh

INPUT=$1

echo -n "wsl\t";        ./det-matrix-big.wls $INPUT | grep "overall" | sed 's/overall .*= *//'
echo -n "julia\t";      ./det-matrix-big.jl  $INPUT | grep "overall" | sed 's/overall .*= *//'
echo -n "python\t";     ./det-matrix-big.py  $INPUT | grep "overall" | sed 's/overall .*= *//'
echo -n "javascript\t"; ./det-matrix-big.js  $INPUT | grep "overall" | sed 's/overall .*= *//'
echo -n "fortran\t";    ./det-matrix-big     $INPUT | grep "overall" | sed 's/overall .*= *//'