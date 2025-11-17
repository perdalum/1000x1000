#!/usr/bin/env wolframscript

(* Check argument: filename *)
If[Length[$ScriptCommandLine] < 2,
  Print["Usage: det-matrix.wls <matrixfile.csv>"];
  Exit[1];
];

infile = $ScriptCommandLine[[2]];

Print["Reading matrix from ", infile, " ..."];

mat = Import[infile, "CSV"];

(* Ensure numeric matrix *)
If[!MatrixQ[mat, NumericQ],
  Print["Error: imported data is not a numeric matrix."];
  Exit[1];
];

n = Length[mat];
Print["Matrix size: ", n, " x ", n];

(* Time the determinant *)
{t, detval} = AbsoluteTiming[Det[mat]];

Print["determinant = ", ToString@NumberForm[detval, NumberFormat -> (Row[{#1, "e", #3}] &)]];
Print["time (s)    = ", t];