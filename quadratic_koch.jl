import PyPlot
plt = PyPlot

len = 10
side = [(1,1), (1+len,1)]

function generator(side)
    """ performs on generate step on a side of the fractal """
    a = side[1]
    b = side[2]
    len = sqrt((a[1]-b[1])^2 + (a[2]-b[2])^2)/4

    # Generate six corners, c, d, e, f, g, h
    # return resulting corners
    if a[1] == b[1]
        # vertical line
        c = (a[1], a[2] + len)
        d = (c[1] - len, c[2])
        e = (d[1], d[2] + len)
        f = (e[1] + 2*len, e[2])
        g = (f[1], f[2] + len)
        h = (g[1] - len, g[2])
        corners = [a, c, d, e, f, g, h, b]
        return corners
    elseif a[2] == b[2]
        # horisontal line
        c = (a[1] + len, a[2])
        d = (c[1], c[2] + len)
        e = (d[1] + len, d[2])
        f = (e[1], e[2] - 2*len)
        g = (f[1] + len, f[2])
        h = (g[1], g[2] + len)
        corners = [a, c, d, e, f, g, h, b]
        return corners
    end
end

side = generator(side)
println(side)

side_col = collect(zip(side...))
x = side_col[1]
y = side_col[2]

plt.plot(x, y)
plt.show()


