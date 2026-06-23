# Dense QP wrapper.
#
# Solves
#
#     min_x  ½ xᵀ H x + gᵀ x
#     s.t.   A x = b                     (ne equality constraints)
#            lb ≤ x[idxb] ≤ ub           (nb box constraints)
#            lg ≤ C x ≤ ug               (ng general polytopic constraints)
#
# `H` (nv×nv) and `C` (ng×nv), `A` (ne×nv) are passed as ordinary column-major
# `Matrix{Float64}`; HPIPM packs them internally into BLASFEO panel-major
# storage (that one pack is intrinsic and accepted). All objects are allocated
# once in `DenseQP`; `set!`/`solve!` perform no Julia allocation.

import .LibHPIPM as L

const _STATUS = (:success, :max_iter, :min_step, :nan_sol, :incons_eq)
_status_symbol(i::Integer) = (0 <= i <= 4) ? _STATUS[Int(i) + 1] : :unknown

"""
    DenseQP(nv; ne=0, nb=0, ng=0, ns=0, mode=BALANCE, iter_max=50, compute_obj=true)

Preallocate a dense QP of the given dimensions. Reuse the object across many
`set!`/`solve!` calls for allocation-free, GC-free re-solves.

* `nv` — number of variables
* `ne` — equality constraints (rows of `A`)
* `nb` — box constraints (defaults `idxb = 0:nb-1`, i.e. the first `nb` vars)
* `ng` — general constraints (rows of `C`)
* `ns` — soft constraints (slacks; advanced)
* `mode` — `SPEED_ABS`, `SPEED`, `BALANCE` (default) or `ROBUST`
"""
mutable struct DenseQP
    nv::Int
    ne::Int
    nb::Int
    ng::Int
    ns::Int
    # managed HPIPM objects (header + data buffers; GC roots). Header sized by
    # strsize(), NOT sizeof(generated struct) — see memory.jl.
    dim::HObj{L.d_dense_qp_dim}
    qp::HObj{L.d_dense_qp}
    sol::HObj{L.d_dense_qp_sol}
    arg::HObj{L.d_dense_qp_ipm_arg}
    ws::HObj{L.d_dense_qp_ipm_ws}
    # persistent index set for box constraints
    idxb::Vector{Cint}
    # bound value/mask scratch (reused; lets ±Inf bounds disable a side)
    lbv::Vector{Float64}; lbm::Vector{Float64}
    ubv::Vector{Float64}; ubm::Vector{Float64}
    lgv::Vector{Float64}; lgm::Vector{Float64}
    ugv::Vector{Float64}; ugm::Vector{Float64}
    # preallocated outputs / scalar scratch
    x::Vector{Float64}
    pi::Vector{Float64}
    _istatus::Base.RefValue{Cint}
    _iiter::Base.RefValue{Cint}
    _dobj::Base.RefValue{Cdouble}
    _dres::Base.RefValue{Cdouble}
end

function DenseQP(nv::Integer; ne::Integer = 0, nb::Integer = 0, ng::Integer = 0,
                 ns::Integer = 0, mode = L.BALANCE, iter_max::Integer = 50,
                 compute_obj::Bool = true)
    nv, ne, nb, ng, ns = Int(nv), Int(ne), Int(nb), Int(ng), Int(ns)

    # --- dim ---
    dim = HObj{L.d_dense_qp_dim}(L.d_dense_qp_dim_strsize(), L.d_dense_qp_dim_memsize())
    GC.@preserve dim begin
        L.d_dense_qp_dim_create(dim.ptr, dim.mem.ptr)
        L.d_dense_qp_dim_set_all(nv, ne, nb, ng, ns, dim.ptr)
    end

    # --- qp ---
    qp = GC.@preserve dim HObj{L.d_dense_qp}(L.d_dense_qp_strsize(), L.d_dense_qp_memsize(dim.ptr))
    GC.@preserve dim qp L.d_dense_qp_create(dim.ptr, qp.ptr, qp.mem.ptr)

    # --- sol ---
    sol = GC.@preserve dim HObj{L.d_dense_qp_sol}(L.d_dense_qp_sol_strsize(), L.d_dense_qp_sol_memsize(dim.ptr))
    GC.@preserve dim sol L.d_dense_qp_sol_create(dim.ptr, sol.ptr, sol.mem.ptr)

    # --- ipm arg ---
    arg = GC.@preserve dim HObj{L.d_dense_qp_ipm_arg}(L.d_dense_qp_ipm_arg_strsize(), L.d_dense_qp_ipm_arg_memsize(dim.ptr))
    GC.@preserve dim arg begin
        L.d_dense_qp_ipm_arg_create(dim.ptr, arg.ptr, arg.mem.ptr)
        L.d_dense_qp_ipm_arg_set_default(mode, arg.ptr)
        L.d_dense_qp_ipm_arg_set_iter_max(Ref(Cint(iter_max)), arg.ptr)
        L.d_dense_qp_ipm_arg_set_compute_obj(Ref(Cint(compute_obj)), arg.ptr)
    end

    # --- ipm workspace (depends on dim AND arg) ---
    ws = GC.@preserve dim arg HObj{L.d_dense_qp_ipm_ws}(L.d_dense_qp_ipm_ws_strsize(), L.d_dense_qp_ipm_ws_memsize(dim.ptr, arg.ptr))
    GC.@preserve dim arg ws L.d_dense_qp_ipm_ws_create(dim.ptr, arg.ptr, ws.ptr, ws.mem.ptr)

    # default box index set: first nb variables (0-based)
    idxb = Cint.(0:(nb - 1))

    obj = DenseQP(nv, ne, nb, ng, ns, dim, qp, sol, arg, ws, idxb,
                  zeros(nb), zeros(nb), zeros(nb), zeros(nb),
                  zeros(ng), zeros(ng), zeros(ng), zeros(ng),
                  zeros(Float64, nv), zeros(Float64, ne),
                  Ref(Cint(0)), Ref(Cint(0)), Ref(0.0), Ref(0.0))

    if nb > 0
        GC.@preserve obj L.d_dense_qp_set_idxb(pointer(obj.idxb), obj.qp.ptr)
    end
    return obj
end

# Pass a column-major matrix / vector pointer to a `d_dense_qp_set_*` setter.
@inline function _set!(setter::F, qp::DenseQP, data::AbstractArray{Float64}) where {F}
    GC.@preserve qp data setter(pointer(data), qp.qp.ptr)
    return nothing
end

# Pass a scalar pointer to an `ipm_arg_set_*` setter.
@inline function _argset!(setter::F, qp::DenseQP, value) where {F}
    GC.@preserve qp setter(Ref(value), qp.arg.ptr)
    return nothing
end

# Set a bound vector plus its mask, translating ±Inf into a disabled side
# (mask = 0). Reuses `valbuf`/`maskbuf` so the call does not allocate.
@inline function _setbound!(setvec::F1, setmask::F2, qp::DenseQP, src,
                            valbuf::Vector{Float64}, maskbuf::Vector{Float64}) where {F1, F2}
    length(src) == length(valbuf) ||
        throw(DimensionMismatch("expected length-$(length(valbuf)) bound, got $(length(src))"))
    @inbounds for i in eachindex(valbuf)
        v = Float64(src[i])
        fin = isfinite(v)
        valbuf[i] = fin ? v : 0.0
        maskbuf[i] = fin ? 1.0 : 0.0
    end
    GC.@preserve qp valbuf setvec(pointer(valbuf), qp.qp.ptr)
    GC.@preserve qp maskbuf setmask(pointer(maskbuf), qp.qp.ptr)
    return nothing
end

"""
    set!(qp::DenseQP; H, g, A, b, C, lb, ub, lg, ug, idxb, mode,
                      iter_max, mu0, tol_stat, tol_eq, tol_ineq, tol_comp, warm_start)

Set any subset of the problem data / solver options in place. Only the provided
keywords are written, so re-solving with a changed `g`/`b`/bounds keeps the
already-packed `H`/`A`/`C`. Matrices must be `Matrix{Float64}` in column-major
order; vectors `Vector{Float64}`; `idxb` a 0-based `Vector{<:Integer}`.
"""
function set!(qp::DenseQP;
              H = nothing, g = nothing, A = nothing, b = nothing, C = nothing,
              lb = nothing, ub = nothing, lg = nothing, ug = nothing,
              idxb = nothing, mode = nothing, iter_max = nothing, mu0 = nothing,
              tol_stat = nothing, tol_eq = nothing, tol_ineq = nothing,
              tol_comp = nothing, warm_start = nothing)
    H  === nothing || _set!(L.d_dense_qp_set_H,  qp, _f64mat(H, qp.nv, qp.nv))
    g  === nothing || _set!(L.d_dense_qp_set_g,  qp, _f64vec(g, qp.nv))
    A  === nothing || _set!(L.d_dense_qp_set_A,  qp, _f64mat(A, qp.ne, qp.nv))
    b  === nothing || _set!(L.d_dense_qp_set_b,  qp, _f64vec(b, qp.ne))
    C  === nothing || _set!(L.d_dense_qp_set_C,  qp, _f64mat(C, qp.ng, qp.nv))
    lb === nothing || _setbound!(L.d_dense_qp_set_lb, L.d_dense_qp_set_lb_mask, qp, lb, qp.lbv, qp.lbm)
    ub === nothing || _setbound!(L.d_dense_qp_set_ub, L.d_dense_qp_set_ub_mask, qp, ub, qp.ubv, qp.ubm)
    lg === nothing || _setbound!(L.d_dense_qp_set_lg, L.d_dense_qp_set_lg_mask, qp, lg, qp.lgv, qp.lgm)
    ug === nothing || _setbound!(L.d_dense_qp_set_ug, L.d_dense_qp_set_ug_mask, qp, ug, qp.ugv, qp.ugm)

    if idxb !== nothing
        length(idxb) == qp.nb || throw(DimensionMismatch("idxb must have length nb=$(qp.nb)"))
        @inbounds for i in eachindex(qp.idxb)
            qp.idxb[i] = Cint(idxb[i])
        end
        GC.@preserve qp L.d_dense_qp_set_idxb(pointer(qp.idxb), qp.qp.ptr)
    end

    mode       === nothing || GC.@preserve qp L.d_dense_qp_ipm_arg_set_default(mode, qp.arg.ptr)
    iter_max   === nothing || _argset!(L.d_dense_qp_ipm_arg_set_iter_max, qp, Cint(iter_max))
    mu0        === nothing || _argset!(L.d_dense_qp_ipm_arg_set_mu0, qp, Float64(mu0))
    tol_stat   === nothing || _argset!(L.d_dense_qp_ipm_arg_set_tol_stat, qp, Float64(tol_stat))
    tol_eq     === nothing || _argset!(L.d_dense_qp_ipm_arg_set_tol_eq, qp, Float64(tol_eq))
    tol_ineq   === nothing || _argset!(L.d_dense_qp_ipm_arg_set_tol_ineq, qp, Float64(tol_ineq))
    tol_comp   === nothing || _argset!(L.d_dense_qp_ipm_arg_set_tol_comp, qp, Float64(tol_comp))
    warm_start === nothing || _argset!(L.d_dense_qp_ipm_arg_set_warm_start, qp, Cint(warm_start))
    return qp
end

"""
    set_g!(qp, g);  set_b!(qp, b);  set_H!(qp, H);  set_A!(qp, A);  set_C!(qp, C)

Dedicated zero-allocation in-place setters for the hot loop (no keyword
overhead). Pass contiguous `Vector{Float64}` / `Matrix{Float64}` to avoid any
conversion copy. Useful for re-solving when only part of the data changes (e.g.
update `g` each iteration while `H` stays packed).
"""
set_g!(qp::DenseQP, g::AbstractVector{Float64}) = _set!(L.d_dense_qp_set_g, qp, _f64vec(g, qp.nv))
set_b!(qp::DenseQP, b::AbstractVector{Float64}) = _set!(L.d_dense_qp_set_b, qp, _f64vec(b, qp.ne))
set_H!(qp::DenseQP, H::AbstractMatrix{Float64}) = _set!(L.d_dense_qp_set_H, qp, _f64mat(H, qp.nv, qp.nv))
set_A!(qp::DenseQP, A::AbstractMatrix{Float64}) = _set!(L.d_dense_qp_set_A, qp, _f64mat(A, qp.ne, qp.nv))
set_C!(qp::DenseQP, C::AbstractMatrix{Float64}) = _set!(L.d_dense_qp_set_C, qp, _f64mat(C, qp.ng, qp.nv))

"""
    solve!(qp::DenseQP) -> Symbol

Run the interior-point solve in place (no allocation). Returns the status symbol
(`:success`, `:max_iter`, `:min_step`, `:nan_sol`, `:incons_eq`). Read results
with [`primal`](@ref), [`objective`](@ref), [`iterations`](@ref) etc.
"""
function solve!(qp::DenseQP)
    GC.@preserve qp begin
        L.d_dense_qp_ipm_solve(qp.qp.ptr, qp.sol.ptr, qp.arg.ptr, qp.ws.ptr)
        L.d_dense_qp_ipm_get_status(qp.ws.ptr, qp._istatus)
        L.d_dense_qp_ipm_get_iter(qp.ws.ptr, qp._iiter)
        L.d_dense_qp_ipm_get_obj(qp.ws.ptr, qp._dobj)
        L.d_dense_qp_sol_get_v(qp.sol.ptr, pointer(qp.x))
        qp.ne > 0 && L.d_dense_qp_sol_get_pi(qp.sol.ptr, pointer(qp.pi))
    end
    return _status_symbol(qp._istatus[])
end

# --- accessors (read in-place buffers; no allocation except where noted) ---

"""`status(qp)` — solver status as a `Symbol`."""
status(qp::DenseQP) = _status_symbol(qp._istatus[])
"""`iterations(qp)` — interior-point iterations taken."""
iterations(qp::DenseQP) = Int(qp._iiter[])
"""`objective(qp)` — optimal objective value (requires `compute_obj=true`)."""
objective(qp::DenseQP) = qp._dobj[]
"""`primal(qp)` — optimal primal `x` (the live internal buffer; `copy` to keep)."""
primal(qp::DenseQP) = qp.x
"""`dual_eq(qp)` — equality-constraint multipliers `π` (live buffer)."""
dual_eq(qp::DenseQP) = qp.pi

"""`residuals(qp)` — NamedTuple of max KKT residuals (stationarity/eq/ineq/comp)."""
function residuals(qp::DenseQP)
    GC.@preserve qp begin
        L.d_dense_qp_ipm_get_max_res_stat(qp.ws.ptr, qp._dres); stat = qp._dres[]
        L.d_dense_qp_ipm_get_max_res_eq(qp.ws.ptr, qp._dres);   eq = qp._dres[]
        L.d_dense_qp_ipm_get_max_res_ineq(qp.ws.ptr, qp._dres); ineq = qp._dres[]
        L.d_dense_qp_ipm_get_max_res_comp(qp.ws.ptr, qp._dres); comp = qp._dres[]
    end
    return (; stat, eq, ineq, comp)
end

# --- input coercion helpers (validate dims; reuse contiguous Float64 arrays) ---

function _f64mat(M::AbstractMatrix, m::Int, n::Int)
    size(M) == (m, n) || throw(DimensionMismatch("expected $(m)×$(n) matrix, got $(size(M))"))
    return M isa Matrix{Float64} ? M : Matrix{Float64}(M)
end
function _f64vec(v::AbstractVector, n::Int)
    length(v) == n || throw(DimensionMismatch("expected length-$n vector, got $(length(v))"))
    return v isa Vector{Float64} ? v : Vector{Float64}(v)
end

"""
    solve(H, g; A, b, C, lb, ub, lg, ug, idxb, mode=BALANCE, kwargs...) -> NamedTuple

One-shot convenience: build a `DenseQP`, set the data, solve, and return
`(; x, objective, status, iterations, pi, residuals)`. For repeated solves of the
same size, build a `DenseQP` once and reuse it instead.
"""
function solve(H::AbstractMatrix, g::AbstractVector;
               A = nothing, b = nothing, C = nothing,
               lb = nothing, ub = nothing, lg = nothing, ug = nothing,
               idxb = nothing, mode = L.BALANCE, kwargs...)
    nv = length(g)
    ne = A === nothing ? 0 : size(A, 1)
    ng = C === nothing ? 0 : size(C, 1)
    nb = idxb !== nothing ? length(idxb) :
         (lb !== nothing ? length(lb) : (ub !== nothing ? length(ub) : 0))
    qp = DenseQP(nv; ne, nb, ng, mode, kwargs...)
    set!(qp; H, g, A, b, C, lb, ub, lg, ug, idxb)
    st = solve!(qp)
    return (; x = copy(qp.x), objective = objective(qp), status = st,
            iterations = iterations(qp), pi = copy(qp.pi), residuals = residuals(qp))
end
