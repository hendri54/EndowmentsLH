using Test, Random, EndowmentsLH

function quantile_test()
    rng = MersenneTwister(45);
    @testset "Quantiles" begin
        n = 50;
        ed = EndowmentsLH.make_test_endowment_draws(n);
        # pctV = LinRange(0.1, 0.9, n);
        for dName in names(ed)
            drawV = get_draws(ed, dName);
            if eltype(drawV) <: Real
                qV = endow_quantiles(ed, dName, [0.3, 0.7]);
                @test eltype(qV) == eltype(drawV)
                @test size(qV) == (2,)
                @test all(diff(qV) .> 0.0)

                q = endow_quantiles(ed, dName, 0.7);
                @test isapprox(qV[2], q)
                nLess = sum(get_draws(ed, dName) .<= q);
                @test abs(nLess / n - 0.7) < 1.5 / n
            end
        end
    end
end

@testset "Quantiles" begin
    quantile_test();
end

# -----------