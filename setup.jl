include("quadratic_koch.jl")
include("lattice_bfs.jl")
include("lattice_traverse.jl")


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


################
### plotting ###
################


function make_and_plot_fractal(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_corners(level, square)
    frac_points = fill_edges(frac_corners, n_between)

    plt.title(string("Level:", level))
    plt.plot(first.(frac_points), last.(frac_points))
    plt.savefig(string("quad_koch_level", level,".pdf"))
    plt.show()
end


function make_and_plot_fractal_on_lattice(level, n_between)
    square = gen_initial_square(level, n_between)
    frac_corners = gen_corners(level, square)
    frac_points = fill_edges(frac_corners, n_between)
    lattice = make_lattice(frac_points)
    points_inside, points_outside, points_border = arrayify(lattice)

    plt.title(string("Level:", level, "grid constant:", n_between))
    plt.plot(first.(points_inside), last.(points_inside), ".", color="green", label="INSIDE")
    plt.plot(first.(points_outside), last.(points_outside), ".", color="blue", label="OUTSIDE")
    plt.plot(first.(points_border), last.(points_border), ".", color="red", label="BORDER")
    plt.plot(first.(frac_points), last.(frac_points), label="fractal")
    plt.legend()
    plt.savefig(string("quad_koch_on_lattice_level", level, "grid_const", n_between,".pdf"))
    plt.show()
end


if PROGRAM_FILE == basename(@__FILE__)
    make_and_plot_fractal(3, 0)
    make_and_plot_fractal_on_lattice(3, 2)
end


