import PyPlot
plt = PyPlot


@enum Location inside outside border

### Refactoring of lattice creation
### Represent lattice by a normal 2D array
############################################################################
function make_lattice(level, frac_points, defloc=outside)
    side_length = (4^(level) + 1) 
    lattice = fill(defloc, (side_length, side_length))
    min = -minimum(first.(frac_points)) + 10
    println(min)

    for (x, y) in frac_points
        lattice[convert(Int, x), convert(Int, y)] = border
    end

    return lattice
end


function arrayify(lattice)
    """ Make arrays from lattice cartesian indices """
    #len = length(lattice[1,:])^2
    #x = zeros(len)
    #y = zeros(len)
    x = []
    y = []
    for (idx, p) in enumerate(CartesianIndices(lattice))
        #x[idx] = p[1]
        #y[idx] = p[2]
        if lattice[p] == border
            push!(x, p[1])
            push!(y, p[2])
        end
    end
    return x, y
end
###########################################################################


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
        println("Returned corners: ", summary(corners))
        return unique(corners)
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


function gen_initial_square(level)
    side_length = 4^(level)
    min = 1
    max = side_length+min
    a = (min, min)
    b = (max, min)
    c = (max, max)
    d = (min, max)
    return [a, b, c, d]
end


###########################################################################


### Lattice creation
###########################################################################
struct Point
    x::Real
    y::Real
    location::Location
end


### TODO: implement, test and compare another method
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

    if (x, y) in frac_points
        # Point on border, not inside fractal
        push!(determined_points, p)
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
                border_next = frac_points[idx+1]
                border_prev = frac_points[idx-1]
                if border_next[1] > border[1] && border_prev[2] < border[2]
                    # next border is right and border_prev is down
                    return Point(x, y, inside)
                    # return determined_points, inside
                elseif border_next[2] > border[2] && border_prev[1] > border[1]
                    # next border is up, and prev is right
                    return Point(x, y, inside)
                    # return determined_points, inside
                elseif border_next[2] > border[2] && border_prev[2] < border[2]
                    # next is up prev is down
                    return Point(x, y, inside)
                    # return determined_points, inside
                else
                    return Point(x, y, outside)
                    # return determined_points, outside
                end
            else
                push!(determined_points, (x_walker, y))
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
                border_next = frac_points[idx+1]
                border_prev = frac_points[idx-1]
                if border_next[2] < border[2] && border_prev[1] < border[1]
                    # next border is down, prev is left
                    return Point(x, y, inside)
                    # return determined_points, inside
                elseif border_next[1] < border[1] && border_prev[2] > border[2]
                    # next border is left, prev is up
                    return Point(x, y, inside)
                    # return determined_points, inside
                elseif border_next[2] < border[2] && border_prev[2] > border[2]
                    # next is down, prev is up
                    return Point(x, y, inside)
                    # return determined_points, inside
                else
                    return Point(x, y, outside)
                    # return determined_points, outside
                end
            else
                push!(determined_points, (x_walker, y))
            end
        end
        return Point(x, y, outside)
        # return determined_points, outside
    end
end


function determine_point_locations(frac_points, lattice_points)
    """
    Given all lattice point coordinates and fractal coordinates, determines wether every point is
    inside, on or outside of the fractal

    possible canidate for different method for checking points location:
    Breadth-first search like method
    """
    center = lattice_points[convert(Int, round(end/2))]
end


function gen_lattice(x, y, frac_points)
    lat_const = x[2] - x[1]
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
        lattice[i]=is_enclosed(coord, min_frac, max_frac, frac_points, lat_const)
    end

    println(summary(coords))
    x, y = first.(coords), last.(coords)
    println(summary(x))
    return x_lat, y_lat, lattice
end


###########################################################################


### Executing functions
###########################################################################
function fractal_exec()
    println("Definging test data")
    level = 2
    corners = gen_initial_square(level)
    frac_points = gen_frac(level, corners)
    plot_fractal(frac_points)
end


function fractal_ref_exec(level)
    square = gen_initial_square(level)
    println(square)
    frac_points = gen_frac(level, square)
    lattice = make_lattice(level, frac_points)
    x, y = arrayify(lattice)
    plt.plot(x, y, ".")
    plt.show()
end


function get_location_points(lattice)
""" extracts arrays with the different locations """
    x_inside = []
    y_inside = []
    x_border = []
    y_border = []
    x_outside = []
    y_outside = []
    for point in lattice
        if point.location == inside
            push!(x_inside, point.x)
            push!(y_inside, point.y)
        elseif point.location == border
            push!(x_border, point.x)
            push!(y_border, point.y)
        else
            push!(x_outside, point.x)
            push!(y_outside, point.y)
        end
    end
    println("#points inside: ", length(x_inside))
    return x_inside, y_inside, x_outside, y_outside, x_border, y_border
end


function fractal_lattice_excec(level)
    corners = gen_initial_square(level)
    frac_points = gen_frac(level, corners)
    x_frac, y_frac = first.(frac_points), last.(frac_points)
    x_lattice, y_lattice, lattice = gen_lattice(x_frac, y_frac, frac_points)

    x_inside, y_inside, x_outside, y_outside, x_border, y_border = get_location_points(lattice)

    #println("#####################")
    #println(minimum(x_inside)/abs(x_inside[1]-x_inside[2]))
    #println(minimum(y_inside))
    #println("#####################")

    plt.plot(x_inside, y_inside, ".", color="green", label="inside")
    plt.plot(x_border, y_border, "v", color="red", label="on fractal border")
    plt.plot(x_outside, y_outside, ".", color="blue", label="outside")
    plt.plot(x_frac, y_frac, label="fractal")
    plt.legend()
    #plt.savefig("quad_koch_on_lattice_level1.pdf")
    plt.show()
end
###########################################################################


### functions for exporting
###########################################################################
function gen_quadkoch(level)
    initial_square = gen_initial_square(level)
    frac_points = gen_frac(level, initial_square)
    x_frac, y_frac = first.(frac_points), last.(frac_points)
    x_lattice, y_lattice, lattice = gen_lattice(x_frac, y_frac, frac_points)
    return lattice, x_lattice, y_lattice, frac_points
end
###########################################################################

#fractal_lattice_excec(2)
