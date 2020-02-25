# Scaling of density of states, should scale as omega^d
# Find estimate for d

using CurveFit


function delta_N(eigvals, level, lpps, n_inside)
    aomegas = sqrt.(eigvals)

    println("IDOS:")

    frac_area = n_inside # (4^(2*(level-1)))*4*(lpps+1)^2
    delta_N = zeros(length(aomegas))

    for (idx, val) in enumerate(aomegas)
        delta_N[idx] = frac_area*val^2/(4*pi) - length(aomegas[aomegas .< val])
        println(val)
    end


    fit = curve_fit(PowerFit, aomegas, delta_N)
    println("Estimate for d: ", fit.coefs[2])
    plt.plot(aomegas, delta_N, ".")
    plt.plot(aomegas, fit.(aomegas))
    plt.show()
end


