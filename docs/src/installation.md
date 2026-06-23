# Installation & transport

This repository is a small mono-repo:

```
HPIPM/        # the HPIPM.jl package
HPIPM_jll/    # a self-contained, in-repo JLL wrapping the prebuilt binaries
jll/          # build_tarballs.jl (for an eventual Yggdrasil submission)
docs/  examples/  setup.jl
```

`HPIPM` depends on the in-repo `HPIPM_jll` via a relative path, and the actual
shared library (`libhpipm.so`, with BLASFEO statically linked) ships as a tarball
inside `HPIPM_jll/tarballs/`. Nothing is downloaded.

## First-time setup on a machine

The binaries are installed into the local depot's artifact store from the
vendored tarball — once per machine/depot, offline:

```console
$ julia setup.jl
$ julia --project=HPIPM -e 'using Pkg; Pkg.instantiate()'
$ julia --project=HPIPM -e 'using HPIPM'      # precompiles
```

`setup.jl` unpacks the tarball whose `git-tree-sha1` matches the binding in
`HPIPM_jll/Artifacts.toml`, so `using HPIPM_jll` resolves with no network access.

## Moving to another computer

Because everything is in the repo, transport is just a copy:

1. Copy the whole `HPIPM/` repository to the target machine.
2. Run `julia setup.jl` there (installs the vendored artifact offline).
3. `Pkg.instantiate()` and let Julia precompile.

The target must be **x86_64 Linux with AVX2** (glibc or musl), matching the
prebuilt binaries. For other architectures, rebuild `jll/build_tarballs.jl`.

## Requirements

* Julia ≥ 1.6 (developed and tested on 1.12).
* For the docs only: Node.js (VitePress) — already handled by `DocumenterVitepress`.

## Future: registered `HPIPM_jll`

`jll/build_tarballs.jl` is ready to submit to
[Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil). Once `HPIPM_jll` is
registered in the General registry, drop the path dependency and add the
registered package — the API is identical, so no code changes are needed.
