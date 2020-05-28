module EndowmentsLH

using ArgCheck, DocStringExtensions, Random
using DataFrames
using CommonLH

include("types.jl");
include("marginals.jl")
include("endowment.jl")
include("endowment_draws.jl")

# Endowment
export AbstractMarginal, UniformMarginal, NormalMarginal, BoundedMarginal, UnboundedMarginal, PercentileMarginal, UnknownMarginal
export Endowment
export label, name, marginal, validate_draws

# EndowmentDraws
export EndowmentDraws
export validate_draws, add_draws!, replace_draws!, select_rows, get_draws, get_label, get_meta, has_endowment, type_endowments

end # module
