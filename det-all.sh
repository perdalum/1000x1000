#!/bin/zsh

INPUT=$1

echo -n "wsl\t"; ./det-matrix.wls $INPUT | grep determinant | sed 's/determinant =//'
echo -n "julia\t"; ./det-matrix-big.jl $INPUT | grep determinant | sed 's/determinant =//;s/\+//'
echo -n "python\t"; ./det-matrix-big.py $INPUT | grep determinant | sed 's/determinant =//;s/\+//'
