function *(C::CauchyTransform,domain::Jacobi)
    a = domain.GD.D.a
    b = domain.GD.D.b
    α = domain.α
    β = domain.β
    gd = JacobiMappedInterval(a,b,α,β)
    range = Hardy(Exterior(gd)) # Just to ensure the right weight is encoded
    ConcreteOperator(domain,range,BasicBandedOperator{ℕ₊,ℕ₊}(0,0, (i,j) -> i == j && i >= 0 ? complex(1.0) : 0.0im ))
end

function dist(z,n) # check if inside Bernstein ellipse that tends to
    # [-1,1] as n -> ∞
    ρ = 1 + 0.5/n
    a = (ρ+1/ρ)/2.0
    b = (ρ-1/ρ)/2.0
    if real(z)^2/a^2 + imag(z)^2/b^2 <= 1
        return 1
    else
        return 0
    end
end

@memoize function cauchy(a,b,seed,n,z::Number)
    if  dist(z,n) == 0   # the criterion for changing.
        # Non-adaptive method
        m = 16; #over sampling, should be done adaptively
        err = 1
        while err > 1e-15
            m *= 2
            c = fill(0.0im,m)
            c[1] = 1.0/(2im*pi)
            ldiv!(jacobi(a,b,m-1) - complex(z)*I,c)
            #c = ((jacobi(a,b,m-1) - complex(z)*I)\v)
            err = maximum(abs.(c[end-3:end]))
        end
        if m < n + 1
            append!(c,zeros(n + 10 - m))
        end
        # Adaptive method
        #println("eval off")
        #c = cauchy_off(a,b,n,z)
    else
        c = fill(0.0im,n+3)
        c[1] = seed(z);
        Z = complex(z)
        c[2] = Z*c[1] - a(0)*c[1] + 1/(2im*pi)
        c[2] = c[2]/b(0)
        for j = 1:n-1 # compute c_n
            c[j+2] = Z*c[j+1] - a(j)*c[j+1] - b(j-1)*c[j]
            c[j+2] /= b(j)
        end
    end
    c[1:n+1] 
end

function cauchy(a,b,seed,n,z::Vector)  # vectorize!
    A = zeros(ComplexF64,length(z),n+1)
    for i = 1:length(z)
        A[i,:] = cauchy(a,b,seed,n,z[i])
    end
    A
    #vcat(map(zz -> cauchy(a,b,seed,n,zz) |> transpose, z)...)
end