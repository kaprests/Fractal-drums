import PyPlot
plt = PyPlot


#############################
### Generate Koch fractal ###
#############################


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


function gen_corners(level, corners)
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
        gen_corners(level, corners)
    end
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


function gen_quad_koch(level, e_fill)
    initial_square = gen_initial_square(level, e_fill)
    frac_corners = gen_corners(level, initial_square)
    frac_points = fill_edges(frac_corners, e_fill)
    return frac_points
end


####################
### Plot fractal ###
####################


function make_and_plot_fractal(level, n_between=0)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_corners(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    plt.plot(first.(frac_points), last.(frac_points))
    plt.show()
end


if PROGRAM_FILE == basename(@__FILE__)
    make_and_plot_fractal(3)
end


