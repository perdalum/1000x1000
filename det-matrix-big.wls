#!/usr/bin/env wolframscript

(* Check argument: filename *)
If[Length[$ScriptCommandLine] < 2,
  Print["Usage: det-matrix.wls <matrixfile.csv>"];
  Exit[1];
];

infile = $ScriptCommandLine[[2]];
t0Overall = Now;
Print["Reading matrix from ", infile, " ..."];

mat = Import[infile, "CSV"];

(* Ensure numeric matrix *)
If[!MatrixQ[mat, NumericQ],
  Print["Error: imported data is not a numeric matrix."];
  Exit[1];
];

n = Length[mat];
Print["Matrix size: ", n, " x ", n];

(* Compute log|det| using LU decomposition for numerical stability *)
{t, {logdetval, signdet}} = AbsoluteTiming[
  Module[{lu, diag},
    lu = LUDecomposition[mat][[1]];
    diag = Diagonal[lu];
    {Total[Log[Abs[diag]]], Times @@ Sign[diag]}
  ]
];

Print["Sign(det)   = ", signdet];
Print["log|det|    = ", logdetval];
Print["time (s)    = ", t];

Print["\napprox determinant = ",ToString@NumberForm[approxDet=Exp[logdetval], NumberFormat -> (Row[{#1, "e", #3}] &)]]

(*
detval=Det[mat];
Print["Direct calculation of the determinant Det[A] = ", ToString@NumberForm[detval, NumberFormat -> (Row[{#1, "e", #3}] &)]]
*)

t1Overall = Now;
Print["overall (s) = ",QuantityMagnitude[t1Overall-t0Overall]]