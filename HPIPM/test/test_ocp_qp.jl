using Test, HPIPM

@testset "OCPQP" begin
    # double integrator, dt = 1
    A = [1.0 1.0; 0.0 1.0]
    B = reshape([0.0, 1.0], 2, 1)
    Q = [1.0 0.0; 0.0 1.0]
    R = reshape([1.0], 1, 1)
    N = 5
    x0 = [1.0, 0.0]

    ocp = OCPQP(N; nx = 2, nu = 1, nbx = 2)
    set!(ocp; A, B, Q, R, x0, lbx = [-1e3, -1e3], ubx = [1e3, 1e3])
    @test solve!(ocp) == :success

    X = HPIPM.states(ocp)
    U = HPIPM.inputs(ocp)

    @testset "initial state pinned" begin
        @test X[1] ≈ x0 atol = 1e-6
    end

    @testset "dynamics consistency" begin
        maxres = 0.0
        for k in 1:N
            maxres = max(maxres, maximum(abs, X[k + 1] .- (A * X[k] .+ B * U[k])))
        end
        @test maxres < 1e-6
    end

    @testset "regulation" begin
        @test sum(abs2, X[end]) < sum(abs2, x0)
    end

    @testset "cross-check vs dense condensation" begin
        # Condense the OCP into a single dense QP in the inputs U=(u₀…u_{N-1}) by
        # propagating xₖ = Φₖ x₀ + Σ Γ Bᵢ uᵢ, then compare the optimal u₀.
        n, m = 2, 1
        # state trajectory as affine function of stacked U
        Φ = Matrix{Float64}(I, n, n)
        Smap = [zeros(n, N * m) for _ in 0:N]   # xₖ = Φᵏ x₀ + Smap[k]·U
        Φk = [Matrix{Float64}(I, n, n) for _ in 0:N]
        for k in 1:N
            Φk[k + 1] = A * Φk[k]
            Smap[k + 1] = A * Smap[k]
            Smap[k + 1][:, ((k - 1) * m + 1):(k * m)] = B
        end
        # cost J = Σ xₖ'Qxₖ·½·2 ... build H,g over U
        H = zeros(N * m, N * m)
        g = zeros(N * m)
        for k in 0:N
            S = Smap[k + 1]
            H .+= S' * Q * S
            xc = Φk[k + 1] * x0
            g .+= S' * Q * xc
        end
        for k in 0:(N - 1)
            H[(k * m + 1):((k + 1) * m), (k * m + 1):((k + 1) * m)] .+= R
        end
        res = HPIPM.solve(H, g)
        @test res.status == :success
        @test res.x[1:m] ≈ U[1] atol = 1e-5
    end
end
