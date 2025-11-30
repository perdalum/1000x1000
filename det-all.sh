#!/bin/zsh

INPUT=$1

echo "Compare the result of log|det|"
./det-all-logdet.sh $1

echo ""
echo "Compare the calculation time for log|det|"
./det-all-time.sh $1

echo ""
echo "Compare the result of approximating the determinant"
./det-all-approx.sh $1

echo ""
echo "Compare the overall run time minus start-up time"
./det-all-overall.sh $1