import PyPlot
plt = PyPlot


function generate_side(side)
    """ performs one generate step on a side of the fractal """
    a = side[1]
    b = side[2]
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
        return corners
    else
        num_corners = size(corners, 1)
        sides = []
        #sides = Array{Array{Tuple{Real, Real}}}(undef, 4)
        for i in 1:num_corners
            if i < num_corners
                a = corners[i]
                b = corners[i+1]
                append!(sides,generate_side([a, b]))
            else
                append!(sides, reverse(generate_side([corners[1], corners[end]])))
            end
        end
        corners = sides
        level -= 1
        println("RECURSIVE CALL")
        gen_frac(level, corners)
    end
end


function plot_fractal(points)
    """ Takes a list of tuples as x,y-pairs and plots """
    println("prepare for plotting")
    num_points = size(points, 1)
    x = zeros(num_points)
    y = zeros(num_points)
    for i in 1:num_points
        x[i] = points[i][1]
        y[i] = points[i][2]
    end
    println("plotting")
    plt.plot(x, y)
    plt.show()
end


function plotify(points)
    """ prepare for plotting """
    num_points = size(points, 1)
    x = zeros(num_points)
    y = zeros(num_points)
    for i in 1:num_points
        x[i] = points[i][1]
        y[i] = points[i][2]
    end   
    return x, y
end


function test()
    println("Definging test data")
    level = 3
    len = 10
    side = [(1,1), (1+len,1)]
    corners = [(1,1), (1+len, 1), (1+len, 1+len), (1, 1+len)]
    #corners = [(1,1), (1+len, 1)]
    println("Calling rec func")
    frac_points = gen_frac(level, corners)
    plot_fractal(frac_points)
end


#test()
