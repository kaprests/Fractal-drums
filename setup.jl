include("quadratic_koch.jl")
include("lattice_bfs.jl")
include("lattice_traverse.jl")

@enum Location INSIDE OUTSIDE BORDER

struct Point
    x::Int
    y::Int
    location::Location
end


#################################
### functions for "exporting" ###
#################################


function gen_quadkoch(level, e_fill)
    initial_square = gen_initial_square(level, e_fill)
    frac_corners = gen_corners(level, initial_square)
    frac_points = fill_edges(frac_corners, e_fill)
    lattice = make_lattice(frac_points)
    return lattice, frac_points
end


#################
### plottingi ###
#################


function make_and_plot_fractal(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_corners(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    plt.plot(first.(frac_points), last.(frac_points))
    plt.show()
end


function make_and_plot_fractal_on_lattice(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_corners(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    lattice = make_lattice(frac_points)
    points_inside, points_outside, points_border = arrayify(lattice)

    plt.plot(first.(points_inside), last.(points_inside), ".", color="green", label="INSIDE")
    plt.plot(first.(points_outside), last.(points_outside), ".", color="blue", label="OUTSIDE")
    plt.plot(first.(points_border), last.(points_border), ".", color="red", label="BORDER")
    plt.plot(first.(frac_points), last.(frac_points), label="fractal")
    plt.legend()
    #plt.savefig("quad_koch_on_lattice_level1.pdf")
    plt.show()
end


if PROGRAM_FILE == basename(@__FILE__)
    make_and_plot_fractal(2, 1)
    make_and_plot_fractal_on_lattice(2, 0)
end


