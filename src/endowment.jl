# ------  Access

Base.show(io :: IO, e :: Endowment{T1}) where T1 =
    print(io, typeof(e),  " $(name(e)) with ",  marginal(e));

name(e :: Endowment{T1}) where T1  =  e.name;
label(e :: Endowment{T1}) where T1  = e.label;
marginal(e :: Endowment{T1}) where T1  =  e.marginal;
Base.eltype(e :: Endowment{T1}) where T1 = T1;

validate_draws(e :: Endowment{T1}, x :: Vector{T1}) where T1  =
    validate_draws(marginal(e), x);



# ------  For testing

function make_test_endowment_vector()
    return [Endowment(:normal, "Normal", NormalMarginal(2.0, 1.5)),
        Endowment(:uniform, "Uniform", UniformMarginal(-1.5, 0.5)),
        Endowment(:percentile, "Percentile", PercentileMarginal{Float32}()),
        Endowment(:bounded,  "Bounded", BoundedMarginal(3.0, 4.0)),
        Endowment(:unbounded,  "Unbounded", UnboundedMarginal{Float16}()),
        Endowment(:beta, "Beta", BetaMarginal(-1.2, 3.4, 1.4, 3.2)),
        Endowment(:unknown, "Unknown", UnknownMarginal{Vector{Int}}())]
end


draw_test_endowments(e :: Endowment{T1}, n, rng :: AbstractRNG) where T1  =
    draw_test_endowments(marginal(e), n, rng);


# --------------