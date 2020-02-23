# Nine point stensil approximation of the negative laplacian


function nine_point_laplacian(N, lattice, points_inside)
    println("Making laplacian matrix")
    lap_matrix = spzeros(N, N)
    for (idx, p) in enumerate(points_inside)
        x, y = p 
        lap_matrix[idx, idx] = 8/3
        for nn in (-2, -1 , 1, 2)
            try
                if lattice[x+nn, y] == INSIDE
                    nn_idx = findfirst(p -> p== (x+nn, y), points_inside)
                    lap_matrix[idx, nn_idx] = -1/3
                end
            catch
            end

            try
            if lattice[x, y+nn] == INSIDE
                nn_idx = findfirst(p -> p== (x, y+nn), points_inside)
                lap_matrix[idx, nn_idx] = -1/3
            end
            catch
            end
        end
    end 
    return lap_matrix
end

