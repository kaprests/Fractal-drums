include("setup.jl")
using SparseArrays
using Arpack


function laplacian_matrix(N, lattice, points_inside)
    println("Making laplacian matrix")
    lap_matrix = spzeros(N, N)
    for (idx, p) in enumerate(points_inside)
        x, y = p
        lap_matrix[idx, idx] = 4
        for nn in (-1, 1)
            if (x+nn, y) in points_inside
                nn_idx = findfirst(p -> p== (x+nn, y), points_inside)
                lap_matrix[idx, nn_idx] = -1
            end
            if (x, y+nn) in points_inside
                nn_idx = findfirst(p -> p== (x, y+nn), points_inside)
                lap_matrix[idx, nn_idx] = -1
            end
        end
    end
    return lap_matrix
end


if PROGRAM_FILE == basename(@__FILE__)
    level = 3
    lpps = 0
    lattice, frac = gen_quadkoch(level, lpps)
    points_inside, points_outside, points_border= arrayify(lattice)
    N = length(points_inside)


    lap_mat = laplacian_matrix(N, lattice, points_inside)
    println("Solving EV-problem")
    eigvals, eigvecs = eigs(lap_mat, nev=10, which=:SM)
    sorted_indices = sortperm(eigvals)

    grid = zeros(size(lattice, 1), size(lattice, 1), 10)
    for i in 1:10
        idx = sorted_indices[i]
        for (j, p) in enumerate(points_inside)
            grid[p[1], p[2], i] = eigvecs[:, i][j]
        end
        
        plt.imshow(grid[:, :, i])
        plt.title(string("eigenmode #", i, ", fractal level: ", level, ", lpps: ", lpps))
        #plt.savefig(string("eigenmode_2d", i, ".png"))
        plt.show()

        xy = collect(1: size(lattice, 1))
        plt.surf(xy, xy, grid[:, :, i], cmap=plt.cm.coolwarm)
        plt.title(string("eigenmode #", i, ", fractal level: ", level, ", lpps: ", lpps))
        #plt.savefig(string("eigenmode_3d", i, ".png"))
        plt.show()
    end
end


