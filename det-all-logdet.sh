#!/bin/zsh

INPUT=$1

echo -n "wsl\t";        ./det-matrix-big.wls $INPUT | grep "log|det| " | sed 's/log|det| *=//'
echo -n "julia\t";      ./det-matrix-big.jl  $INPUT | grep "log|det| " | sed 's/log|det| *=//'
echo -n "python\t";     ./det-matrix-big.py  $INPUT | grep "log|det| " | sed 's/log|det| *=//'
echo -n "javascript\t"; ./det-matrix-big.js  $INPUT | grep "log|det| " | sed 's/log|det| *=//'
echo -n "fortran\t";    ./det-matrix-big-f     $INPUT | grep "log|det| " | sed 's/log|det| *=//'
echo -n "C\t";    ./det-matrix-big-c     $INPUT | grep "log|det| " | sed 's/log|det| *=//'
