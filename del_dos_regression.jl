# Scaling of density of states, should scale as omega^d
# Find estimate for d

using CurveFit

"""
    Don't think I have understood this. Both function yield weird results.
"""

function get_N(omg, eigvals)
    return length(eigvals[eigvals. < omg])
end


function delta_N(eigvals, level)
    frac_area = 4^(2*(level-1))
    #IDOS = zeros(length(eigvals))
    IDOS = collect(1:1:length(eigvals))
    @assert(length(IDOS) == length(eigvals))
    delta_IDOS = (frac_area/(4*pi))* (eigvals .^ 2) - IDOS
    plt.plot(eigvals, delta_IDOS)
    plt.show()
end


function deldos_fit(eigvals, level)
    """ Estimates d, assumes sorted eigenvalues """
    min_eigval = eigvals[1]
    max_eigval = eigvals[end]
    interval = (max_eigval - min_eigval)/100
    aomegas = collect(min_eigval:interval:max_eigval)
    Ns = zeros(length(aomegas))

    for (idx, aomg) in enumerate(aomegas)
        Ns[idx] = length(eigvals[eigvals .< aomg])
    end

    area = 4^(2*(level-1))
    del_dos = (area/(4*pi))*aomegas.^2 - Ns
    #fit = curve_fit(PowerFit, aomegas, del_dos)
    fit = "TEHEE"
    print("a*omega^d, a and d are: ", fit)
    plt.plot(aomegas, del_dos, label="d_dos")
    plt.plot(aomegas, Ns, label="Ns")
    plt.plot(aomegas, aomegas.^(3/2), label="lol")
    plt.legend()
    plt.show()
    return fit
end
