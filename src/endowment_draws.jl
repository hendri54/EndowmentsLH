"""
	$(SIGNATURES)

Constructor for `EndowmentDraws`.
"""
EndowmentDraws() = EndowmentDraws(Vector{Endowment}(), DataFrame())

# EndowmentDraws(meta :: Vector{Endowment{Any}}) =
#     EndowmentDraws(meta, DataFrame());

# EndowmentDraws(meta :: Vector{Endowment{T1}}) where T1 =
#     EndowmentDraws(meta, DataFrame());



"""
	$(SIGNATURES)

Validate endowment draws. Includes bounds checking.
"""
function validate_draws(ed :: EndowmentDraws)
    isValid = true;
    if !isempty(ed)
        for dName in names(ed)
            isValid = isValid  &&
                validate_draws(get_meta(ed, dName), get_draws(ed, dName));
        end
    end
    return isValid
end


"""
	$(SIGNATURES)

Compute the correlation matrix of select endowments. Defaults to all endowments in the order determined by `names(ed)`.
Note that not all endowments are scalar. Correlations are only computed for those that are. The others are set to NaN.
"""
function corr_matrix(ed :: EndowmentDraws, nameV :: Vector{Symbol} = names(ed))
    n = length(nameV);
    @assert n > 1
    corrM = zeros(n, n);
    for i1 = 1 : (n-1)
        d1 = get_draws(ed, nameV[i1]);
        corrM[i1, i1] = 1.0;
        if isa(d1, Vector{<:Real})
            for i2 = (i1+1) : n
                d2 = get_draws(ed, nameV[i2]);
                if isa(d2, Vector{<:Real})
                    corrM[i1, i2] = cor(d1, d2);
                else
                    corrM[i1, i2] = NaN;
                end
            end
        end
    end
    corrM[n, n] = 1.0;
    return corrM
end


"""
	$(SIGNATURES)

Create formatted correlation matrix for selected endowments. Returns a string matrix with headers.
"""
function formatted_corr_matrix(ed :: EndowmentDraws, 
    nameV :: Vector{Symbol} = names(ed))

    corrM = corr_matrix(ed, nameV);
    return formatted_corr_matrix(corrM, nameV);
end


"""
	$(SIGNATURES)

Create formatted correlation matrix from a numeric matrix and variable names. Correlation matrix may contain NaNs.
"""
function formatted_corr_matrix(corrM :: AbstractMatrix{F1}, nameV :: Vector{T2}) where {F1 <: Real, T2}

    n = length(nameV);
    @assert size(corrM) == (n, n)
    
    m = fill("", n+1, n+1);
    for j = 1 : n
        m[1, j+1] = string(nameV[j]);
        m[j+1, 1] = string(nameV[j]);
        m[j+1, j+1] = "1.0";
    end
    for j1 = 1 : (n-1)
        for j2 = (j1 + 1) : n
            c = corrM[j1, j2];
            if isnan(c)
                s = "--";
            else
                s = "$(round(c, digits = 2))";
            end
            m[j1+1, j2+1] = s;
        end
    end
    return m
end


## -------------  Access

Base.show(io :: IO, ed :: EndowmentDraws) = 
    print(io,  "EndowmentDraws of length ", length(ed), " with fields ", names(ed));
Base.isempty(ed :: EndowmentDraws) = (length(ed) == 0);
Base.length(ed :: EndowmentDraws) = size(ed.draws, 1);

# Returns names as Vector{Symbol}
function Base.names(ed :: EndowmentDraws)
    if isempty(ed)
        return nothing
    else
        return Symbol.(names(ed.draws));
    end
end


"""
	$(SIGNATURES)

Retrieve endowment draws for one type as a DataFrame row. One can splat this as a tuple into a function:

`foo(type_endowments(e, j)...)` is the same as `foo(x, y)`
"""
type_endowments(e :: EndowmentDraws, j :: Integer) = e.draws[j,:];


"""
	$(SIGNATURES)

Create a copy of an `EndowmentDraws` object with only select cases.
"""
select_rows(e :: EndowmentDraws, idxV) = EndowmentDraws(e.meta, e.draws[idxV, :]);


# """
# 	$(SIGNATURES)

# Select cases in place.
# """
# select_rows!(e :: EndowmentDraws, idxV) = (e.draws = e.draws[idxV, :]);

Base.eltype(e :: EndowmentDraws, eName :: Symbol) = 
    eltype(get_meta(e, eName));

"""
	$(SIGNATURES)

Retrieve label for one endowment.
"""
get_label(e :: EndowmentDraws, eName :: Symbol) = 
    label(get_meta(e, eName));

"""
	$(SIGNATURES)

Retrieve the meta information about one `Endowment`. Returns an `Endowment` object. Nothing if not found.
"""
function get_meta(e :: EndowmentDraws, eName :: Symbol)
    idx = find_meta(e, eName);
    if !isnothing(idx)
        return e.meta[idx];
    else
        return nothing
    end
end

# Find index into `meta` for an endowment. Nothing if not found.
function find_meta(e :: EndowmentDraws, eName :: Symbol)
    if isempty(e)
        return nothing
    else
        return findfirst(n -> eName == n,  names(e));
    end
end

has_endowment(e :: EndowmentDraws, eName :: Symbol) = 
    !isnothing(find_meta(e, eName));

"""
	$(SIGNATURES)

Retrieve draws for one endowment; for all individuals.
"""
get_draws(e :: EndowmentDraws, eName) = e.draws[!, eName];

get_draws(e :: EndowmentDraws, eName, idxV) = e.draws[idxV, eName];

"""
	$(SIGNATURES)

Return DataFrame with all endowments. Useful for running regressions on endowments.
"""
get_dataframe(e :: EndowmentDraws) = e.draws;


"""
	$(SIGNATURES)

Returns quantiles of one endowment from its draws. Returns the same `DataType` as the endowment itself (e.g. nearest Integer).

Quantile = quantile from Statistics, rounded to the `eltype` of the endowment draw.

Only for scalar, numeric endowments.
"""
function endow_quantiles(e :: EndowmentDraws, eName, pctV)
    eType = eltype(e, eName);
    @assert eType <: Real  "Only for scalar numeric endowments. $eName is of $eType"
    qV = quantile(get_draws(e, eName), pctV);
    if eType <: Integer
        eqV = round.(eType, qV);
    else
        eqV = convert.(eType, qV);
    end
    return eqV
end


## ---------  Modify

"""
	$(SIGNATURES)

Add draws for one variable to existing `EndowDraws`.
"""
function add_draws!(e :: EndowmentDraws, endow :: Endowment{T1},
    dV :: AbstractVector{T1}) where T1

    @assert !has_endowment(e, name(endow))
    push!(e.meta, endow);
    setproperty!(e.draws, name(endow), dV);
end


"""
	$(SIGNATURES)

Replace values for one endowment. Type cannot change.
`newVals` is a Vector. One element for each draw. Or it is a scalar.
"""
function replace_draws!(e :: EndowmentDraws, eName :: Symbol, newVals :: T1) where T1
    oldType = eltype(getproperty(e.draws, eName));
    if oldType == T1
        # This is necessary in case each entry is a Vector
        for j = 1 : length(e)
            e.draws[j, eName] = newVals;
        end
    elseif eltype(newVals) == oldType
        # Input is a vector. One draw for each old draw.
        @assert length(newVals) == length(e)    
        e.draws[!, eName] .= newVals;
    else
        error("""
        Type mismatch for $eName:  
        $(typeof(newVals))  vs  $(oldType)
        """);
    end
end


# """
# 	$(SIGNATURES)

# Replace endowments with their quantiles.
# """
# function replace_with_quantiles!(e :: EndowmentDraws, eNames, 
#     pctV :: AbstractVector{F1}) where F1 <: AbstractFloat

#     @assert length(pctV) == length(e)  "Need one percentile for each observation";
#     for eName in eNames
#         replace_draws!(e, eName, endow_quantiles(e, eName, pctV));
#     end
# end


"""
	$(SIGNATURES)

Return `n` endowment draws where all numeric endowments are set to the same quantile in their distributions. Non-scalar endowments are set arbitrarily (because they don't have well-defined quantiles).

# Arguments
- `addNoise`: scale for additive noise. If not `nothing`, create a Vector in (0, addNoise) and add it to the draws. The purpose is to leave some variation in the draws for cases where identical draws cause numerical issues.
"""
function draw_fixed_percentiles(e :: EndowmentDraws, n :: Integer, pct :: F1;
    addNoise :: F2 = 0.0) where {F1 <: AbstractFloat, F2 <: AbstractFloat}

    draws = select_rows(e, 1 : n);
    for eName in names(e)
        eType = eltype(e, eName);
        if eType <: Real
            q = endow_quantiles(e, eName, pct);
            replace_draws!(draws, eName, q .+ gen_noise(eType, addNoise, n));
        end
    end
    return draws
end

function gen_noise(F1 :: Type{<:AbstractFloat}, addNoise, n :: Integer)
    if addNoise > zero(F1)
        nV = F1(addNoise) .* rand(F1, n);
    else
        nV = zero(F1);
    end
end

# For Integers, cannot add noise
gen_noise(I1 :: Type{<:Integer}, addNoise, n :: Integer) = zero(I1);


# -------  For testing

function make_test_endowment_draws(n :: Integer)
    rng = MersenneTwister(43);
    ev = make_test_endowment_vector();
    ed = EndowmentDraws();
    for endow in ev
        dV = draw_test_endowments(endow, n, rng);
        add_draws!(ed, endow, dV);
    end
    @assert validate_draws(ed)
    return ed
end


# -----------------