# Solves the eigenvalue problem for the ten lowest eigenvalues and plots
# The corresponding eigenstates

include("setup.jl")
include("five_point_stensil.jl")
include("nine_point_stensil.jl")
using SparseArrays
using Arpack
using DelimitedFiles

# Consider splitting this up into smaller functions
function main()
    ##########################################
    ### Ser parameters, LEVEL and GRID_RES ###
    ##########################################

    PLOTTING = true
    LEVEL = 3
    GRID_RES = 1
    NEV = 10
    WIRE = false
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

    lattice, frac = gen_quadkoch(LEVEL, GRID_RES)
    points_inside, points_outside, points_border= arrayify(lattice)
    N = length(points_inside)

    #lap_mat = five_point_laplacian(N, lattice, points_inside)
    lap_mat = nine_point_laplacian(N, lattice, points_inside)

    TOTAL_MEMORY_MB = 7660000 # available according to htop
    mem_used = sizeof(lap_mat)*1e-6
    println("Bytesize of laplacian matrix (MB): ", mem_used)
    println("Percentage of total: ", mem_used*100/TOTAL_MEMORY_MB)

    println("Solving EV-problem")
    eigvals, eigvecs = eigs(lap_mat, nev=NEV, which=:SM)

    grid = zeros(size(lattice, 1), size(lattice, 1), 10)
    if WIRE
        wireframe_grid = fill(NaN, (size(lattice, 1), size(lattice, 1), 10))
    end

    if SAVE
        # Save eigenvalues and vectors to file
        filename = string("eigenvals_and_vecs_level", LEVEL, "gridres", GRID_RES, ".txt")
        open(filename, "w") do eigen
            writedlm(eigen, LEVEL)
            writedlm(eigen, GRID_RES)
            writedlm(eigen, N)
            writedlm(eigen, eigvals)
            writedlm(eigen, eigvecs)
        end
    end

    ####################
    ### Plot results ###
    ####################

    if PLOTTING
        println("Plotting")
        if (LEVEL == 1) && (GRID_RES == 2)
            plt.pcolormesh(lap_mat)
            plt.title(string("level: ", LEVEL, ", grid_res: ", GRID_RES))
            plt.savefig("laplacian_matrix.pdf")
            #plt.show()
            plt.cla()
            plt.clf()
        end

        for i in 1:NEV
            # For high levels the loop below seems to be slower than the eigen calculation...
            for (j, p) in Base.Iterators.enumerate(points_inside)
                grid[p[1], p[2], i] = eigvecs[:, i][j]
                #wireframe_grid[p[1], p[2], i] = eigvecs[:, i][j]
            end

            if WIRE
                for (j, p) in enumerate(points_border)
                    surf_grid[p[1], p[2], i] = 0
                end
            end

            if LEVEL > 3
                plt.imshow(transpose(grid[:, :, i][1:10:end]), origin="upper")
            else
                plt.imshow(transpose(grid[:, :, i]), origin="upper")
            end
            plt.plot(first.(frac) .- 1 , last.(frac) .- 1)
            plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", GRID_RES: ", GRID_RES))
            plt.savefig(string("eigenmode_2d", i, ".png"))
            #plt.show()
            plt.cla()
            plt.clf()

            xy = collect(1: size(lattice, 1))
            plt.title(string("eigenmode #", i, ", fractal LEVEL: ", LEVEL, ", GRID_RES: ", GRID_RES))
            if WIRE
                plt.plot_wireframe(xy, xy, transpose(surf_grid[:, :, i] ./ 10), color="gray")
                plt.plot(first.(frac) , last.(frac), color="red")
                plt.savefig(string("eigenmode_3d_wireframe", i, ".png"))
            else
                if LEVEL > 3
                    plt.surf(grid[:, :, i][1:10:end], cmap=plt.cm.coolwarm, alpha=1)
                else
                    plt.surf(grid[:, :, i], cmap=plt.cm.coolwarm, alpha=1)
                end
            end
            plt.plot(first.(frac) , last.(frac), color="red")
            plt.savefig(string("eigenmode_3d", i, ".png"))
            #plt.show()
            plt.cla()
            plt.clf()
        end
    end
end


if PROGRAM_FILE == basename(@__FILE__)
    main()
end


