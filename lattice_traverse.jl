############################################################################
### Lattice creation, naive traverse method to determine point locations ###
############################################################################


@enum Location INSIDE OUTSIDE BORDER


struct Point
    x::Int
    y::Int
    location::Location
end


function is_enclosed(p::Tuple, lower, upper, frac_points, lat_const)
    """
    Chech if arbitrary point is INSIDE, on or OUTSIDE of fractal.
    Checks by traversing from the point til the BORDER and determine
    INSIDE/OUTSIDE of fractal from the orientation of the curve.
    Checks if point is on BORDER before traversing

    All points on the traverse path between the initial point and the
    BORDER will have same location. Therfore it is not needed to 
    do this traverse check for every point.

    returns:
        determined_points: list of points (tuples)
        location: INSIDE/OUTSIDE/BORDER
    """
    x = p[1]
    x_walker = p[1]
    y = p[2]

    determined_points = []
    #push!(determined_points, (x, y))

    if (x, y) in frac_points
        # Point on BORDER, not INSIDE fractal
        #return determined_points, BORDER
        return Point(x, y, BORDER)
    end

    if x > upper/2
        # Traverse right
        while x_walker < upper
            x_walker += lat_const
            if (x_walker, y) in frac_points
                # collision
                idx = findall(p->p==(x_walker, y), frac_points)[1]
                BORDER = frac_points[idx]
                BORDER_next = frac_points[1]
                BORDER_prev = frac_points[end]
                try
                    BORDER_next = frac_points[idx+1]
                    BORDER_prev = frac_points[idx-1]
                finally
                end
                if BORDER_next[1] > BORDER[1] && BORDER_prev[2] < BORDER[2]
                    # next BORDER is right and BORDER_prev is down
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                elseif BORDER_next[2] > BORDER[2] && BORDER_prev[1] > BORDER[1]
                    # next BORDER is up, and prev is right
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                elseif BORDER_next[2] > BORDER[2] && BORDER_prev[2] < BORDER[2]
                    # next is up prev is down
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                else
                    return Point(x, y, OUTSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, OUTSIDE
                end
            else
                #push!(determined_points, (x_walker, y))
            end
        end
        return Point(x, y, OUTSIDE)
        #return determined_points, OUTSIDE
    else
        # Traverse right
        while x_walker > lower
            x_walker -= lat_const
            if (x_walker, y) in frac_points
                # collision
                idx = findall(p->p==(x_walker, y), frac_points)[1]
                BORDER = frac_points[idx]
                BORDER_next = frac_points[1]
                BORDER_prev = frac_points[end]
                try
                    BORDER_next = frac_points[idx+1]
                    BORDER_prev = frac_points[idx-1]
                catch
                end
                if BORDER_next[2] < BORDER[2] && BORDER_prev[1] < BORDER[1]
                    # next BORDER is down, prev is left
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                elseif BORDER_next[1] < BORDER[1] && BORDER_prev[2] > BORDER[2]
                    # next BORDER is left, prev is up
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                elseif BORDER_next[2] < BORDER[2] && BORDER_prev[2] > BORDER[2]
                    # next is down, prev is up
                    return Point(x, y, INSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, INSIDE
                else
                    return Point(x, y, OUTSIDE)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, OUTSIDE
                end
            else
                #push!(determined_points, (x_walker, y))
            end
        end
        return Point(x, y, OUTSIDE)
        #return determined_points, OUTSIDE
    end
end


function gen_lattice_ts(frac_points)
    """ Generates lattice with the traverse method for checking points location """
    lat_const = 1

    x = first.(frac_points)
    y = last.(frac_points)
    min_frac = min(x...)
    max_frac = max(x...)

    lattice_vals = collect(min_frac:lat_const:max_frac)
    L_lat = size(lattice_vals, 1)
    x_lat = transpose(repeat(lattice_vals, 1, L_lat))
    y_lat = repeat(lattice_vals, 1, L_lat)
    lat_size = size(x_lat, 1) * size(x_lat, 2)
    coords = collect(zip(x_lat, y_lat)) # List of coordinates as tuples

    lattice = Array{Point}(undef, (L_lat, L_lat))

    println("Making lattice, checking for INSIDErs")
    for (i, coord) in enumerate(coords)
        lattice[Int(coord[1]), Int(coord[2])]=is_enclosed(coord, min_frac, max_frac,          frac_points, lat_const)
    end
    return x_lat, y_lat, lattice
end


function get_location_points(lattice)
""" extracts arrays with the different locations """
    points_inside = []
    points_outside = []
    points_border = []

    for point in lattice
        if point.location == INSIDE
            push!(points_inside, (point.x, point.y))
        else
            push!(points_inside, (point.x, point.y))
        end
    end
    println("#points INSIDE: ", length(points_inside))
    println("#points on BORDER ", length(points_border))
    println("#points b+i ", length(points_border) + length(points_border))
    return points_inside, points_inside, points_inside
end


