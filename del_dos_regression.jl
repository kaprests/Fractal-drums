# Scaling of density of states, should scale as omega^d
# Find estimate for d

using CurveFit


function deldos_fit(eigvals)
    """ Estimates d, assumes sorted eigenvalues """
    min_eigval = eigvals[1]
    max_eigval = eigvals[end]
    interval = (max_eigval-min_eigval)/1000
    # a*omega
    aomegas = collect(min_eigval:interval:max_eigval)
    Ns = zeros(length(aomegas))
    for (idx, aomg) in enumerate(aomegas)
        #N = length(eigvals[eigvals .< aomg])
        N = sum(eigvals[eigvals .< aomg])
        Ns[idx] = N
    end
    del_dos = 10*aomegas.^2 - Ns .+ 10
    #println(repr(aomegas))
    println(length(Ns) == length(aomegas))
    fit = curve_fit(PowerFit, aomegas, Ns)
    print("a*omega^d, a and d are: ", fit)
    plt.plot(aomegas, Ns, label="Ns")
    #plt.plot(aomegas, del_dos, label="ddos")
    #plt.plot(aomegas, aomegas.^(3/2), label="lol")
    plt.legend()
    plt.show()
    return fit
end
