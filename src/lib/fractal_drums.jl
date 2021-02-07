module fractal_drums

using PyPlot

include("quadratic_koch.jl")
using .quad_koch

include("lattice_bfs.jl")
using .lattice_bfs

include("laplacian_stensils.jl")
using .laplacian_stensils


export gen_quad_koch, make_and_plot_fractal
export make_lattice, arrayify
export five_point_laplacian, nine_point_laplacian
export make_and_plot_fractal_on_lattice


function make_and_plot_fractal_on_lattice(level, n_between)
    frac_points = gen_quad_koch(level, n_between)
    lattice = make_lattice(frac_points)
    points_inside, points_outside, points_border = arrayify(lattice)

    title(string("Level:", level, "grid constant:", n_between))
    plot(first.(points_inside), last.(points_inside), ".", color="green", label="INSIDE")
    plot(first.(points_outside), last.(points_outside), ".", color="blue", label="OUTSIDE")
    plot(first.(points_border), last.(points_border), ".", color="red", label="BORDER")
    plot(first.(frac_points), last.(frac_points), label="fractal")
    legend()
    #savefig(string("quad_koch_on_lattice_level", level, "grid_const", n_between,".pdf"))
    show()
end


if PROGRAM_FILE == basename(@__FILE__)
    make_and_plot_fractal(3, 0)
    make_and_plot_fractal_on_lattice(3, 2)
end


end
