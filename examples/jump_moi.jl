# Driving HPIPM from JuMP, and comparing it against another MOI solver.
#
#   julia --project=examples examples/jump_moi.jl
#
# This is the comparison harness: assemble a QP, solve it with HPIPM, and (if you
# have another QP solver installed) solve the identical JuMP model with it and
# diff the solutions / objectives.

using HPIPM, JuMP
const MOI = JuMP.MOI
using LinearAlgebra

"""
    build_model(optimizer, H, g; A, b, lb, ub)

Build `min ½xᵀHx + gᵀx s.t. Ax=b, lb≤x≤ub` as a JuMP model using `optimizer`.
"""
function build_model(optimizer, H, g; A = nothing, b = nothing,
                     lb = nothing, ub = nothing)
    n = length(g)
    m = Model(optimizer)
    set_silent(m)
    @variable(m, x[1:n])
    lb === nothing || set_lower_bound.(x, lb)
    ub === nothing || set_upper_bound.(x, ub)
    if A !== nothing
        @constraint(m, A * x .== b)
    end
    @objective(m, Min, 0.5 * x' * H * x + g' * x)
    return m, x
end

# A small strictly-convex QP with one equality and box bounds.
H = [3.0 1.0; 1.0 2.0]
g = [-1.0, -4.0]
A = [1.0 1.0]
b = [1.0]
lb = [0.0, 0.0]
ub = [2.0, 2.0]

m, x = build_model(HPIPM.Optimizer, H, g; A, b, lb, ub)
optimize!(m)
xh = value.(x)
println("HPIPM:  status=$(termination_status(m))  x=$(round.(xh; digits=6))  obj=$(round(objective_value(m); digits=6))")

# --- compare against another solver, if available ---------------------------
# Install one and uncomment, e.g.:
#     import Pkg; Pkg.add("OSQP")            # or Clarabel, Ipopt, ...
#     using OSQP
#     other = OSQP.Optimizer
#
# Then:
function compare(other_optimizer, H, g; kwargs...)
    m2, x2 = build_model(other_optimizer, H, g; kwargs...)
    optimize!(m2)
    xo = value.(x2)
    println("other:  status=$(termination_status(m2))  x=$(round.(xo; digits=6))  obj=$(round(objective_value(m2); digits=6))")
    println("‖Δx‖∞ = ", norm(xo .- value.(x), Inf))
    return xo
end

# Uncomment once you have a second solver:
# compare(OSQP.Optimizer, H, g; A, b, lb, ub)

println("\n(To compare: add a second QP solver and call `compare(Solver.Optimizer, H, g; A, b, lb, ub)`.)")
