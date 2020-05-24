module EndowmentsLH

using ArgCheck, DocStringExtensions, Random
using DataFrames
using CommonLH

include("types.jl");
include("endowment.jl")
include("endowment_draws.jl")

# Endowment
export AbstractMarginal, UniformMarginal, NormalMarginal
export Endowment
export name, marginal, validate_draws

# EndowmentDraws
export EndowmentDraws
export validate_draws, get_draws, get_meta, has_endowment, type_endowments

end # module
