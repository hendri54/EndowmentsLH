# ------  Access

name(e :: Endowment{T1}) where T1  =  e.name;
marginal(e :: Endowment{T1}) where T1  =  e.marginal;

validate_draws(e :: Endowment{T1}, x :: Vector{T1}) where T1  =
    validate_draws(marginal(e), x);

function validate_draws(u :: UniformMarginal{T1}, x :: Vector{T1})  where T1
    isValid = true;
    isValid = isValid  &&  check_float_array(x, lb(u), ub(u));
    return isValid
end

function validate_draws(nm :: NormalMarginal{T1}, x :: Vector{T1}) where T1
    isValid = true
    isValid = isValid && !any(isinf.(x));
    return isValid
end


# ------  For testing

draw_test_endowments(e :: Endowment{T1}, n, rng :: AbstractRNG) where T1  =
    draw_test_endowments(marginal(e), n, rng);

draw_test_endowments(m :: UniformMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    lb(m) .+ (ub(m) - lb(m)) .* rand(rng, n);

draw_test_endowments(nm :: NormalMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    mean(nm) .+ std(nm) .* randn(rng, n);



# --------------