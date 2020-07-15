using EndowmentsLH
using Random, Test


# function marginals_test()
# 	@testset "Marginals" begin
# 	end
# end

function endowment_test()
    @testset "Endowment and Marginals" begin
        rng = MersenneTwister(43);
        n = 11;
        ev = EndowmentsLH.make_test_endowment_vector();
        for e in ev
            m = marginal(e);
            println(m);
            @test isa(m, AbstractMarginal);
            if EndowmentsLH.isbounded(m)
                @test all(EndowmentsLH.ub(m) .> EndowmentsLH.lb(m))
            end

            println(e);
            @test isa(name(e), Symbol);
            x = EndowmentsLH.draw_test_endowments(e, n, rng);
            @test validate_draws(e, x)

            # Quantiles
            pctV = collect(0.0 : 0.2 : 1.0);
            quantileV = marginal_quantile(m, pctV);
            if !isnothing(quantileV)
                @test size(pctV) == size(quantileV)
                @test all(diff(quantileV) .>= 0.0)
                if isbounded(m)
                    @test isapprox(quantileV[1], lb(m))
                    @test isapprox(quantileV[end], ub(m))
                end
            end
        end
    end
end


function endowment_draws_test()
    rng = MersenneTwister(45);
    @testset "EndowmentDraws" begin
        # Empty
        # eV = EndowmentsLH.make_test_endowment_vector();
        ed = EndowmentDraws();
        @test isempty(ed)
        @test length(ed) == 0
        @test isnothing(names(ed))
        @test isnothing(get_meta(ed, :test))

        n = 5;
        ed = EndowmentsLH.make_test_endowment_draws(n);
        @test validate_draws(ed)
        @test length(ed) == n
        @test !isempty(ed)
        @test length(names(ed)) > 1
        @test !has_endowment(ed, :test)
        @test isnothing(get_meta(ed, :test))

        for dName in names(ed)
            @test has_endowment(ed, dName)
            endow = get_meta(ed, dName);
            @test name(endow) == dName
            @test isequal(get_label(ed, dName), label(endow))

            drawV = get_draws(ed, dName);
            @test length(drawV) == length(ed)
            
            draw23V = get_draws(ed, dName, 2:3);
            @test draw23V == drawV[2:3]

            newDrawV = EndowmentsLH.draw_test_endowments(endow, length(ed), rng);
            replace_draws!(ed, dName, newDrawV);
            @test get_draws(ed, dName) == newDrawV

            replace_draws!(ed, dName, newDrawV[2]);
            @test all(x -> newDrawV[2] == x,  get_draws(ed, dName))
        end

        for j = 1 : n
            tpE = type_endowments(ed, j);
            @test size(tpE) == size(names(ed))
        end

        # Select rows
        dName = names(ed)[2];
        idxV = 2 : 3;
        ed2 = select_rows(ed, idxV);
        @test length(ed2) == length(idxV)
        for (j, idx) in enumerate(idxV)
            @test isequal(get_draws(ed, dName, idx),  get_draws(ed2, dName, j))
        end
    end
end

## -----------  Custom endowment type, non-scalar values

# This is the custom type to be drawn.
struct CustomEndow{T1}
    x :: Vector{T1}
end

# Custom marginal that can handle a custom type
# # could be built in!
# struct CustomMarginal{T1} <: AbstractMarginal{T1} end
# EndowmentsLH.isbounded(::CustomMarginal{T1}) where T1 = false;
# Need to define `validate_draws` for each marginal
# EndowmentsLH.validate_draws(endow1 :: CustomMarginal{T1}, drawV) where T1 = true;

# Drawing endowments happens outside of the Endowments package.
function draw_endowments(T1, n, rng :: AbstractRNG)
    x = [CustomEndow(rand(rng, T1, 3))  for j = 1 : n];
    return x
end

function custom_type_test()
    rng = MersenneTwister(123);
    n = 7;

    @testset "Custom type" begin
        ed = EndowmentDraws();

        # Add a regular set of draws
        endow2 = Endowment(:endow2, "Endow2", PercentileMarginal{Float32}());
        draw2V = EndowmentsLH.draw_test_endowments(endow2, n, rng);
        add_draws!(ed, endow2, draw2V);
        @test validate_draws(ed)

        # Custom endowment
        T1 = Float16;
        drawV = draw_endowments(T1, n, rng);
        marginal1 = UnknownMarginal{CustomEndow{T1}}();
        endow1 = Endowment(:endow1, "Endow1", marginal1);
        add_draws!(ed, endow1, drawV);
        @test length(ed) == n
        @test length(names(ed)) == 2
        @test validate_draws(ed)
    end
end


@testset "All" begin
    endowment_test()
    endowment_draws_test()
    custom_type_test()
end

# -----------