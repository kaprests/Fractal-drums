import PyPlot
plt = PyPlot

include("quadratic_koch.jl")


level = 2
L = 5 # fractal side length
corners = [(1,1), (1+L, 1), (1+L, 1+L), (1, 1+L)]
frac_points = gen_frac(level, corners)
#plot_fractal(frac_points)
x_frac, y_frac = plotify(frac_points)


"""
struct Point
    x::Real
    y::Real
    lat_const::Real
    self_inside::Bool
    neighbours = []
end
"""


# determine lattice points
lat_const = x_frac[2] - x_frac[1]
# 10 chosen arbitrarily, should perhaps improve
lattice_vals = collect(min(x_frac...)-lat_const*2:lat_const:max(x_frac...)+lat_const*2)
L_lattice = size(lattice_vals, 1)
x_lattice = transpose(repeat(lattice_vals, 1, L_lattice))
y_lattice = repeat(lattice_vals, 1, L_lattice)
lattice_size = size(x_lattice, 1) * size(x_lattice, 2)

"""
lattice_coords = collect(zip(x_lattice, y_lattice))
lattice = Array{Point}(undef, (L_lattice, L_lattice))
for i in 1:size(lattice_coords, 1)
    is
    p = Point(lattice_coords[i][1], lattice_coords[i][1], false)
    if 
    lattice[i] = p 
end
"""


plt.plot(x_lattice, y_lattice, ".", color="blue")
plt.plot(x_frac, y_frac, "x", color="red")
plt.plot(x_frac, y_frac)
plt.show()


