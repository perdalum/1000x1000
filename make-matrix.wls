#!/usr/bin/env wolframscript

(* Check arguments: N and filename *)
If[Length[$ScriptCommandLine] < 3,
  Print["Usage: make-matrix.wls <N> <outfile.csv>"];
  Exit[1];
];

n = ToExpression[$ScriptCommandLine[[2]]];
outfile = $ScriptCommandLine[[3]];

If[!IntegerQ[n] || n <= 0,
  Print["N must be a positive integer."];
  Exit[1];
];

Print["Creating random ", n, " x ", n, " matrix..."];

(* Uniform random reals in [0,1] *)
mat = RandomReal[{0, 1}, {n, n}];

(* Export as CSV for easy reading from Julia *)
Export[outfile, mat, "CSV"];

Print["Wrote matrix to ", outfile];