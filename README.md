# HPIPM.jl

Julia bindings, an idiomatic wrapper, and a MathOptInterface layer for
[HPIPM](https://github.com/giaf/hpipm) — Gianluca Frison's high-performance
interior-point QP solver, built on [BLASFEO](https://github.com/giaf/blasfeo).

* **Dense QP** — feed pre-assembled `H`, `g`, `A`, `b`, `C`, bounds.
* **OCP QP** — structured, stagewise model-predictive-control form.
* **Direct API** with allocation-free, GC-free re-solves for benchmarking.
* **`HPIPM.Optimizer`** — usable from JuMP / MathOptInterface.

## Repository layout

| Path | What |
|---|---|
| `HPIPM/` | the `HPIPM.jl` package (`src/`, `test/`) |
| `HPIPM_jll/` | self-contained, in-repo JLL wrapping the prebuilt `libhpipm.so` |
| `jll/build_tarballs.jl` | BinaryBuilder recipe (for a future Yggdrasil submission) |
| `gen/` | Clang.jl binding generator config + driver |
| `docs/`, `examples/` | DocumenterVitepress site, runnable examples |
| `setup.jl` | one-shot offline installer for the vendored binary artifact |

## Quick start

```console
$ julia setup.jl                                          # install binaries (offline, once)
$ julia --project=HPIPM -e 'using Pkg; Pkg.instantiate()'
$ julia --project=HPIPM
```

```julia
using HPIPM

# min ½‖x‖² s.t. x₁ + x₂ = 1
res = HPIPM.solve([1.0 0; 0 1], [0.0, 0.0];
                  A = reshape([1.0, 1.0], 1, 2), b = [1.0])
res.x          # ≈ [0.5, 0.5]
```

From JuMP:

```julia
using JuMP, HPIPM
m = Model(HPIPM.Optimizer)
@variable(m, x[1:2]); @constraint(m, sum(x) == 1)
@objective(m, Min, x[1]^2 + x[2]^2)
optimize!(m); value.(x)
```

## Tests, examples, docs

```console
$ julia --project=HPIPM -e 'using Pkg; Pkg.test()'
$ julia --project=examples examples/dense_qp.jl
$ julia --project=docs docs/make.jl          # builds the VitePress site (needs Node.js)
```

## Transport to another machine

Copy the repo, run `julia setup.jl` (installs the vendored artifact offline),
`Pkg.instantiate()`, and let Julia precompile. Target must be **x86_64 Linux
(AVX2)**, glibc or musl. See `docs/src/installation.md`.

## Notes

* The Clang-generated struct sizes are unreliable (the generator drops some
  fields), so all HPIPM objects are sized via HPIPM's own `*_strsize()` and read
  through getter functions — never via the generated struct layout. See
  `HPIPM/src/memory.jl`.
* HPIPM owns its BLASFEO panel-major storage; the one column-major→panel-major
  pack inside `set!` is intrinsic. The Julia side adds no copies/allocations.
