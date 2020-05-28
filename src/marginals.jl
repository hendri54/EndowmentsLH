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

validate_draws(u :: UniformMarginal{T1}, x :: Vector{T1})  where T1 =
    validate_bounded_draws(u, x);


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

## -----------  Percentile

lb(u :: PercentileMarginal{T1}) where T1  =  zero(T1);
ub(u :: PercentileMarginal{T1}) where T1  =  one(T1);

draw_test_endowments(m :: PercentileMarginal{T1}, n, rng :: AbstractRNG) where T1 =
    rand(rng, T1, n);

validate_draws(u :: PercentileMarginal{T1}, x) where T1 = 
    validate_bounded_draws(u, x);


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