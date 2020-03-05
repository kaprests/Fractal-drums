# Solves the eigenvalue problem for the ten lowest eigenvalues and plots
# The corresponding eigenstates

include("setup.jl")
include("del_dos_regression.jl")
include("five_point_stensil.jl")
include("nine_point_stensil.jl")
using SparseArrays
using Arpack


if PROGRAM_FILE == basename(@__FILE__)
    ##########################################
    ### Ser parameters, LEVEL and GRID_RES ###
    ##########################################

    PLOTTING = false
    LEVEL = 3
    GRID_RES = 1

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

    lattice, frac = gen_quadkoch(LEVEL, GRID_RES)
    points_inside, points_outside, points_border= arrayify(lattice)
    N = length(points_inside)

    lap_mat = five_point_laplacian(N, lattice, points_inside)
    #lap_mat = nine_point_laplacian(N, lattice, points_inside)

    println("Solving EV-problem")
    eigvals, eigvecs = eigs(lap_mat, nev=10, which=:SM)
    sorted_indices = sortperm(eigvals)

    grid = zeros(size(lattice, 1), size(lattice, 1), 10)
    #surf_grid = Array{Float64, 3}(undef, (size(lattice, 1), size(lattice, 1), 10))
    surf_grid = fill(NaN, (size(lattice, 1), size(lattice, 1), 10))

    TOTAL_MEMORY_MB = 8030668
    mem_used = sizeof(lap_mat)*1e-6
    println("Bytesize of laplacian matrix (MB): ", mem_used)
    println("Percentage of total: ", mem_used*100/TOTAL_MEMORY_MB)

    ###########
    ### DOS ###
    ###########

    delta_N(eigvals, N)

    ####################
    ### Plot results ###
    ####################

    if PLOTTING
        println("Plotting")
        for i in 1:10
            idx = sorted_indices[i]
            for (j, p) in enumerate(points_inside)
                grid[p[1], p[2], i] = eigvecs[:, i][j]
                surf_grid[p[1], p[2], i] = eigvecs[:, i][j]
            end

            for (j, p) in enumerate(points_border)
                surf_grid[p[1], p[2], i] = 0
            end
            
            plt.imshow(transpose(grid[:, :, i]), origin="upper")
            plt.plot(first.(frac) .- 1 , last.(frac) .- 1)
            plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", GRID_RES: ", GRID_RES))
            #plt.savefig(string("eigenmode_2d", i, ".png"))
            plt.show()

            xy = collect(1: size(lattice, 1))
            plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", GRID_RES: ", GRID_RES))
            if length(ARGS) >= 3
                if ARGS[3] == "wire"
                    plt.plot_wireframe(xy, xy, transpose(surf_grid[:, :, i] ./ 10), color="gray")
                    plt.plot(first.(frac) , last.(frac), color="red")
                    plt.savefig(string("eigenmode_3d_wireframe", i, ".png"))
                else
                    plt.surf(grid[:, :, i], cmap=plt.cm.coolwarm, alpha=1)
                end
            else
                plt.surf(grid[:, :, i], cmap=plt.cm.coolwarm, alpha=1)
            end
            #plt.savefig(string("eigenmode_3d", i, ".png"))
            plt.show()
        end
    end
end


