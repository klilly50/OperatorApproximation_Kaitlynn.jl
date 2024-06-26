## Both CauchyTransform and CauchyOperator implemented here

function *(C::CauchyTransform,domain::Laurent)
    range = Hardy(Interior(domain.GD))
    Cp = ConcreteOperator(domain,range,BasicBandedOperator{ℤ,ℕ₊}(0,0, (i,j) -> i == j && i >= 0 ? complex(1.0) : 0.0im ))
    range = Hardy(Exterior(domain.GD))
    Cm = ConcreteOperator(domain,range,BasicBandedOperator{ℤ,ℕ₋}(0,0, (i,j) -> i == j && i < 0 ? complex(-1.0) : 0.0im ))
    Cp ⊘ Cm
end

function *(C::CauchyOperator,domain::Laurent)
    range = domain
    if C.o == 1.0
        return ConcreteOperator(domain,range,BasicBandedOperator{ℤ,ℤ}(0,0, (i,j) -> i == j && i >= 0 ? complex(1.0) : 0.0im ))
    elseif C.o == -1.0
        return Cm = ConcreteOperator(domain,range,BasicBandedOperator{ℤ,ℤ}(0,0, (i,j) -> i == j && i < 0 ? complex(-1.0) : 0.0im ))
    end
end