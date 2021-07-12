module EndowmentsLH

using ArgCheck, DocStringExtensions, Random
using DataFrames, Distributions, Statistics
using CommonLH

include("types.jl");
include("marginals.jl");
include("endowment.jl")
include("endowment_draws.jl")

# Endowment
export AbstractMarginal, UniformMarginal, LogNormalMarginal, NormalMarginal, BetaMarginal, BoundedMarginal, UnboundedMarginal, PercentileMarginal, UnknownMarginal
export Endowment
export label, name, isbounded, lb, ub, marginal, marginal_quantile, validate_draws

# EndowmentDraws
export EndowmentDraws
export validate_draws, add_draws!, replace_draws!, 
    select_rows, draw_fixed_percentiles, get_draws, endow_quantiles, 
    get_label, get_meta, has_endowment, type_endowments, 
    corr_matrix, formatted_corr_matrix

end # module
