"""
	$(SIGNATURES)

Constructor for `EndowmentDraws`.
"""
EndowmentDraws(meta :: Vector{Endowment{Any}}) =
    EndowmentDraws(meta, DataFrame());

EndowmentDraws(meta :: Vector{Endowment{T1}}) where T1 <: AbstractFloat =
    EndowmentDraws(meta, DataFrame());


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


## ---------  Modify

"""
	$(SIGNATURES)

Add draws for one variable to existing `EndowDraws`.
"""
function add_draws!(e :: EndowmentDraws, endow :: Endowment{T1},
    dV :: AbstractVector{T1}) where T1

    setproperty!(e.draws, name(endow), dV);
end


# -------  For testing

function make_test_endowment_draws(n :: Integer)
    rng = MersenneTwister(43);
    ev = make_test_endowment_vector();
    ed = EndowmentDraws(ev);
    for endow in ev
        dV = draw_test_endowments(endow, n, rng);
        add_draws!(ed, endow, dV);
    end
    @assert validate_draws(ed)
    return ed
end

function make_test_endowment_vector()
    return [Endowment(:normal, NormalMarginal(2.0, 1.5)),
        Endowment(:uniform, UniformMarginal(-1.5, 0.5))]
end

# -----------------