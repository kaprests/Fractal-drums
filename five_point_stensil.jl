# Create five point stensil approx. to the -laplacian operator


function five_point_laplacian(N, lattice, points_inside)
    println("Making laplacian matrix")
    #lap_matrix = spzeros(N, N)
    x_vec = zeros(N*5)
    y_vec = zeros(N*5)
    v_vec = zeros(N*5)

    idx = 1
    for (i, p) in enumerate(points_inside)
        x, y = p 
        #lap_matrix[idx, idx] = 4 
        x_vec[idx] = x
        y_vec[idx] = y
        v_vec[idx] = 4
        idx += 1
        for nn in (-1, 1)
            if lattice[x+nn, y] == INSIDE
                nn_idx = findfirst(p -> p== (x+nn, y), points_inside)
                #lap_matrix[idx, nn_idx] = -1
                x_vec[idx] = i
                y_vec[idx] = nn_idx
                v_vec[idx] = -1
                idx += 1
            end
            if lattice[x, y+nn] == INSIDE
                nn_idx = findfirst(p -> p== (x, y+nn), points_inside)
                #lap_matrix[idx, nn_idx] = -1
                x_vec[idx] = i
                y_vec[idx] = nn_idx
                v_vec[idx] = -1
                idx += 1
            end
        end
    end 

    x_vec = x_vec[1:idx]
    y_vec = y_vec[1:idx]
    v_vec = v_vec[1:idx]

#    x_vec = x_vec[x_vec .!= 0]
#    y_vec = y_vec[y_vec .!= 0]
#    v_vec = v_vec[v_vec .!= 0]

    lap_matrix = sparse(x_vec, y_vec, v_vec)
    return lap_matrix
end


