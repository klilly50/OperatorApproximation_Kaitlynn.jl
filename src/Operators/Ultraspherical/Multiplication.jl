function *(M::Multiplication,sp::Ultraspherical)
    if typeof(M.f) <: Function
        a = sp.GD.D.a
        b = sp.GD.D.b
        GD = UltraMappedInterval(a,b,0.0)
        ff = BasisExpansion(M.f,Ultraspherical(0.0,GD)) |> chop
    else 
        ff = M.f
    end
    
    if typeof(ff.basis) <: Ultraspherical && ff.basis.GD.D == sp.GD.D
        a, b = Jacobi_ab(ff.basis.λ - 1/2,ff.basis.λ - 1/2)
        α, β = Jacobi_ab(sp.λ - 1/2,sp.λ - 1/2)
        f = n -> OPMultiplication(a,b,α,β,ff.c,sparse(I,n,n))[1:n,1:n] |> sparse
        m = length(ff.c)
        Op = SemiLazyBandedOperator{ℕ₊,ℕ₊}(m,m,f,f(5))
    else 
        1 + 1 #TODO: just evaluate and expand, need transform
    end
    ConcreteOperator(sp,sp,Op)
end