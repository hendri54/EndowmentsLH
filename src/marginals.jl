include("beta_marginal.jl")

## -----------  Generic

isbounded(u :: AbstractMarginal{T1}) where T1 = true;
lb(u :: AbstractMarginal{T1}) where T1  =  
    isbounded(u)  ?  u.lb  :  -Inf;
ub(u :: AbstractMarginal{T1}) where T1  =  
    isbounded(u)  ?  u.ub  :  Inf;

function Base.show(io :: IO, u :: AbstractMarginal{T1}) where T1
    print(io, typeof(u));
    if isbounded(u)
        print(io,  " with bounds ",  round.([lb(u), ub(u)], digits = 2));
    end
end


"""
	$(SIGNATURES)

Quantiles for a marginal distribution. Inputs are percentiles in [0, 1].
Not defined for all distributions. Fallback returns nothing.
"""
function marginal_quantile(u :: AbstractMarginal{T1}, pct) where T1
    return nothing
end


"""
	$(SIGNATURES)

Validate draws from a given marginal distribution. Mainly bounds checking and avoiding Inf and NaN.
"""
function validate_draws end

function validate_bounded_draws(u :: AbstractMarginal{T1}, x :: AbstractArray{T1}) where T1 <: AbstractFloat

    isValid = true;
    isValid = isValid  &&  check_float_array(x, lb(u), ub(u));
    return isValid
end

function validate_bounded_draws(u :: AbstractMarginal{T1}, x :: T1) where T1 <: AbstractFloat
    
    isValid = true;
    isValid = isValid  &&  check_float(x, lb(u), ub(u));
    return isValid
end

function validate_unbounded_draws(nm :: AbstractMarginal{T1}, x) where T1
    isValid = true
    isValid = isValid && !any(isinf.(x));
    return isValid
end


## ------  Uniform

draw_test_endowments(m :: UniformMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    lb(m) .+ (ub(m) - lb(m)) .* rand(rng, T1, n);

validate_draws(u :: UniformMarginal{T1}, x :: AbstractVector{T1})  where T1 =
    validate_bounded_draws(u, x);

function marginal_quantile(u :: UniformMarginal{T1}, pct) where T1
    return lb(u) .+ (ub(u) .- lb(u)) .* pct;
end
    
mean(m :: UniformMarginal{T1}) where T1 = (ub(m) + lb(m)) / T1(2);
var(m :: UniformMarginal{T1}) where T1 = ((ub(m) - lb(m)) ^ T1(2)) / T1(12);
std(m :: UniformMarginal{T1}) where T1 = sqrt(var(m));


## ----------  Normal

Base.show(io :: IO, u :: NormalMarginal{T1}) where T1 =
    print(io, typeof(u), 
        " with mean ",  round(mean(u), digits = 2),
        " and std ",  round(std(u), digits = 2));

mean(n :: NormalMarginal{T1}) where T1  =  n.mean;
std(n :: NormalMarginal{T1}) where T1  =  n.std;
isbounded(u :: NormalMarginal{T1}) where T1 = false;

draw_test_endowments(nm :: NormalMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    mean(nm) .+ std(nm) .* randn(rng, T1, n);

validate_draws(nm :: NormalMarginal{T1}, x :: Vector{T1}) where T1 =
    validate_unbounded_draws(nm, x);

function marginal_quantile(u :: NormalMarginal{T1}, pct) where T1
    return quantile.(Distributions.Normal(u.mean, u.std), pct)
end
    

## ----------  LogNormal

Base.show(io :: IO, u :: LogNormalMarginal{T1}) where T1 =
    print(io, typeof(u), 
        " with mean ",  round(mean(u), digits = 2),
        " and std ",  round(std(u), digits = 2));

# https://en.wikipedia.org/wiki/Log-normal_distribution
mean(n :: LogNormalMarginal{T1}) where T1  =  
    n.lb + exp(n.mean + T1(0.5) * (n.std) ^ T1(2));
var(n :: LogNormalMarginal{T1}) where T1  =  
    exp(T1(2) * n.mean + n.std ^ 2) * (exp(n.std ^ 2) - one(T1));
std(n :: LogNormalMarginal{T1}) where T1 = sqrt(var(n));
isbounded(u :: LogNormalMarginal{T1}) where T1 = false;

draw_test_endowments(nm :: LogNormalMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    # Do not use mean(nm) and std(nm). They mean something different.
    nm.lb .+ exp.(nm.mean .+ nm.std .* randn(rng, T1, n));

validate_draws(nm :: LogNormalMarginal{T1}, x :: Vector{T1}) where T1 =
    validate_unbounded_draws(nm, x);

function marginal_quantile(u :: LogNormalMarginal{T1}, pct) where T1
    return u.lb .+ exp.(quantile.(Distributions.Normal(u.mean, u.std), pct))
end
    

## -----------  Percentile

lb(u :: PercentileMarginal{T1}) where T1  =  zero(T1);
ub(u :: PercentileMarginal{T1}) where T1  =  one(T1);

# Same as uniform
mean(m :: PercentileMarginal{T1}) where T1 = (ub(m) + lb(m)) / T1(2);
var(m :: PercentileMarginal{T1}) where T1 = ((ub(m) - lb(m)) ^ T1(2)) / T1(12);
std(m :: PercentileMarginal{T1}) where T1 = sqrt(var(m));

draw_test_endowments(m :: PercentileMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    rand(rng, T1, n);

validate_draws(u :: PercentileMarginal{T1}, x) where T1 = 
    validate_bounded_draws(u, x);

marginal_quantile(m :: PercentileMarginal{T1}, pct) where T1 = pct;


## -----------  Bounded

draw_test_endowments(m :: BoundedMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    lb(m) .+ (ub(m) - lb(m)) .* rand(rng, T1, n);

validate_draws(u :: BoundedMarginal{T1}, x) where T1 = 
    validate_bounded_draws(u, x);



## -----------  Unbounded
        
isbounded(u :: UnboundedMarginal{T1}) where T1 = false;
validate_draws(u :: UnboundedMarginal{T1}, x) where T1 =
    validate_unbounded_draws(u, x);

draw_test_endowments(m :: UnboundedMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    randn(rng, T1, n);


## ------------  Unknown

isbounded(u :: UnknownMarginal{T1}) where T1 = false;
validate_draws(u :: UnknownMarginal{T1}, x) where T1 = true;

draw_test_endowments(m :: UnknownMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    [draw_test_endowment(T1, rng)  for j = 1 : n];

function draw_test_endowment(T1, rng :: AbstractRNG)
    if T1 == Vector{Int}
        return rand(rng, 1 : 100, 3);
    else
        error("Not implemented")
    end
end

# -------------