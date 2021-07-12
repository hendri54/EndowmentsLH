## --------  Marginal distributions

"""
	$(SIGNATURES)

Abstract type for marginal distributions of endowments.
"""
abstract type AbstractMarginal{T1} end

"""
	$(SIGNATURES)

Marginal distribution that is Uniform[0, 1].
"""
struct PercentileMarginal{T1 <: Real} <: AbstractMarginal{T1} end

"""
	$(SIGNATURES)

Uniform marginal distribution over fixed bounds.
"""
struct UniformMarginal{T1 <: Real} <: AbstractMarginal{T1}
	lb :: T1
	ub :: T1
end

"""
	$(SIGNATURES)

Normal(mean, std) marginal. Should store the Normal object +++
"""
struct NormalMarginal{T1 <: Real} <: AbstractMarginal{T1}
	mean :: T1
	std :: T1
end


"""
	$(SIGNATURES)

LogNormal(mean, std) marginal with offset `lb`. Should store the Normal object +++
"""
struct LogNormalMarginal{T1 <: Real} <: AbstractMarginal{T1}
	lb :: T1
	mean :: T1
	std :: T1
end


"""
	$(SIGNATURES)

Beta marginal distribution. Characterized by lower bound, upper bound, and Beta parameters alpha and beta.
"""
struct BetaMarginal{T1} <: AbstractMarginal{T1}
	lb :: T1
	ub :: T1
	betaDistr :: Distributions.Beta{T1}
end


"""
	$(SIGNATURES)

Bounded marginal with unkown distribution.
"""
struct BoundedMarginal{T1} <: AbstractMarginal{T1}
	lb :: T1
	ub :: T1
end

"""
	$(SIGNATURES)

Marginal with unknown distribution and no bounds.
"""
struct UnboundedMarginal{T1} <: AbstractMarginal{T1} end


"""
	$(SIGNATURES)

Fallback marginal for cases where no automatic checking of endowments takes place.
"""
struct UnknownMarginal{T1} <: AbstractMarginal{T1} end


## --------  Endowment info

"""
	$(SIGNATURES)

Meta information about one endowment. Contains a name, label, and its marginal distribution.

# Example
```
e = Endowment(:afqt, "Test score", PercentileMarginal{Float64}())
```
"""
struct Endowment{T1}
	name :: Symbol
	label :: String
	marginal :: AbstractMarginal{T1}
end


## ---------  EndowmentDraws

struct EndowmentDraws
	meta :: Vector{Endowment}
	draws :: DataFrame
end


# ------------