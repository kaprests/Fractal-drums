include("quadratic_koch.jl")

level = 3
lattice, x_lat, y_lat, frac = gen_quadkoch(level)
xi, yi, xo, yo, xb, yb = get_location_points(lattice)


plt.plot(xi, yi, ".", color="green")
plt.plot(xo, yo, ".", color="red")
plt.plot(xb, yb, ".", color="blue")
plt.plot(first.(frac), last.(frac))
plt.show()
