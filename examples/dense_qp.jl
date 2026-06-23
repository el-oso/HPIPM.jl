# Dense QP via the direct API.
#
#   julia --project=examples examples/dense_qp.jl
#
# Feed pre-assembled matrices/vectors straight to HPIPM.

using HPIPM

# min ½ xᵀH x + gᵀx  s.t.  A x = b,  lb ≤ x ≤ ub,  lg ≤ C x ≤ ug
H = [2.0 0.5 0.0
     0.5 2.0 0.0
     0.0 0.0 1.0]
g = [-1.0, -2.0, 0.0]
A = [1.0 1.0 1.0]          # x₁+x₂+x₃ = 1
b = [1.0]
C = [1.0 0.0 -1.0]         # -∞ ≤ x₁-x₃ ≤ 0.5
lg = [-Inf]
ug = [0.5]
lb = [0.0, 0.0, 0.0]       # x ≥ 0
ub = [Inf, Inf, Inf]
idxb = [0, 1, 2]           # bounds on all three variables (0-based)

res = HPIPM.solve(H, g; A, b, C, lg, ug, lb, ub, idxb)

println("status      : ", res.status)
println("x*          : ", res.x)
println("objective   : ", res.objective)
println("iterations  : ", res.iterations)
println("eq dual π   : ", res.pi)
println("KKT resid.  : ", res.residuals)
