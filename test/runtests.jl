using EndowmentsLH
using Random, Test

function endowment_test()
    @testset "Endowment" begin
        rng = MersenneTwister(43);
        n = 11;
        ev = EndowmentsLH.make_test_endowment_vector();
        for e in ev
            println(e);
            @test isa(name(e), Symbol);
            @test isa(marginal(e), AbstractMarginal);
            x = EndowmentsLH.draw_test_endowments(e, n, rng);
            @test validate_draws(e, x)
        end
    end
end


function endowment_draws_test()
    @testset "EndowmentDraws" begin
        # Empty
        eV = EndowmentsLH.make_test_endowment_vector();
        ed = EndowmentDraws(eV);
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

            drawV = get_draws(ed, dName);
            @test length(drawV) == length(ed)
            
            draw23V = get_draws(ed, dName, 2:3);
            @test draw23V == drawV[2:3]
        end

        for j = 1 : n
            tpE = type_endowments(ed, j);
            @test size(tpE) == size(names(ed))
        end
    end
end

@testset "All" begin
    endowment_test()
    endowment_draws_test()
end

# -----------