using Test, HPIPM

@testset "DenseQP" begin
    @testset "equality-constrained" begin
        # min ½(x₁²+x₂²) s.t. x₁+x₂=1  ⇒  x=(½,½), obj=¼, π=½
        res = HPIPM.solve([1.0 0; 0 1], [0.0, 0.0];
                          A = reshape([1.0, 1.0], 1, 2), b = [1.0])
        @test res.status == :success
        @test res.x ≈ [0.5, 0.5] atol = 1e-8
        @test res.objective ≈ 0.25 atol = 1e-8
        @test res.pi ≈ [0.5] atol = 1e-8
        @test res.residuals.stat < 1e-8
        @test res.residuals.eq < 1e-8
    end

    @testset "box-constrained" begin
        # min ½‖x‖² - [2,2]'x  s.t. 0≤x≤1  ⇒  x=(1,1), obj=-3
        qp = DenseQP(2; nb = 2)
        set!(qp; H = [1.0 0; 0 1], g = [-2.0, -2.0],
             lb = [0.0, 0.0], ub = [1.0, 1.0], idxb = [0, 1])
        @test solve!(qp) == :success
        @test HPIPM.primal(qp) ≈ [1.0, 1.0] atol = 1e-6
        @test HPIPM.objective(qp) ≈ -3.0 atol = 1e-6
    end

    @testset "one-sided general inequality (±Inf masks)" begin
        # min ½‖x‖² s.t. x₁+x₂≥2  ⇒  x=(1,1), obj=1
        qp = DenseQP(2; ng = 1)
        set!(qp; H = [1.0 0; 0 1], g = [0.0, 0.0],
             C = reshape([1.0, 1.0], 1, 2), lg = [2.0], ug = [Inf])
        @test solve!(qp) == :success
        @test HPIPM.primal(qp) ≈ [1.0, 1.0] atol = 1e-6
        @test HPIPM.objective(qp) ≈ 1.0 atol = 1e-6
    end

    @testset "dimension checks" begin
        qp = DenseQP(2)
        @test_throws DimensionMismatch set!(qp; H = [1.0 0; 0 1], g = [1.0])
        @test_throws DimensionMismatch set!(qp; H = ones(3, 3), g = [0.0, 0.0])
    end

    @testset "zero-allocation reuse" begin
        qp = DenseQP(2; nb = 2)
        set!(qp; H = [1.0 0; 0 1], g = [-2.0, -2.0],
             lb = [-5.0, -5.0], ub = [5.0, 5.0], idxb = [0, 1])
        g = [-1.0, -1.0]
        function loop!(qp, g, N)
            s = 0.0
            for k in 1:N
                @inbounds g[1] = -1.0 - 1e-9 * k
                set_g!(qp, g)
                solve!(qp)
                s += @inbounds HPIPM.primal(qp)[1]
            end
            return s
        end
        loop!(qp, g, 3)                       # warm up / compile
        @test (@allocated loop!(qp, g, 1000)) == 0
    end
end
