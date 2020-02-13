include("quadratic_koch.jl")
using LinearAlgebra

level = 2
lattice, x_lat, y_lat, frac = gen_quadkoch(level, 2)
points_inside, points_outside, points_border= get_location_points(lattice)

N = length(points_inside)


function laplacian_matrix(N, lattice, points_inside)
    println("Making laplacian matrix")
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
println("Solving EV-problem")
eigvals, eigvecs = eigen(lap_mat)
sorted_indices = sortperm(eigvals)

grid = zeros(size(lattice, 1), size(lattice, 1), 5)
for i in 1:5
    idx = sorted_indices[i]
    for (j, p) in enumerate(points_inside)
        grid[Int(p[1]), Int(p[2]), i] = abs(eigvecs[:, idx][j])
    end
    plt.imshow(grid[:, :, i])
    plt.savefig(string("eigenmode_cntr_", i, ".pdf"))
    plt.title(string("eigenmode #", i))
    plt.show()
end

println("Plotting")
plt.plot(first.(points_inside), last.(points_inside), ".", color="green")
plt.plot(first.(points_outside), last.(points_outside), ".", color="red")
plt.plot(first.(points_border), last.(points_border), ".", color="blue")
plt.plot(first.(frac), last.(frac))
plt.title("Quadratic koch fractal on lattice")
plt.savefig("fractal_on_lattice.pdf")
plt.show()
