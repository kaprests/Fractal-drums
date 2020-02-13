include("quadratic_koch.jl")
using LinearAlgebra

level = 3
lattice, x_lat, y_lat, frac = gen_quadkoch(level)
points_inside, points_outside, points_border= get_location_points(lattice)

N = length(points_inside)


function laplacian_matrix(N, lattice, points_inside)
    lap_matrix = zeros(N, N)
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


lap_mat = laplacian_matrix(N, lattice, points_inside)

# Solve eigenproblem
eigvals, eigvecs = eigen(lap_mat)
evec1 = eigvecs[1, :]

grid = zeros(size(lattice, 1), size(lattice, 1), 5)
for i in 1:5
    for (idx, p) in enumerate(points_inside)
        grid[Int(p[1]), Int(p[2]), i] = abs(eigvecs[i, :][idx])
    end
    plt.imshow(grid[:, :, 1])
    plt.show()
end


plt.plot(first.(points_inside), last.(points_inside), ".", color="green")
plt.plot(first.(points_outside), last.(points_outside), ".", color="red")
plt.plot(first.(points_border), last.(points_border), ".", color="blue")
plt.plot(first.(frac), last.(frac))
plt.show()



