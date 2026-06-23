# OCP QP: a small double-integrator model-predictive-control problem.
#
#   julia --project=examples examples/ocp_qp.jl

using HPIPM

# discrete double integrator (dt = 1): state [position; velocity], input = force
A = [1.0 1.0; 0.0 1.0]
B = reshape([0.0, 1.0], 2, 1)
Q = [1.0 0.0; 0.0 1.0]      # stage + terminal state cost
R = reshape([0.1], 1, 1)    # input cost
N = 10                      # horizon
x0 = [5.0, 0.0]             # start 5 units from the origin, at rest

ocp = OCPQP(N; nx = 2, nu = 1, nbx = 2, nbu = 1)
set!(ocp; A, B, Q, R, x0,
     lbx = [-10.0, -10.0], ubx = [10.0, 10.0],   # state limits
     lbu = [-1.0], ubu = [1.0])                   # actuator saturation ±1

st = solve!(ocp)
println("status     : ", st, "   (", HPIPM.iterations(ocp), " iters)")
println("\n k :        x (pos, vel)            u")
for k in 0:N
    xk = HPIPM.state(ocp, k)
    uk = k < N ? HPIPM.input(ocp, k) : Float64[]
    println(lpad(k, 2), " : ", round.(xk; digits = 4), "    ", round.(uk; digits = 4))
end
