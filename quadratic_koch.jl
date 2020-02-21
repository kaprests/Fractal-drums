import PyPlot
plt = PyPlot


### Generate Koch fractal
###########################################################################
function generate_side(side)
    """ performs one generate step on a side of the fractal """
    a = side[1]
    b = side[2]
    #len = max(abs(b[1]-a[1]), abs(b[2]-a[2]))
    len = sqrt((a[1]-b[1])^2 + (a[2]-b[2])^2)/4
    # Generate six corners, c, d, e, f, g, h
    # return resulting corners
    if a[1] == b[1]
        # vertical line
        if a[2] < b[2]
            c = (a[1], a[2] + len)
            d = (c[1] - len, c[2])
            e = (d[1], d[2] + len)
            fm = (e[1] + len, e[2])
            f = (fm[1] + len, fm[2])
            g = (f[1], f[2] + len)
            h = (g[1] - len, g[2])
        else
            c = (a[1], a[2] - len)
            d = (c[1] + len, c[2])
            e = (d[1], d[2] - len)
            fm = (e[1] - len, e[2])
            f = (fm[1] - len, fm[2])
            g = (f[1], f[2] - len)
            h = (g[1] + len, g[2])
        end
        corners = [a, c, d, e, fm, f, g, h, b]
        return corners
    elseif a[2] == b[2]
        # horisontal line
        if a[1] < b[1]
            c = (a[1] + len, a[2])
            d = (c[1], c[2] + len)
            e = (d[1] + len, d[2])
            fm = (e[1], e[2] - len)
            f = (fm[1], fm[2] - len)
            g = (f[1] + len, f[2])
            h = (g[1], g[2] + len)
        else
            c = (a[1] - len, a[2])
            d = (c[1], c[2] - len)
            e = (d[1] - len, d[2])
            fm = (e[1], e[2] + len)
            f = (fm[1], fm[2] + len)
            g = (f[1] - len, f[2])
            h = (g[1], g[2] - len)
        end
        corners = [a, c, d, e, fm, f, g, h, b]
        return corners
    end
end


function gen_frac(level, corners)
    """ Recursively generates fractal from given initial shape and recursion depth level """
    println("LEVEL: ", level)
    if level == 0
        corners = unique(corners)
        x, y = first.(corners), last.(corners)
        min_val = min(corners...)[1] -1
        x .-= min_val 
        y .-= min_val
        corners = collect(zip(x, y))
        return corners
    else
        num_corners = size(corners, 1)
        sides = Array{Array, 1}(undef, length(corners))
        for i in 1:num_corners
            if i < num_corners
                a = corners[i]
                b = corners[i+1]
                sides[i] = generate_side([a, b])
            else
                sides[i] = reverse(generate_side([corners[1], corners[end]]))
            end
        end
        corners = collect(Base.Iterators.flatten(sides))
        level -= 1
        gen_frac(level, corners)
    end
end


function gen_initial_square(level, n_between)
    side_length = (4^(level))*(1 + n_between)
    min = 1
    max = side_length+min
    a = (min, min)
    b = (max, min)
    c = (max, max)
    d = (min, max)
    return [a, b, c, d]
end


function fill_edges(frac_corners, n_between)
    n_corners = length(frac_corners)
    n_fill = n_corners * n_between
    n_tot = n_corners + n_fill
    frac_points = Array{Tuple}(undef, n_tot)

    counter = 1
    for i in 1:n_corners
        x1, y1 = frac_corners[i]
        x2, y2 = frac_corners[1]
        try
            x2, y2 = frac_corners[i+1]
        catch
            println("end")
        end
        x_shift = (x2 - x1)/(n_between+1)
        y_shift = (y2 - y1)/(n_between+1)
        p1 = (x1, y1)
        f_index = i + n_between*(i-1)
        frac_points[f_index] = p1

        for j in 1:n_between
            frac_points[f_index+j] = (x1+j*x_shift, y1+j*y_shift)
        end
    end
    return frac_points
end


###########################################################################


### Lattice creation
###########################################################################



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
        lattice[Int(coord[1]), Int(coord[2])]=is_enclosed(coord, min_frac, max_frac, frac_points, lat_const)
    end
    return x_lat, y_lat, lattice
end


function make_lattice(frac_points)
    x = first.(frac_points)
    N = Int(max(x...))
    lattice = fill(OUTSIDE, (N, N))

    for point in frac_points
        lattice[Int(point[1]), Int(point[2])] = BORDER
    end

    # Center is INSIDE, always
    x0 = y0 = Int((N+1)/2)
    center = (x0, y0)
    lattice[x0, y0] = INSIDE

    # neares neighbours of center
    left = (x0 - 1, y0)
    right = (x0 + 1, y0)
    down = (x0, y0 - 1)
    up = (x0, y0 + 1)

    points = [left, right, down, up]
    println("begin search")
    for point in points
        x, y = point
        if lattice[x, y] == OUTSIDE
            # New INSIDE point
            println("inside")
            lattice[x, y] = INSIDE
            
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
    myst = []
    for (idx, p) in enumerate(CartesianIndices(lattice))
        if lattice[p] == BORDER
            push!(border, (p[1], p[2]))
        elseif lattice[p] == OUTSIDE
            push!(outside, (p[1], p[2]))
        elseif lattice[p] == INSIDE
            push!(inside, (p[1], p[2]))
        end
    end
    return inside, outside, border
end


function gen_lattice_points(frac_points)
    """ Generates the coordinates of the lattice points """
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
    lattice_points = collect(zip(x_lat, y_lat)) # List of coordinates as tuples

    return x_lat, y_lat, lattice_points
end


###########################################################################


### Functions for testing and plotting
###########################################################################


function make_and_plot_lattice(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_frac(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    
    lattice = make_lattice(frac_points)
    println("Lattice made, prep for plot")
    inside, outside, border = arrayify(lattice)
    
    println("Plotting")
    plt.plot(first.(inside), last.(inside), ".", color="green", label="inside")
    plt.plot(first.(outside), last.(outside), ".", color="gray", label="outside")
    plt.plot(first.(border), last.(border), "^", color="red", label="border")
    plt.legend()
    plt.show()
end


function make_and_plot_fractal(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_frac(level, square)
    frac_points = fill_edges(frac_points, n_between)
    plt.plot(first.(frac_points), last.(frac_points))
    plt.show()
end


function make_and_plot_fractal_on_lattice(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_frac(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    #x_lattice, y_lattice, lattice = gen_lattice(frac_points)
    #points_INSIDE, points_OUTSIDE, points_BORDER = get_location_points(lattice)

    x_lat, y_lat, lattice_points = gen_lattice_points(frac_points)
    lattice = gen_lattice_bfs(frac_points, lattice_points)
    points_INSIDE, points_OUTSIDE, points_BORDER = get_location_points(lattice)

    plt.plot(first.(points_INSIDE), last.(points_INSIDE), ".", color="green", label="INSIDE")
    plt.plot(first.(points_OUTSIDE), last.(points_OUTSIDE), ".", color="blue", label="OUTSIDE")
    plt.plot(first.(points_BORDER), last.(points_BORDER), ".", color="red", label="BORDER")
    plt.plot(first.(frac_points), last.(frac_points), label="fractal")
    plt.legend()
    #plt.savefig("quad_koch_on_lattice_level1.pdf")
    plt.show()
end


###########################################################################


### functions for "exporting"
###########################################################################


function gen_quadkoch(level, e_fill)
    initial_square = gen_initial_square(level, e_fill)
    frac_corners = gen_frac(level, initial_square)
    frac_points = fill_edges(frac_corners, e_fill)
    x_lattice, y_lattice, lattice_points = gen_lattice_points(frac_points)

    lattice = make_lattice(frac_points)
    println("Lattice made, prep for plot")
    return lattice, frac_points
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
###########################################################################


#make_and_plot_fractal(2, 2)
#make_and_plot_fractal_on_lattice(2, 1)
#test_new_lattice(4,0)


