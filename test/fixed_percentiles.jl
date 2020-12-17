using Test, EndowmentsLH, Random

function fixed_percentiles_test(addNoise)
    rng = MersenneTwister(45);
    @testset "Draw fixed percentiles" begin
        n = 15;
        ed = EndowmentsLH.make_test_endowment_draws(n);
        nameV = names(ed);

        n2 = 5;
        pct = 0.7;
        draws = draw_fixed_percentiles(ed, n2, pct; addNoise = addNoise);
        @test names(draws) == nameV;
        for eName ∈ nameV
            v = get_draws(draws, eName);
            # Check that element type was not changed
            @test eltype(v) == eltype(ed, eName)
            if eltype(v) <: Integer
                @test all(v .== v[1])
            elseif eltype(v) <: Real
                @test all(isapprox.(v, v[1], atol = addNoise + 1e-5))
            end
        end
    end
end


@testset "Fixed percentiles" begin
    for addNoise ∈ (0.0, 0.1)
        fixed_percentiles_test(addNoise);
    end
end

# -------------