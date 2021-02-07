# Solves the eigenvalue problem for the 1000 lowest eigenvalues and saves them to file

include("./lib/fractal_drums.jl")
using .fractal_drums
using SparseArrays
using Arpack
using DelimitedFiles


if basename(PROGRAM_FILE) == basename(@__FILE__)
    ##########################################
    ### Set parameters, LEVEL and GRID_RES ###
    ##########################################

    LEVEL = 3
    GRID_RES = 1
    NEV = 1000
    SAVE = true

    if length(ARGS) >= 1
        LEVEL = parse(Int, ARGS[1])
    else
        println("No argument provided, using default LEVEL=3")
    end

    if length(ARGS) >= 2
        GRID_RES = parse(Int, ARGS[2])
    else
        println("No argument provided, using default GRID_RES=1")
    end

    ###########################################################
    ### Make lattice, laplacian matrix and solce EV-problem ###
    ###########################################################

    frac = gen_quad_koch(LEVEL, GRID_RES)
    lattice = make_lattice(frac)
    points_inside, points_outside, points_border= arrayify(lattice)
    N = length(points_inside)

    println("N: ", N)

    lap_mat = five_point_laplacian(N, lattice, points_inside)
    #lap_mat = nine_point_laplacian(N, lattice, points_inside)

    println("Solving EV-problem")
    eigvals, vecs = eigs(lap_mat, nev=NEV, which=:SM, ritzvec=false)

    TOTAL_MEMORY_MB = 8030668
    mem_used = sizeof(lap_mat)*1e-6
    println("Bytesize of laplacian matrix (MB): ", mem_used)
    println("Percentage of total: ", mem_used*100/TOTAL_MEMORY_MB)

    if SAVE
        filename = string("eigenvalues_level", LEVEL, "_gridres", GRID_RES,".txt")
        open(filename, "w") do ev
            writedlm(ev, LEVEL)
            writedlm(ev, GRID_RES)
            writedlm(ev, N)
            writedlm(ev, eigvals)
        end
    end
end


