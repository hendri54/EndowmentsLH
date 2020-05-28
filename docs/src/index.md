# EndowmentsLH

The purpose of this package is to provide a uniform interface for storing, accessing, and validating endowment draws in heterogeneous agent economic models.

Endowment draws are collected in the [`EndowmentDraws`](@ref) object. These draws can be scalars or custom, user defined data types.

Each [`Endowment`](@ref) contains information about its marginal distribution, encoded as an [`AbstractMarginal`](@ref). This allows automatic checking of types and bounds. The following marginal distributions are predefined:

* [`UniformMarginal`](@ref)
* [`NormalMarginal`](@ref)
* [`PercentileMarginal`](@ref)
* [`BoundedMarginal`](@ref)
* [`UnboundedMarginal`](@ref)

All of these handle scalar `Float` or `Integer` draws, which constitute the majority of the draws in the kinds of models that I work with. The user can define additional marginal distributions (see below).

Each marginal comes with a [`validate_draws`](@ref) function that validates that endowment draws are valid for this marginal.


```@docs
EndowmentDraws
Endowment
AbstractMarginal
UniformMarginal
NormalMarginal
PercentileMarginal
UnboundedMarginal
validate_draws
```

## Typical Flow

A collection of `EndowmentDraws` is typically set up by:

1. Initializing an empty object: `ed = EndowmentDraws()`.
2. Defining one endowment at a time: `endow2 = Endowment(:endow2, "Endow2", PercentileMarginal{Float32}())`.
3. Drawing the endowment (model specific).
4. Adding the endowment to the object: `add_draws!(ed, endow2, drawV)`.
5. Validating the draws with [`validate_draws`](@ref).

Endowment draws may be retrieved one endowment at a time using [`get_draws`](@ref) or all endowments for one individual in one go using [`type_endowments`](@ref).

```@docs
add_draws!
get_draws
type_endowments
```

--------------
