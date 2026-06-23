```@meta
CurrentModule = HPIPM
```

# OCP QP

[`OCPQP`](@ref) solves the structured, stagewise problem over `k = 0 … N`:

```math
\min\ \sum_{k=0}^{N} \tfrac12
\begin{bmatrix} x_k \\ u_k \end{bmatrix}^\top
\begin{bmatrix} Q_k & S_k^\top \\ S_k & R_k \end{bmatrix}
\begin{bmatrix} x_k \\ u_k \end{bmatrix}
+ \begin{bmatrix} q_k \\ r_k \end{bmatrix}^\top
\begin{bmatrix} x_k \\ u_k \end{bmatrix}
\quad\text{s.t.}\quad
x_{k+1} = A_k x_k + B_k u_k + b_k
```

with box bounds on states and inputs. Dimensions may be constant (an `Int`) or
per-stage (a length-`N+1` vector); `u_N` is automatically empty.

Per-stage data passed to [`set!`](@ref) is either a single array (used on every
stage) or a vector of per-stage arrays.

## Double-integrator MPC

```@example ocp
using HPIPM
A = [1.0 1.0; 0.0 1.0]
B = reshape([0.0, 1.0], 2, 1)
Q = [1.0 0.0; 0.0 1.0]
R = reshape([0.1], 1, 1)
N = 10
x0 = [5.0, 0.0]

ocp = OCPQP(N; nx = 2, nu = 1, nbx = 2, nbu = 1)
set!(ocp; A, B, Q, R, x0,
     lbx = [-10.0, -10.0], ubx = [10.0, 10.0],
     lbu = [-1.0], ubu = [1.0])
solve!(ocp)

(HPIPM.state(ocp, 0), HPIPM.input(ocp, 0), HPIPM.state(ocp, N))
```

`x0` pins the initial state through stage-0 box bounds (so build the object with
`nbx ≥ nx` at stage 0). Read the optimal trajectory with [`state`](@ref) /
[`input`](@ref), or whole-trajectory [`states`](@ref) / [`inputs`](@ref).
