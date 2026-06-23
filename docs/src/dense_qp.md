```@meta
CurrentModule = HPIPM
```

# Dense QP

[`DenseQP`](@ref) solves

```math
\min_x\ \tfrac12 x^\top H x + g^\top x
\quad\text{s.t.}\quad
A x = b,\quad
l_b \le x_{\text{idxb}} \le u_b,\quad
l_g \le C x \le u_g .
```

* `H` is `nv×nv`, `A` is `ne×nv`, `C` is `ng×nv`, all column-major `Matrix{Float64}`.
* Box bounds apply to the variables listed (0-based) in `idxb`.
* Use `±Inf` in any bound to disable that side (handled via HPIPM masks).

## One-shot

```@example dense
using HPIPM
res = HPIPM.solve([2.0 0.5; 0.5 2.0], [-1.0, -2.0];
                  A = [1.0 1.0], b = [1.0],
                  lb = [0.0, 0.0], ub = [Inf, Inf], idxb = [0, 1])
(res.status, res.x, res.objective)
```

The returned `NamedTuple` has `x`, `objective`, `status`, `iterations`, `pi`
(equality multipliers) and `residuals` (max KKT residuals).

## Reusable object (allocation-free re-solves)

Build the [`DenseQP`](@ref) once and reuse it; only the data you pass to
[`set!`](@ref) is updated, so changing `g` keeps `H`/`A`/`C` already packed.

```@example dense
qp = DenseQP(2; nb = 2)
set!(qp; H = [1.0 0; 0 1], g = [-2.0, -2.0],
     lb = [0.0, 0.0], ub = [1.0, 1.0], idxb = [0, 1])
solve!(qp)
HPIPM.primal(qp), HPIPM.objective(qp)
```

For the hot loop, the dedicated setters [`set_g!`](@ref) (and `set_b!`,
`set_H!`, `set_A!`, `set_C!`) avoid keyword overhead and allocate nothing:

```@example dense
g = [-1.0, -1.0]
for _ in 1:1000
    set_g!(qp, g)
    solve!(qp)
end
HPIPM.primal(qp)
```

## Accessors

`status`, `iterations`, `objective`, `primal`, `dual_eq`, `residuals` read the
in-place buffers after [`solve!`](@ref). The returned arrays are live internal
buffers — `copy` them if you need to retain values across solves.
