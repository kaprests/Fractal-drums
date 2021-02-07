# Scaling of density of states, should scale as omega^d
# Find estimate for d

using CurveFit
using DelimitedFiles
using PyPlot


function delta_N(eigvals, n_inside, level, grid_res)
    """ Regression for scaling of IDOS """
    aomegas = sqrt.(eigvals)
    frac_area = n_inside
    delta_N = zeros(length(aomegas))

    for (idx, val) in enumerate(aomegas)
        delta_N[idx] = frac_area*val^2/(4*pi) - length(aomegas[aomegas .< val])
    end

    fit = curve_fit(PowerFit, aomegas, delta_N)
    println("Estimate for d: ", fit.coefs[2])
    plt.plot(aomegas, delta_N, ".")
    plt.plot(aomegas, fit.(aomegas), label=string("level: ", Int(level), ", grid_res: ", Int(grid_res)))
    plt.legend()
    plt.savefig("idos.pdf")
end


########################
### Investigate IDOS ###
########################

### Read eigenvalues from files ###
num_files = length(readdir("../../eigenvalues"))
eig_matrix = zeros(num_files, 1000)

for (idx, filename) in enumerate(readdir("../../eigenvalues"))
    filename = string("../../eigenvalues/", filename)
    level = readdlm(filename, '\n')[1]
    grid_res = readdlm(filename, '\n')[2]
    num_inside = readdlm(filename, '\n')[3]
    eigvals = readdlm(filename, '\n')[4:end]
    delta_N(eigvals, num_inside, level, grid_res)
end


plt.show()
