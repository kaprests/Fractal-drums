import PyPlot
plt = PyPlot

include("quadratic_koch.jl")


level = 1
L = 5 # fractal side length
corners = [(1,1), (1+L, 1), (1+L, 1+L), (1, 1+L)]
frac_points = gen_frac(level, corners)
x_frac, y_frac = plotify(frac_points)


@enum Location inside outside border


struct Point
    x::Real
    y::Real
    location::Location
end


function traverse(x, upper)
    if x < upper/2
        x -= 1
    else
        x += 1
    end
end


function is_enclosed(p::Tuple, lower, upper, frac_points, lat_const)
    """ Chech if arbitrary point is inside, on or outside of fractal """
    x = p[1]
    x_walker = p[1]
    y = p[2]

    if (x, y) in frac_points
        # Point on border, not inside fractal
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
                elseif border_next[2] > border[2] && border_prev[1] > border[1]
                    # next border is up, and prev is right
                    return Point(x, y, inside)
                elseif border_next[2] > border[2] && border_prev[2] < border[2]
                    # next is up prev is down
                    return Point(x, y, inside)
                else
                    return Point(x, y, outside)
                end
            end
        end
        return Point(x, y, outside)
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
                elseif border_next[1] < border[1] && border_prev[2] > border[2]
                    # next border is left, prev is up
                    return Point(x, y, inside)
                elseif border_next[2] < border[2] && border_prev[2] > border[2]
                    # next is down, prev is up
                    return Point(x, y, inside)
                else
                    return Point(x, y, outside)
                end
            end
        end
        return Point(x, y, outside)
    end
end


function is_enclosed2()
    """ Chech if arbitrary point is inside, on or outside of fractal, alternate method """
end


function determine_point_locations(frac_points, lattice_points)
    """
    Given all lattice point coordinates and fractal coordinates, determines wether every point is
    inside, on or outside of the fractal
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
    x, y = plotify(coords)
    println(summary(x))
    return x_lat, y_lat, lattice
end

x_lattice, y_lattice, lattice = gen_lattice(x_frac, y_frac, frac_points)

num_inside = 0
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
println("Points inside fractal: ", length(x_inside))

plt.plot(x_inside, y_inside, ".", color="green", label="inside")
plt.plot(x_border, y_border, "v", color="red", label="on fractal border")
plt.plot(x_outside, y_outside, ".", color="blue", label="outside")
plt.plot(x_frac, y_frac, label="fractal")
plt.legend()
plt.savefig("quad_koch_on_lattice_level1.pdf")
plt.show()

