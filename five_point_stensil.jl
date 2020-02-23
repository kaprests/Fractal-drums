include("setup.jl")
include("del_dos_regression.jl")
using SparseArrays
using Arpack


function laplacian_matrix(N, lattice, points_inside)
    println("Making laplacian matrix")
    lap_matrix = spzeros(N, N)
    for (idx, p) in enumerate(points_inside)
        x, y = p
        lap_matrix[idx, idx] = 4
        for nn in (-1, 1)
            if lattice[x+nn, y] == INSIDE
                nn_idx = findfirst(p -> p== (x+nn, y), points_inside)
                lap_matrix[idx, nn_idx] = -1
            end
            if lattice[x, y+nn] == INSIDE
                nn_idx = findfirst(p -> p== (x, y+nn), points_inside)
                lap_matrix[idx, nn_idx] = -1
            end
        end
    end
    return lap_matrix
end


if PROGRAM_FILE == basename(@__FILE__)
    ######################################
    ### Ser parameters, LEVEL and LPPS ###
    ######################################

    LEVEL = 2
    LPPS = 2

    if length(ARGS) >= 1
        LEVEL = parse(Int, ARGS[1])
    else
        println("No argument provided, using default LEVEL=3")
    end

    if length(ARGS) >= 2
        LPPS = parse(Int, ARGS[2])
    else
        println("No argument provided, using default LPPS=0")
    end

    ###########################################################
    ### Make lattice, laplacian matrix and solce EV-problem ###
    ###########################################################

    lattice, frac = gen_quadkoch(LEVEL, LPPS)
    points_inside, points_outside, points_border= arrayify(lattice)
    N = length(points_inside)

    lap_mat = laplacian_matrix(N, lattice, points_inside)
    println("Solving EV-problem")
    eigvals, eigvecs = eigs(lap_mat, nev=10, which=:SM)
    sorted_indices = sortperm(eigvals)

    grid = zeros(size(lattice, 1), size(lattice, 1), 10)
    #surf_grid = Array{Float64, 3}(undef, (size(lattice, 1), size(lattice, 1), 10))
    surf_grid = fill(NaN, (size(lattice, 1), size(lattice, 1), 10))

    ###########
    ### DOS ###
    ###########

"""
    fit = deldos_fit(sort(eigvals))
    a, d = fit.coefs[1], fit.coefs[2]
"""

    ####################
    ### Plot results ###
    ####################

    println("PLotting")
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
        plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", LPPS: ", LPPS))
        #plt.savefig(string("eigenmode_2d", i, ".png"))
        plt.show()

        xy = collect(1: size(lattice, 1))
        if length(ARGS) >= 3
            if ARGS[3] == "wire"
                plt.plot_wireframe(xy, xy, transpose(surf_grid[:, :, i] ./ 10), color="gray")
                plt.plot(first.(frac) , last.(frac), color="red")
            else
                plt.surf(grid[:, :, i], cmap=plt.cm.coolwarm, alpha=1)
            end
        else
            plt.surf(grid[:, :, i], cmap=plt.cm.coolwarm, alpha=1)
        end
        plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", LPPS: ", LPPS))
        #plt.savefig(string("eigenmode_3d", i, ".png"))
        plt.show()
    end
end


