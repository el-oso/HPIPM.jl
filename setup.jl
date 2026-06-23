#!/usr/bin/env julia
#
# One-shot, OFFLINE installer for the vendored HPIPM binary artifact.
#
# Run this ONCE per machine (and per Julia depot) before instantiating the
# project:
#
#     julia setup.jl
#     julia --project=HPIPM -e 'using Pkg; Pkg.instantiate()'
#
# It unpacks the prebuilt tarball in `HPIPM_jll/tarballs/` straight into this
# depot's artifact store, keyed by the git-tree-sha1 recorded in
# `HPIPM_jll/Artifacts.toml`. No network or package registry is required.

using Pkg.Artifacts: artifact_exists, artifact_path
using Pkg.PlatformEngines: unpack
using Base.BinaryPlatforms: HostPlatform, libc
using Base: SHA1

const ROOT = @__DIR__

# (git-tree-sha1, tarball filename) per libc, matching HPIPM_jll/Artifacts.toml.
const ARTIFACTS = Dict(
    "glibc" => (
        SHA1("452e1bfdf3cd9e872c874a1b57429e35c3b5069a"),
        "HPIPM.v0.1.4.x86_64-linux-gnu-march+avx2.tar.gz",
    ),
    "musl" => (
        SHA1("263971260f6b3859a6e38ff7fac06b068423966d"),
        "HPIPM.v0.1.4.x86_64-linux-musl-march+avx2.tar.gz",
    ),
)

function main()
    Sys.islinux() || error("This vendored build targets x86_64 Linux only " *
                           "(host: $(Sys.MACHINE)). Rebuild jll/build_tarballs.jl " *
                           "for other platforms.")
    host_libc = libc(HostPlatform())
    haskey(ARTIFACTS, host_libc) ||
        error("No vendored HPIPM tarball for libc=$host_libc.")
    hash, tarname = ARTIFACTS[host_libc]

    if artifact_exists(hash)
        @info "HPIPM artifact already installed" hash=bytes2hex(hash.bytes)
        return
    end

    tarball = joinpath(ROOT, "HPIPM_jll", "tarballs", tarname)
    isfile(tarball) || error("Vendored tarball missing: $tarball")

    dest = artifact_path(hash)
    @info "Installing HPIPM artifact offline" tarball dest
    mkpath(dirname(dest))
    unpack(tarball, dest)

    artifact_exists(hash) ||
        error("Unpack finished but artifact not found at $dest — hash mismatch?")
    @info "HPIPM artifact installed successfully" hash=bytes2hex(hash.bytes)
end

main()
