```@meta
CurrentModule = HPIPM
```

# Benchmarking another solver

A common workflow is to take an already-assembled QP and compare HPIPM against
another solver. There are two equivalent entry points.

## Same matrices, two solvers, via JuMP

Build one JuMP model factory and instantiate it with each optimizer:

```julia
using JuMP, HPIPM, LinearAlgebra

function build(optimizer, H, g; A, b, lb, ub)
    n = length(g)
    m = Model(optimizer); set_silent(m)
    @variable(m, x[1:n])
    set_lower_bound.(x, lb); set_upper_bound.(x, ub)
    @constraint(m, A * x .== b)
    @objective(m, Min, 0.5 * x' * H * x + g' * x)
    return m, x
end

H = [3.0 1.0; 1.0 2.0]; g = [-1.0, -4.0]
A = [1.0 1.0]; b = [1.0]; lb = [0.0, 0.0]; ub = [2.0, 2.0]

mh, xh = build(HPIPM.Optimizer, H, g; A, b, lb, ub); optimize!(mh)

# import Pkg; Pkg.add("OSQP"); using OSQP
# mo, xo = build(OSQP.Optimizer, H, g; A, b, lb, ub); optimize!(mo)
# @show norm(value.(xo) .- value.(xh), Inf)
```

See [`examples/jump_moi.jl`](https://github.com/el-oso/HPIPM.jl/blob/main/examples/jump_moi.jl).

## Allocation-free timing via the direct API

For apples-to-apples timing of the solver itself (not model assembly), use the
reusable [`DenseQP`](@ref) and time `solve!` after a warm-up. `solve!` allocates
nothing, so the GC never perturbs your measurement:

```julia
using HPIPM, BenchmarkTools
qp = DenseQP(2; ne = 1, nb = 2)
set!(qp; H = [3.0 1; 1 2], g = [-1.0, -4.0],
     A = [1.0 1.0], b = [1.0], lb = [0.0, 0.0], ub = [2.0, 2.0], idxb = [0, 1])
@benchmark solve!($qp)        # 0 allocations
```

The wrapper passes your column-major arrays to HPIPM by pointer; the only copy is
HPIPM's intrinsic column-major → BLASFEO panel-major pack inside `set!`. To
exclude even that from a re-solve benchmark, change only the right-hand sides
(`set_g!`, `set_b!`) between solves and keep `H`/`A`/`C` packed.
