using Test, HPIPM
using JuMP
const MOI = JuMP.MOI

@testset "MOI / JuMP" begin
    @testset "equality QP" begin
        # min x₁²+x₂² s.t. x₁+x₂=1  ⇒  x=(½,½), obj=½
        m = Model(HPIPM.Optimizer)
        set_silent(m)
        @variable(m, x[1:2])
        @constraint(m, c, x[1] + x[2] == 1)
        @objective(m, Min, x[1]^2 + x[2]^2)
        optimize!(m)
        @test termination_status(m) == MOI.OPTIMAL
        @test primal_status(m) == MOI.FEASIBLE_POINT
        @test value.(x) ≈ [0.5, 0.5] atol = 1e-7
        @test objective_value(m) ≈ 0.5 atol = 1e-7
        @test dual(c) ≈ 1.0 atol = 1e-6        # shadow price d(obj)/db
        @test MOI.get(m, MOI.BarrierIterations()) isa Integer
    end

    @testset "bounded LP via QP path, maximize" begin
        # max 2x+3y s.t. x+y≤4, 0≤x≤3, y≥0  ⇒  (x,y)=(0,4), obj=12
        m = Model(HPIPM.Optimizer)
        set_silent(m)
        @variable(m, 0 <= x <= 3)
        @variable(m, y >= 0)
        @constraint(m, x + y <= 4)
        @objective(m, Max, 2x + 3y)
        optimize!(m)
        @test termination_status(m) == MOI.OPTIMAL
        @test objective_value(m) ≈ 12.0 atol = 1e-5
        @test value(y) ≈ 4.0 atol = 1e-5
        @test value(x) ≈ 0.0 atol = 1e-5
    end

    @testset "interval-constrained QP" begin
        # min (x-3)²+(y-2)² s.t. 1≤x+y≤3, x,y≥0
        m = Model(HPIPM.Optimizer)
        set_silent(m)
        @variable(m, x >= 0)
        @variable(m, y >= 0)
        @constraint(m, 1 <= x + y <= 3)
        @objective(m, Min, (x - 3)^2 + (y - 2)^2)
        optimize!(m)
        @test termination_status(m) == MOI.OPTIMAL
        # unconstrained min (3,2) has x+y=5>3, so x+y=3 is active
        @test value(x) + value(y) ≈ 3.0 atol = 1e-5
    end

    @testset "raw options" begin
        m = Model(HPIPM.Optimizer)
        set_optimizer_attribute(m, "iter_max", 5)
        set_optimizer_attribute(m, "mode", "ROBUST")
        set_silent(m)
        @variable(m, z)
        @constraint(m, z >= 1)
        @objective(m, Min, z^2)
        optimize!(m)
        @test termination_status(m) == MOI.OPTIMAL
        @test value(z) ≈ 1.0 atol = 1e-5
    end
end
