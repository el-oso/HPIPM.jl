```@meta
CurrentModule = HPIPM
```

# HPIPM.jl

Julia bindings, an idiomatic wrapper, and a [MathOptInterface](https://github.com/jump-dev/MathOptInterface.jl)
layer for [HPIPM](https://github.com/giaf/hpipm) — Gianluca Frison's
high-performance interior-point QP solver built on
[BLASFEO](https://github.com/giaf/blasfeo).

It targets two problem classes in double precision:

* **Dense QP** — feed pre-assembled `H`, `g`, `A`, `b`, `C` and bounds directly.
* **OCP QP** — the structured, stagewise model-predictive-control form.

and exposes both a **direct API** (for tight, allocation-free re-solves and
benchmarking) and a **JuMP-compatible `Optimizer`**.

## Quick start

```julia
using HPIPM

# min ½‖x‖² s.t. x₁ + x₂ = 1
res = HPIPM.solve([1.0 0; 0 1], [0.0, 0.0];
                  A = reshape([1.0, 1.0], 1, 2), b = [1.0])

res.x          # ≈ [0.5, 0.5]
res.objective  # ≈ 0.25
res.status     # :success
```

From JuMP:

```julia
using JuMP, HPIPM
m = Model(HPIPM.Optimizer)
@variable(m, x[1:2])
@constraint(m, sum(x) == 1)
@objective(m, Min, x[1]^2 + x[2]^2)
optimize!(m)
value.(x)      # ≈ [0.5, 0.5]
```

## Performance model

HPIPM owns its BLASFEO (panel-major) storage and packs your column-major data in
internally — that single pack is intrinsic to BLASFEO. The Julia side adds **no
overhead**: input matrices are passed by pointer (no copy), every solver object
is allocated once in [`DenseQP`](@ref)/[`OCPQP`](@ref), and `solve!` is
allocation- and GC-free. See [Benchmarking another solver](@ref).

## Contents

```@contents
Pages = ["installation.md", "dense_qp.md", "ocp_qp.md", "moi.md", "benchmarking.md", "api.md"]
Depth = 1
```
