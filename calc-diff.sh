#!/bin/sh
# this script takes input data
# name value
# ...  ...
# and rebases the values as defined in calc.bc

while read -r name value; do
  d=$(echo "rebase($value)" | bc -l calc.bc)
  echo $name $d
done
