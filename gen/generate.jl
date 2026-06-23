#!/usr/bin/env julia
#
# Reproducible binding generator for HPIPM.jl.
#
#   julia --project=gen gen/generate.jl
#
# Regenerates `HPIPM/src/LibHPIPM.jl` from the HPIPM/BLASFEO headers shipped in
# the `HPIPM_jll` artifact, using the options in `gen/generator.toml`.
#
# Curated header list: the public double-precision HPIPM API plus the handful of
# BLASFEO headers we need (common types + double aux: create/pack/unpack). This
# avoids dragging in the ~1500 micro-kernel / reference / single-precision
# declarations that bloated the original output.
#
# NOTE: the runtime wrapper never relies on the generated struct *layout* (some
# fields are dropped by Clang); object sizes come from HPIPM's `*_strsize()`
# instead (see HPIPM/src/memory.jl). So regenerating is safe.

using Clang.Generators
using HPIPM_jll

const INCLUDE = joinpath(HPIPM_jll.artifact_dir, "include")

# Curated, double-precision-focused header set.
const HPIPM_HEADERS = [
    "hpipm_common.h",
    "hpipm_timing.h",
    # dense QP / QCQP
    "hpipm_d_dense_qp_dim.h",
    "hpipm_d_dense_qp.h",
    "hpipm_d_dense_qp_sol.h",
    "hpipm_d_dense_qp_res.h",
    "hpipm_d_dense_qp_ipm.h",
    "hpipm_d_dense_qp_utils.h",
    # OCP QP
    "hpipm_d_ocp_qp_dim.h",
    "hpipm_d_ocp_qp.h",
    "hpipm_d_ocp_qp_sol.h",
    "hpipm_d_ocp_qp_res.h",
    "hpipm_d_ocp_qp_ipm.h",
    "hpipm_d_ocp_qp_utils.h",
]

const BLASFEO_HEADERS = [
    "blasfeo_target.h",
    "blasfeo_common.h",         # blasfeo_dmat / blasfeo_dvec
    "blasfeo_d_aux.h",          # memsize/create/pack/unpack_dmat/dvec
    "blasfeo_d_aux_ext_dep.h",
]

function main()
    options = load_options(joinpath(@__DIR__, "generator.toml"))
    # resolve the output path relative to this script, not the caller's cwd
    options["general"]["output_file_path"] =
        normpath(joinpath(@__DIR__, "..", "HPIPM", "src", "LibHPIPM.jl"))
    args = get_default_args()
    push!(args, "-I$INCLUDE")

    headers = String[]
    for h in vcat(HPIPM_HEADERS, BLASFEO_HEADERS)
        p = joinpath(INCLUDE, h)
        isfile(p) ? push!(headers, p) : @warn "header not found, skipping" header = p
    end

    ctx = create_context(headers, args, options)
    build!(ctx)
    @info "Regenerated $(options["general"]["output_file_path"])"
end

main()
