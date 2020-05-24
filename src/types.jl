## --------  Marginal distributions

abstract type AbstractMarginal{T1} end

struct UniformMarginal{T1} <: AbstractMarginal{T1}
	lb :: T1
	ub :: T1
end

lb(u :: UniformMarginal{T1}) where T1  =  u.lb;
ub(u :: UniformMarginal{T1}) where T1  =  u.ub;


struct NormalMarginal{T1} <: AbstractMarginal{T1}
	mean :: T1
	std :: T1
end

mean(n :: NormalMarginal{T1}) where T1  =  n.mean;
std(n :: NormalMarginal{T1}) where T1  =  n.std;


## --------  Endowment info

struct Endowment{T1}
	name :: Symbol
	marginal :: AbstractMarginal{T1}
end


## ---------  EndowmentDraws

struct EndowmentDraws
	meta :: Vector{Endowment}
	draws :: DataFrame
end


# ------------