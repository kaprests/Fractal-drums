# Create five point stensil approx. to the -laplacian operator


function five_point_laplacian(N, lattice, points_inside)
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

