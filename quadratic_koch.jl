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



@enum Location inside outside border


struct Point
    x::Int
    y::Int
    location::Location
end


function is_enclosed(p::Tuple, lower, upper, frac_points, lat_const)
    """
    Chech if arbitrary point is inside, on or outside of fractal.
    Checks by traversing from the point til the border and determine
    inside/outside of fractal from the orientation of the curve.
    Checks if point is on border before traversing

    All points on the traverse path between the initial point and the
    border will have same location. Therfore it is not needed to 
    do this traverse check for every point.

    returns:
        determined_points: list of points (tuples)
        location: inside/outside/border
    """
    x = p[1]
    x_walker = p[1]
    y = p[2]

    determined_points = []
    #push!(determined_points, (x, y))

    if (x, y) in frac_points
        # Point on border, not inside fractal
        #return determined_points, border
        return Point(x, y, border)
    end
    
    if x > upper/2
        # Traverse right
        while x_walker < upper
            x_walker += lat_const
            if (x_walker, y) in frac_points
                # collision
                idx = findall(p->p==(x_walker, y), frac_points)[1]
                border = frac_points[idx]
                border_next = frac_points[1]
                border_prev = frac_points[end]
                try
                    border_next = frac_points[idx+1]
                    border_prev = frac_points[idx-1]
                finally
                end
                if border_next[1] > border[1] && border_prev[2] < border[2]
                    # next border is right and border_prev is down
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                elseif border_next[2] > border[2] && border_prev[1] > border[1]
                    # next border is up, and prev is right
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                elseif border_next[2] > border[2] && border_prev[2] < border[2]
                    # next is up prev is down
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                else
                    return Point(x, y, outside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, outside
                end
            else
                #push!(determined_points, (x_walker, y))
            end
        end
        return Point(x, y, outside)
        #return determined_points, outside
    else
        # Traverse right
        while x_walker > lower
            x_walker -= lat_const
            if (x_walker, y) in frac_points
                # collision
                idx = findall(p->p==(x_walker, y), frac_points)[1]
                border = frac_points[idx]
                border_next = frac_points[1]
                border_prev = frac_points[end]
                try
                    border_next = frac_points[idx+1]
                    border_prev = frac_points[idx-1]
                catch
                end
                if border_next[2] < border[2] && border_prev[1] < border[1]
                    # next border is down, prev is left
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                elseif border_next[1] < border[1] && border_prev[2] > border[2]
                    # next border is left, prev is up
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                elseif border_next[2] < border[2] && border_prev[2] > border[2]
                    # next is down, prev is up
                    return Point(x, y, inside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, inside
                else
                    return Point(x, y, outside)
                    #push!(determined_points, (x_walker, y))
                    #return determined_points, outside
                end
            else
                #push!(determined_points, (x_walker, y))
            end
        end
        return Point(x, y, outside)
        #return determined_points, outside
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

    println("Making lattice, checking for insiders")
    for (i, coord) in enumerate(coords)
        lattice[Int(coord[1]), Int(coord[2])]=is_enclosed(coord, min_frac, max_frac, frac_points, lat_const)
    end
    return x_lat, y_lat, lattice
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


function gen_lattice_bfs(frac_points, lattice_points)
    """
    Determines locations and creates lattice    

    Given all lattice point coordinates and fractal coordinates, determines wether every point is
    inside, on or outside of the fractal

    Breadth-first search like method
    """
    N = size(lattice_points, 1)
    #lattice = Array{Point}(undef, (N, N))
    lattice = fill(Point(0, 0, outside), (N, N))

    center = lattice_points[convert(Int, round(end/2))]
    x0, y0 = Int(center[1]), Int(center[2])
    lattice[x0, y0] = Point(x0, y0, inside)
    # neares neighbours of center
    left = (x0 - 1, y0)
    right = (x0 + 1, y0)
    down = (x0, y0 - 1)
    up = (x0, y0 + 1)

    
    points = [left, right, down, up]

    println("Starting search")
    for point in points
        x, y = point
        if !((x, y) in frac_points) && lattice[x, y] == Point(0, 0, outside)
            # New inside point
            lattice[x, y] = Point(x, y, inside)

            for nn in (-1, 1)
                    push!(points, (x + nn, y))
                    push!(points, (x, y + nn))
           end
        elseif (x, y) in frac_points
            lattice[x, y] = Point(x, y, border)
        end
    end
    return lattice
end


###########################################################################


### Functions for testing and plotting
###########################################################################


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
    #points_inside, points_outside, points_border = get_location_points(lattice)

    x_lat, y_lat, lattice_points = gen_lattice_points(frac_points)
    lattice = gen_lattice_bfs(frac_points, lattice_points)
    points_inside, points_outside, points_border = get_location_points(lattice)

    plt.plot(first.(points_inside), last.(points_inside), ".", color="green", label="inside")
    plt.plot(first.(points_outside), last.(points_outside), ".", color="blue", label="outside")
    plt.plot(first.(points_border), last.(points_border), ".", color="red", label="border")
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
    lattice = gen_lattice_bfs(frac_points, lattice_points)
    return lattice, x_lattice, y_lattice, frac_points
end


function get_location_points(lattice)
""" extracts arrays with the different locations """
    points_inside = []
    points_outside = []
    points_border = []

    for point in lattice
        if point.location == inside
            push!(points_inside, (point.x, point.y))
        elseif point.location == border
            push!(points_border, (point.x, point.y))
        else
            push!(points_outside, (point.x, point.y))
        end
    end
    println("#points inside: ", length(points_inside))
    println("#points on border ", length(points_border))
    println("#points b+i ", length(points_border) + length(points_inside))
    return points_inside, points_outside, points_border
end
###########################################################################


#make_and_plot_fractal(2, 2)
#make_and_plot_fractal_on_lattice(2, 1)





############################################################################
### Possible refactoring of lattice creation
### Represent lattice by a normal 2D array
############################################################################
"""
function make_lattice(level, frac_points, defloc=outside)
    side_length = Int(max(first.(frac_points)...))#(4^(level) + 1)
    println(max(first.(frac_points)...))
    println(min(first.(frac_points)...))
    lattice = fill(defloc, (side_length, side_length))
    for (x, y) in frac_points
        lattice[convert(Int, x), convert(Int, y)] = border
    end

    return lattice
end


function arrayify(lattice)
    x_in = []
    y_in = []
    x_out = []
    y_out = []
    x_border = []
    y_border = []
    for (idx, p) in enumerate(CartesianIndices(lattice))
        #x[idx] = p[1]
        #y[idx] = p[2]
        if lattice[p] == border
            push!(x_border, p[1])
            push!(y_border, p[2])
        elseif lattice[p] == outside
            push!(x_out, p[1])
            push!(y_out, p[2])
        else
            push!(x_in, p[1])
            push!(y_in, p[2])
        end
    end
    return x_in, y_in, x_border, y_border, x_out, y_out
end
"""
###########################################################################


