# OCP QP wrapper (structured / model-predictive-control form).
#
# Stages k = 0 … N with state xₖ (nx[k]) and input uₖ (nu[k], with nu[N]=0):
#
#     min  Σₖ ½ [xₖ;uₖ]ᵀ [Qₖ Sₖᵀ; Sₖ Rₖ] [xₖ;uₖ] + [qₖ;rₖ]ᵀ [xₖ;uₖ]
#     s.t. x_{k+1} = Aₖ xₖ + Bₖ uₖ + bₖ          k = 0 … N-1
#          box bounds on xₖ (idxbx) and uₖ (idxbu)
#
# Per-stage data may be given once (applied to every stage in range) or as a
# vector with one entry per stage. Dimensions can be constant (pass an `Int`) or
# per-stage (pass a length-(N+1) `Vector{Int}`). All HPIPM objects are allocated
# once; `solve!` performs no allocation.

import .LibHPIPM as L

mutable struct OCPQP
    N::Int
    nx::Vector{Int}
    nu::Vector{Int}
    nbx::Vector{Int}
    nbu::Vector{Int}
    ng::Vector{Int}
    dim::HObj{L.d_ocp_qp_dim}
    qp::HObj{L.d_ocp_qp}
    sol::HObj{L.d_ocp_qp_sol}
    arg::HObj{L.d_ocp_qp_ipm_arg}
    ws::HObj{L.d_ocp_qp_ipm_ws}
    idxbx::Vector{Vector{Cint}}   # per-stage box index sets (GC roots)
    idxbu::Vector{Vector{Cint}}
    xtraj::Vector{Vector{Float64}}  # output state trajectory (per stage)
    utraj::Vector{Vector{Float64}}  # output input trajectory (per stage)
    _istatus::Base.RefValue{Cint}
    _iiter::Base.RefValue{Cint}
end

_asvec(x::Integer, n) = fill(Int(x), n)
_asvec(x::AbstractVector, n) = (length(x) == n || throw(DimensionMismatch("expected length-$n dim vector")); Int.(x))

"""
    OCPQP(N; nx, nu, nbx=0, nbu=0, ng=0, mode=BALANCE, iter_max=50)

Preallocate an OCP QP over horizon `N` (stages `0:N`). `nx`/`nu`/`nbx`/`nbu`/`ng`
are either an `Int` (constant across stages) or a length-`N+1` vector. `nu[N]` is
forced to `0` (no control at the terminal stage).
"""
function OCPQP(N::Integer; nx, nu, nbx = 0, nbu = 0, ng = 0,
              mode = L.BALANCE, iter_max::Integer = 50)
    N = Int(N)
    ns = N + 1
    nxv = _asvec(nx, ns)
    nuv = _asvec(nu, ns); nuv[end] = 0
    nbxv = _asvec(nbx, ns)
    nbuv = _asvec(nbu, ns); nbuv[end] = 0
    ngv = _asvec(ng, ns)

    dim = HObj{L.d_ocp_qp_dim}(L.d_ocp_qp_dim_strsize(), L.d_ocp_qp_dim_memsize(N))
    GC.@preserve dim begin
        L.d_ocp_qp_dim_create(N, dim.ptr, dim.mem.ptr)
        for k in 0:N
            L.d_ocp_qp_dim_set_nx(k, nxv[k + 1], dim.ptr)
            L.d_ocp_qp_dim_set_nu(k, nuv[k + 1], dim.ptr)
            L.d_ocp_qp_dim_set_nbx(k, nbxv[k + 1], dim.ptr)
            L.d_ocp_qp_dim_set_nbu(k, nbuv[k + 1], dim.ptr)
            L.d_ocp_qp_dim_set_ng(k, ngv[k + 1], dim.ptr)
        end
    end

    qp = GC.@preserve dim HObj{L.d_ocp_qp}(L.d_ocp_qp_strsize(), L.d_ocp_qp_memsize(dim.ptr))
    GC.@preserve dim qp L.d_ocp_qp_create(dim.ptr, qp.ptr, qp.mem.ptr)

    sol = GC.@preserve dim HObj{L.d_ocp_qp_sol}(L.d_ocp_qp_sol_strsize(), L.d_ocp_qp_sol_memsize(dim.ptr))
    GC.@preserve dim sol L.d_ocp_qp_sol_create(dim.ptr, sol.ptr, sol.mem.ptr)

    arg = GC.@preserve dim HObj{L.d_ocp_qp_ipm_arg}(L.d_ocp_qp_ipm_arg_strsize(), L.d_ocp_qp_ipm_arg_memsize(dim.ptr))
    GC.@preserve dim arg begin
        L.d_ocp_qp_ipm_arg_create(dim.ptr, arg.ptr, arg.mem.ptr)
        L.d_ocp_qp_ipm_arg_set_default(mode, arg.ptr)
        L.d_ocp_qp_ipm_arg_set_iter_max(Ref(Cint(iter_max)), arg.ptr)
    end

    ws = GC.@preserve dim arg HObj{L.d_ocp_qp_ipm_ws}(L.d_ocp_qp_ipm_ws_strsize(), L.d_ocp_qp_ipm_ws_memsize(dim.ptr, arg.ptr))
    GC.@preserve dim arg ws L.d_ocp_qp_ipm_ws_create(dim.ptr, arg.ptr, ws.ptr, ws.mem.ptr)

    idxbx = [Cint.(0:(nbxv[k + 1] - 1)) for k in 0:N]
    idxbu = [Cint.(0:(nbuv[k + 1] - 1)) for k in 0:N]
    xtraj = [zeros(nxv[k + 1]) for k in 0:N]
    utraj = [zeros(nuv[k + 1]) for k in 0:N]

    ocp = OCPQP(N, nxv, nuv, nbxv, nbuv, ngv, dim, qp, sol, arg, ws,
                idxbx, idxbu, xtraj, utraj, Ref(Cint(0)), Ref(Cint(0)))

    # register the (default, full) box index sets where present
    GC.@preserve ocp for k in 0:N
        nbxv[k + 1] > 0 && L.d_ocp_qp_set_idxbx(k, pointer(ocp.idxbx[k + 1]), ocp.qp.ptr)
        nbuv[k + 1] > 0 && L.d_ocp_qp_set_idxbu(k, pointer(ocp.idxbu[k + 1]), ocp.qp.ptr)
    end
    return ocp
end

# constant-vs-per-stage data selector
_stage(x::AbstractMatrix, k) = x
_stage(x::AbstractVector{<:Real}, k) = x
_stage(x::AbstractVector{<:AbstractArray}, k) = x[k + 1]

@inline function _ocp_set!(setter::F, ocp::OCPQP, k::Int, data) where {F}
    d = data isa Matrix{Float64} || data isa Vector{Float64} ? data : collect(Float64, data)
    GC.@preserve ocp d setter(Cint(k), pointer(d), ocp.qp.ptr)
    return nothing
end

"""
    set!(ocp::OCPQP; A, B, b, Q, S, R, q, r, lbx, ubx, lbu, ubu, x0)

Set OCP data in place. Dynamics `A,B,b` apply to stages `0:N-1`; cost `R,S,r` to
`0:N-1`, `Q,q` to `0:N`; bounds `lbu,ubu` to `0:N-1`, `lbx,ubx` to `0:N`. Each
argument is either a single array (used on every stage in range) or a length
vector of per-stage arrays. `x0` pins the initial state via stage-0 box bounds
(requires the constructor's `nbx[0] == nx[0]`).
"""
function set!(ocp::OCPQP;
              A = nothing, B = nothing, b = nothing,
              Q = nothing, S = nothing, R = nothing, q = nothing, r = nothing,
              lbx = nothing, ubx = nothing, lbu = nothing, ubu = nothing,
              x0 = nothing)
    N = ocp.N
    for k in 0:(N - 1)
        A === nothing || _ocp_set!(L.d_ocp_qp_set_A, ocp, k, _stage(A, k))
        B === nothing || _ocp_set!(L.d_ocp_qp_set_B, ocp, k, _stage(B, k))
        b === nothing || _ocp_set!(L.d_ocp_qp_set_b, ocp, k, _stage(b, k))
        R === nothing || _ocp_set!(L.d_ocp_qp_set_R, ocp, k, _stage(R, k))
        S === nothing || _ocp_set!(L.d_ocp_qp_set_S, ocp, k, _stage(S, k))
        r === nothing || _ocp_set!(L.d_ocp_qp_set_r, ocp, k, _stage(r, k))
        lbu === nothing || _ocp_set!(L.d_ocp_qp_set_lbu, ocp, k, _stage(lbu, k))
        ubu === nothing || _ocp_set!(L.d_ocp_qp_set_ubu, ocp, k, _stage(ubu, k))
    end
    for k in 0:N
        Q === nothing || _ocp_set!(L.d_ocp_qp_set_Q, ocp, k, _stage(Q, k))
        q === nothing || _ocp_set!(L.d_ocp_qp_set_q, ocp, k, _stage(q, k))
        lbx === nothing || _ocp_set!(L.d_ocp_qp_set_lbx, ocp, k, _stage(lbx, k))
        ubx === nothing || _ocp_set!(L.d_ocp_qp_set_ubx, ocp, k, _stage(ubx, k))
    end
    if x0 !== nothing
        x0v = collect(Float64, x0)
        GC.@preserve ocp x0v begin
            L.d_ocp_qp_set_lbx(Cint(0), pointer(x0v), ocp.qp.ptr)
            L.d_ocp_qp_set_ubx(Cint(0), pointer(x0v), ocp.qp.ptr)
        end
    end
    return ocp
end

"""
    solve!(ocp::OCPQP) -> Symbol

Solve the OCP in place. Returns a status symbol; read the trajectories with
[`state`](@ref)/[`input`](@ref) or [`states`](@ref)/[`inputs`](@ref).
"""
function solve!(ocp::OCPQP)
    GC.@preserve ocp begin
        L.d_ocp_qp_ipm_solve(ocp.qp.ptr, ocp.sol.ptr, ocp.arg.ptr, ocp.ws.ptr)
        L.d_ocp_qp_ipm_get_status(ocp.ws.ptr, ocp._istatus)
        L.d_ocp_qp_ipm_get_iter(ocp.ws.ptr, ocp._iiter)
        for k in 0:ocp.N
            L.d_ocp_qp_sol_get_x(Cint(k), ocp.sol.ptr, pointer(ocp.xtraj[k + 1]))
            ocp.nu[k + 1] > 0 &&
                L.d_ocp_qp_sol_get_u(Cint(k), ocp.sol.ptr, pointer(ocp.utraj[k + 1]))
        end
    end
    return _status_symbol(ocp._istatus[])
end

status(ocp::OCPQP) = _status_symbol(ocp._istatus[])
iterations(ocp::OCPQP) = Int(ocp._iiter[])
"""`state(ocp, k)` — optimal state xₖ (live buffer)."""
state(ocp::OCPQP, k::Integer) = ocp.xtraj[k + 1]
"""`input(ocp, k)` — optimal input uₖ (live buffer)."""
input(ocp::OCPQP, k::Integer) = ocp.utraj[k + 1]
"""`states(ocp)` — vector of optimal states x₀…x_N."""
states(ocp::OCPQP) = ocp.xtraj
"""`inputs(ocp)` — vector of optimal inputs u₀…u_{N-1}."""
inputs(ocp::OCPQP) = ocp.utraj[1:ocp.N]
