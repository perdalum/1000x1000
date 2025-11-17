#!/bin/zsh

INPUT=$1

echo -n "wsl\t"; ./det-matrix.wls $INPUT | grep time |sed 's/time (s) *= //'
echo -n "julia\t"; ./det-matrix-big.jl $INPUT | grep time | sed 's/time (s) *= //;s/\+//'
echo -n "python\t"; ./det-matrix-big.py $INPUT | grep time | sed 's/time (s) *= //;s/\+//'
