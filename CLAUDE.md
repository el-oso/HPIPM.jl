# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

HPIPM.jl wraps [giaf/hpipm](https://github.com/giaf/hpipm) (interior-point dense/OCP QP
solver, built on BLASFEO) for Julia, with a MathOptInterface layer.

## Mono-repo layout

This is a multi-package repo, not a single package:

- `HPIPM/` — the `HPIPM.jl` package. Depends on `HPIPM_jll` via a **relative path**
  (`../HPIPM_jll`), so always activate `--project=HPIPM`.
- `HPIPM_jll/` — a hand-built JLL that vendors the prebuilt `libhpipm.so` tarballs
  (`HPIPM_jll/tarballs/`). Not from the registry.
- `gen/` — the Clang.jl binding generator (`generator.toml` + `generate.jl`).
- `jll/build_tarballs.jl` — BinaryBuilder recipe (rebuilds the binaries / future Yggdrasil).
- `docs/`, `examples/` — each is its own Julia environment with its own `Project.toml`.
- `setup.jl` — installs the vendored binary artifact into the local depot, offline.

## First-time / new-machine setup (required before anything works)

The library is **not auto-downloaded**. Run once per machine/depot:

```bash
julia setup.jl                                          # offline artifact install
julia --project=HPIPM -e 'using Pkg; Pkg.instantiate()'
```

`setup.jl` unpacks the tarball whose `git-tree-sha1` matches `HPIPM_jll/Artifacts.toml`
into the depot artifact store, so `using HPIPM_jll` resolves with no network. Target must
be **x86_64 Linux + AVX2** (glibc or musl). If `using HPIPM` fails with "Artifact \"HPIPM\"
was not found", `setup.jl` was not run.

## Common commands

```bash
# tests (all 35)
julia --project=HPIPM -e 'using Pkg; Pkg.test()'

# run one test file standalone (HPIPM + JuMP + Test must be available)
julia --project=HPIPM/test -e 'using Pkg; Pkg.develop(path="HPIPM"); include("HPIPM/test/test_dense_qp.jl")'

# examples
julia --project=examples examples/dense_qp.jl     # also: dense_qp_reuse, ocp_qp, jump_moi

# docs (DocumenterVitepress; needs Node.js, which is present)
julia --project=docs docs/make.jl

# regenerate bindings into HPIPM/src/LibHPIPM.jl
julia --project=gen gen/generate.jl
```

When adding dependencies, use `Pkg.add`/`Pkg.develop` — never hand-write UUIDs.

## Architecture: the C-object memory protocol (read this before touching the wrappers)

HPIPM objects are created with a manual two-step protocol that the whole wrapper is built
around. For each object (`dim`, `qp`, `sol`, `ipm_arg`, `ipm_ws`):

1. `strsize = d_*_strsize()` — size of the struct header.
2. `memsize = d_*_memsize(...)` — size of the object's internal data.
3. `d_*_create(..., header_ptr, data_ptr)` — placement-constructs into caller memory.

**Critical, non-obvious invariant:** the Clang-generated Julia structs in `LibHPIPM.jl`
have the WRONG size — the generator silently drops fields (e.g. `d_dense_qp_ipm_ws` is
456 B in C but 432 B generated). Sizing a header from `sizeof(generated struct)` (or using
`Ref{T}()`) overflows the box and corrupts the Julia heap → segfaults during GC. Therefore:

- Header memory is sized from HPIPM's own `*_strsize()`, never from `sizeof`.
- Results are read **only through getter functions** (`*_sol_get_v`, `*_ipm_get_*`), never
  by reading struct fields. The generated struct layout must never be trusted at runtime.

`HPIPM/src/memory.jl` implements this: `AlignedBuffer` (64-byte aligned, BLASFEO needs it)
and `HObj{T}` (a `strsize` header buffer + `memsize` data buffer + typed pointer, both GC
roots). All ccalls pass `.ptr`/`.mem.ptr` and are wrapped in `GC.@preserve`.

## Architecture: layering and the zero-allocation contract

```
LibHPIPM.jl (generated @ccall bindings)
  → memory.jl   (HObj / AlignedBuffer)
  → dense_qp.jl (DenseQP) / ocp_qp.jl (OCPQP)   ← direct API
  → moi_wrapper.jl (HPIPM.Optimizer)            ← MathOptInterface / JuMP
```

- `DenseQP`/`OCPQP` allocate all C objects once in the constructor; `set!`/`solve!` then
  perform **no Julia allocation** (verified by `test_alloc`-style checks). Input matrices
  are passed by `pointer(...)` under `GC.@preserve` — no Julia copy. The only copy is
  HPIPM's intrinsic column-major→BLASFEO panel-major pack inside `set!`, which is accepted.
- For the hot loop use the dedicated setters (`set_g!`, `set_b!`, `set_H!`, ...) — they skip
  the keyword-`set!` overhead and allocate nothing.
- `±Inf` in any bound is translated to an HPIPM **mask** (`set_*_mask`), not a large finite
  value — a `1e30` upper bound prevents the complementarity residual from converging.
- `moi_wrapper.jl` uses the `copy_to` pattern (`supports_incremental_interface = false`);
  JuMP wraps it in a CachingOptimizer. It assembles dense `H,g,A,b,C` and maps MOI's
  quadratic convention (diagonal coef `α` ⇒ `½α xᵢ²`) onto HPIPM's `½xᵀHx`.

## The JLL and binaries

`jll/build_tarballs.jl` pins blasfeo + hpipm by commit (currently == upstream `master`).
BLASFEO is linked **statically** into `libhpipm.so` but its symbols are exported, so the
single `LibraryProduct(:libhpipm)` covers both. To change the binaries, edit the recipe,
rebuild, recompute the `git-tree-sha1`/`sha256` in `HPIPM_jll/Artifacts.toml`, and re-vendor
the tarball under `HPIPM_jll/tarballs/`. The registered `HPIPM_jll` (once on Yggdrasil) is a
drop-in replacement for the path dep.

## Regenerating bindings

`gen/generate.jl` feeds a **curated** double-precision header list to Clang.jl and applies
`gen/generator.toml` (`output_ignorelist` drops `^kernel_`/`_ref$`/single-precision;
`use_ccall_macro`; doxygen comments). This keeps the output ~643 functions instead of ~5300.
Regeneration is safe despite the struct-size bug because of the `strsize` design above.
