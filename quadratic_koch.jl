import PyPlot
plt = PyPlot


### Refactoring
############################################################################
@enum Location inside outside border


function make_lattice(level, frac_points, defloc=outside)
    side_length = (4^(level) + 1) + 100
    lattice = fill(defloc, (side_length, side_length))
    min = -minimum(first.(frac_points)) + 10

    for (x, y) in frac_points
        lattice[convert(Int, x+min), convert(Int, y+min)] = border
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


function plot_fractal(points)
    """ Takes a list of tuples as x,y-pairs and plots """
    println("plotting")
    plt.plot(first.(points), last.(points))
    plt.show()
end



function test()
    println("Definging test data")
    level = 2
    corners = gen_initial_square(level)
    frac_points = gen_frac(level, corners)
    plot_fractal(frac_points)
end


function test_ref()
    level = 3
    square = gen_initial_square(level)
    println(square)
    frac_points = gen_frac(level, square)
    lattice = make_lattice(level, frac_points)
    x, y = arrayify(lattice)
    plt.plot(x, y, ".")
    plt.show()
end


#test()
