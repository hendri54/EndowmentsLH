# Beta marginal distribution

"""
	$(SIGNATURES)

Constructor for `BetaMarginal`.
"""
function BetaMarginal(lb :: T1, ub :: T1, alpha :: T1, beta :: T1) where 
    T1 <: AbstractFloat

    betaDistr = Distributions.Beta(alpha, beta);
    return BetaMarginal(lb, ub, betaDistr);
end

draw_test_endowments(m :: BetaMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    lb(m) .+ (ub(m) .- lb(m)) .* rand(rng, m.betaDistr, n);

validate_draws(m :: BetaMarginal{T1}, x :: AbstractVector{T1})  where T1 =
    validate_bounded_draws(m, x);

marginal_quantile(m :: BetaMarginal{T1}, pct) where T1 =
    lb(m) .+ (ub(m) .- lb(m)) .* quantile.(m.betaDistr, pct);

# ----------