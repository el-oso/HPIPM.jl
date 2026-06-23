# Allocation-free re-solving: build the QP once, change data, re-solve in a loop.
#
#   julia --project=examples examples/dense_qp_reuse.jl
#
# This is the pattern to use when benchmarking or running MPC: the only cost is
# the one-time DenseQP allocation; each subsequent solve is GC-free.

using HPIPM

# min ½‖x‖² - gᵀx  s.t. -5 ≤ x ≤ 5  (parametric in g)
qp = DenseQP(2; nb = 2)
set!(qp; H = [1.0 0.0; 0.0 1.0], g = [0.0, 0.0],
     lb = [-5.0, -5.0], ub = [5.0, 5.0], idxb = [0, 1])

g = [0.0, 0.0]
function sweep!(qp, g, N)
    acc = 0.0
    for k in 1:N
        @inbounds g[1] = -2.0 + 4.0 * (k / N)   # vary g₁ over [-2, 2]
        set_g!(qp, g)                            # zero-allocation update
        solve!(qp)
        acc += @inbounds HPIPM.primal(qp)[1]
    end
    return acc
end

sweep!(qp, g, 10)                                # warm up / compile
allocated = @allocated sweep!(qp, g, 100_000)
println("100,000 update+solve iterations allocated $allocated bytes")
println("final x* = ", HPIPM.primal(qp))
@assert allocated == 0
