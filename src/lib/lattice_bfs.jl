"""
Lattice creation, breadth first like search from center
"""

module lattice_bfs

export make_lattice, arrayify

const INSIDE_POINT = 1
const OUTSIDE_POINT = -1
const BORDER_POINT = 0


function make_lattice(frac_points)
    x = first.(frac_points)
    N = Int(max(x...))
    lattice = fill(OUTSIDE_POINT, (N, N))

    for point in frac_points
        lattice[Int(point[1]), Int(point[2])] = BORDER_POINT
    end

    # Center is INSIDE_POINT, always
    x0 = y0 = Int((N+1)/2)
    center = (x0, y0)
    lattice[x0, y0] = INSIDE_POINT

    # neares neighbours of center
    left = (x0 - 1, y0)
    right = (x0 + 1, y0)
    down = (x0, y0 - 1)
    up = (x0, y0 + 1)

    points = [left, right, down, up]
    println("begin search")
    for point in points
        x, y = point
        if lattice[x, y] == OUTSIDE_POINT
            # New INSIDE_POINT point
            lattice[x, y] = INSIDE_POINT

            # Add nearest neighbours to points
            for nn in (-1, 1)
                    push!(points, (x + nn, y))
                    push!(points, (x, y + nn))
            end
        else
            continue
        end
    end
    return lattice
end


function arrayify(lattice)
    inside = []
    outside = []
    border = []
    for (idx, p) in enumerate(CartesianIndices(lattice))
        if lattice[p] == BORDER_POINT
            push!(border, (p[1], p[2]))
        elseif lattice[p] == OUTSIDE_POINT
            push!(outside, (p[1], p[2]))
        elseif lattice[p] > 0
            push!(inside, (p[1], p[2]))
        end
    end
    return inside, outside, border
end


end
