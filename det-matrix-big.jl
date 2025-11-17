#!/usr/bin/env julia
using LinearAlgebra
using DelimitedFiles
using Printf

function read_matrix(path)
    data = readdlm(path, ',', Float64)
    if ndims(data) != 2
        error("File does not contain a 2D matrix")
    end
    if size(data,1) != size(data,2)
        error("Matrix is not square: $(size(data))")
    end
    return data
end

function det_log_form(A)
    # logabsdet returns (log|det A|, sign(det A))
    return logabsdet(A)
end

function pretty_det(logabs, sign)
    # Convert logabs to a BigFloat magnitude *only once*
    x = BigFloat(logabs)
    mag = exp(x)
    return sign * mag
end

function main()
    if length(ARGS) < 1
        println("Usage: det-matrix-big.jl <matrixfile.csv>")
        exit(1)
    end

    infile = ARGS[1]
    println("Reading matrix from $infile ...")

    A = read_matrix(infile)
    n = size(A,1)
    println("Matrix size: $(n) x $(n)")

    # Time LU + logabsdet
    t0 = time()
    logabs, sign = det_log_form(A)
    t1 = time()

    println("\nSign(det)   = $sign")
    println("log|det|    = $logabs")
    println("time (s)    = $(t1 - t0)")

    # Optional: print gigantic number (slower but still cheap)
    println("\napprox")
    @printf("determinant = %.15e\n", pretty_det(logabs, sign))
    #println("determinant = ", pretty_det(logabs, sign))
end

main()