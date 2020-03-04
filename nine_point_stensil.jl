# Create nine point stensil approx. to the -laplacian operator


function nine_point_laplacian(N, lattice, points_inside)
    println("Making laplacian matrix")
    x_vec = zeros(N*9)
    y_vec = zeros(N*9)
    v_vec = zeros(N*9)
    
    # Set inner indices (nn_idx)
    for (i, p) in enumerate(points_inside)
        lattice[p[1], p[2]] = i
    end

    idx = 1
    for (i, p) in enumerate(points_inside)
        x, y = p 
        x_vec[idx] = i
        y_vec[idx] = i
        v_vec[idx] = 8/3
        idx += 1
        for nn in (-2, -1, 1, 2)
            try
                if lattice[x+nn, y] > 0
                    nn_idx = lattice[x+nn, y] # Nearest neigbours inner index
                    x_vec[idx] = i
                    y_vec[idx] = nn_idx
                    v_vec[idx] = -1/3
                    idx += 1
                end
            catch
                continue
            end

            try
                if lattice[x, y+nn] > 0
                    nn_idx = lattice[x, y+nn] # Nearest neigbours inner index
                    x_vec[idx] = i
                    y_vec[idx] = nn_idx
                    v_vec[idx] = -1/3
                    idx += 1
                end
            catch
                continue
            end
        end
    end 

    x_vec = x_vec[1:idx-1]
    y_vec = y_vec[1:idx-1]
    v_vec = v_vec[1:idx-1]

    lap_matrix = sparse(x_vec, y_vec, v_vec)
    return lap_matrix
end


