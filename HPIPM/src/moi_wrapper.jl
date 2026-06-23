# MathOptInterface wrapper for the dense QP backend.
#
# Exposes `HPIPM.Optimizer`, usable from JuMP, for problems of the form
#
#     min/max  ½ xᵀ H x + gᵀ x + c
#     s.t.     box bounds on variables               (VariableIndex in sets)
#              affine == b                            (ScalarAffine in EqualTo)
#              lg ≤ affine ≤ ug                       (ScalarAffine in {LT,GT,Interval})
#
# The solver consumes the whole problem at once, so we implement the `copy_to`
# interface (JuMP wraps us in a CachingOptimizer automatically).

import MathOptInterface as MOI

const SAF = MOI.ScalarAffineFunction{Float64}
const SQF = MOI.ScalarQuadraticFunction{Float64}
const VI = MOI.VariableIndex
const _SCALAR_SETS = Union{MOI.LessThan{Float64},MOI.GreaterThan{Float64},
                           MOI.EqualTo{Float64},MOI.Interval{Float64}}

"""
    HPIPM.Optimizer()

A MathOptInterface optimizer backed by HPIPM's dense interior-point QP solver.
Use from JuMP with `Model(HPIPM.Optimizer)`. Set options with
`MOI.RawOptimizerAttribute(name)`, e.g. `"iter_max"`, `"mode"`, `"tol_stat"`,
or `MOI.Silent()`.
"""
mutable struct Optimizer <: MOI.AbstractOptimizer
    # options
    silent::Bool
    options::Dict{String,Any}

    # assembled problem (filled by copy_to)
    nv::Int
    sense::MOI.OptimizationSense
    objsign::Float64                 # +1 for min, -1 for max
    objconst::Float64
    H::Matrix{Float64}
    g::Vector{Float64}
    A::Matrix{Float64}
    b::Vector{Float64}
    C::Matrix{Float64}
    lg::Vector{Float64}
    ug::Vector{Float64}
    idxb::Vector{Int}                # 0-based bounded columns
    lb::Vector{Float64}
    ub::Vector{Float64}

    # bookkeeping for results / duals
    var_col::Dict{VI,Int}
    eq_cis::Vector{MOI.ConstraintIndex{SAF,MOI.EqualTo{Float64}}}
    gen_cis::Vector{Tuple{MOI.ConstraintIndex,Int}}   # (ci, general-row)
    bnd_col::Dict{MOI.ConstraintIndex,Int}            # variable-bound ci -> column

    # results
    solved::Bool
    term_status::MOI.TerminationStatusCode
    primal_status::MOI.ResultStatusCode
    raw_status::Symbol
    iters::Int
    solve_time::Float64
    x::Vector{Float64}
    obj::Float64
    pi::Vector{Float64}              # equality multipliers
    lam_lb::Vector{Float64}
    lam_ub::Vector{Float64}
    lam_lg::Vector{Float64}
    lam_ug::Vector{Float64}
end

function Optimizer()
    return Optimizer(false, Dict{String,Any}(),
                     0, MOI.MIN_SENSE, 1.0, 0.0,
                     zeros(0, 0), Float64[], zeros(0, 0), Float64[],
                     zeros(0, 0), Float64[], Float64[], Int[], Float64[], Float64[],
                     Dict{VI,Int}(), MOI.ConstraintIndex{SAF,MOI.EqualTo{Float64}}[],
                     Tuple{MOI.ConstraintIndex,Int}[], Dict{MOI.ConstraintIndex,Int}(),
                     false, MOI.OPTIMIZE_NOT_CALLED, MOI.NO_SOLUTION, :unsolved,
                     0, 0.0, Float64[], NaN, Float64[],
                     Float64[], Float64[], Float64[], Float64[])
end

MOI.get(::Optimizer, ::MOI.SolverName) = "HPIPM"
MOI.get(opt::Optimizer, ::MOI.SolverVersion) = "0.1.4"

# ---- options ----
MOI.supports(::Optimizer, ::MOI.Silent) = true
MOI.set(opt::Optimizer, ::MOI.Silent, v::Bool) = (opt.silent = v; nothing)
MOI.get(opt::Optimizer, ::MOI.Silent) = opt.silent
MOI.supports(::Optimizer, ::MOI.RawOptimizerAttribute) = true
MOI.set(opt::Optimizer, a::MOI.RawOptimizerAttribute, v) = (opt.options[a.name] = v; nothing)
MOI.get(opt::Optimizer, a::MOI.RawOptimizerAttribute) = opt.options[a.name]

# ---- empty / copy_to interface ----
function MOI.is_empty(opt::Optimizer)
    return opt.nv == 0 && isempty(opt.var_col) && !opt.solved
end

function MOI.empty!(opt::Optimizer)
    opt.nv = 0
    opt.sense = MOI.MIN_SENSE
    opt.objsign = 1.0
    opt.objconst = 0.0
    opt.H = zeros(0, 0); opt.g = Float64[]
    opt.A = zeros(0, 0); opt.b = Float64[]
    opt.C = zeros(0, 0); opt.lg = Float64[]; opt.ug = Float64[]
    opt.idxb = Int[]; opt.lb = Float64[]; opt.ub = Float64[]
    empty!(opt.var_col); empty!(opt.eq_cis); empty!(opt.gen_cis); empty!(opt.bnd_col)
    opt.solved = false
    opt.term_status = MOI.OPTIMIZE_NOT_CALLED
    opt.primal_status = MOI.NO_SOLUTION
    opt.raw_status = :unsolved
    opt.iters = 0; opt.solve_time = 0.0
    opt.x = Float64[]; opt.obj = NaN; opt.pi = Float64[]
    opt.lam_lb = Float64[]; opt.lam_ub = Float64[]
    opt.lam_lg = Float64[]; opt.lam_ug = Float64[]
    return nothing
end

MOI.supports_incremental_interface(::Optimizer) = false

# supported objective / constraints
MOI.supports(::Optimizer, ::MOI.ObjectiveSense) = true
MOI.supports(::Optimizer, ::MOI.ObjectiveFunction{<:Union{VI,SAF,SQF}}) = true
MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{<:_SCALAR_SETS}) = true
MOI.supports_constraint(::Optimizer, ::Type{SAF}, ::Type{<:_SCALAR_SETS}) = true

function MOI.copy_to(dest::Optimizer, src::MOI.ModelLike)
    MOI.empty!(dest)
    idxmap = MOI.Utilities.IndexMap()

    # --- variables ---
    vis = MOI.get(src, MOI.ListOfVariableIndices())
    nv = length(vis)
    dest.nv = nv
    for (j, vi) in enumerate(vis)
        dest.var_col[vi] = j
        idxmap[vi] = vi
    end

    H = zeros(nv, nv)
    g = zeros(nv)
    lb = fill(-Inf, nv)
    ub = fill(Inf, nv)

    # --- objective ---
    dest.sense = MOI.get(src, MOI.ObjectiveSense())
    dest.objsign = dest.sense == MOI.MAX_SENSE ? -1.0 : 1.0
    if dest.sense != MOI.FEASIBILITY_SENSE
        F = MOI.get(src, MOI.ObjectiveFunctionType())
        _load_objective!(H, g, dest, MOI.get(src, MOI.ObjectiveFunction{F}()))
    end
    H .*= dest.objsign
    g .*= dest.objsign
    dest.H = H
    dest.g = g

    # --- constraints ---
    eq_rows = Tuple{Vector{Float64},Float64}[]        # (coef row, rhs)
    gen_rows = Tuple{Vector{Float64},Float64,Float64}[]  # (coef row, lg, ug)
    for (F, S) in MOI.get(src, MOI.ListOfConstraintTypesPresent())
        _load_constraints!(dest, src, F, S, lb, ub, eq_rows, gen_rows, idxmap)
    end

    # box constraints: keep only variables that actually have a finite bound
    idxb = Int[]; lbv = Float64[]; ubv = Float64[]
    for j in 1:nv
        if isfinite(lb[j]) || isfinite(ub[j])
            push!(idxb, j - 1)        # 0-based for HPIPM
            push!(lbv, lb[j]); push!(ubv, ub[j])
        end
    end
    dest.idxb = idxb; dest.lb = lbv; dest.ub = ubv

    ne = length(eq_rows)
    A = zeros(ne, nv); b = zeros(ne)
    for (i, (row, rhs)) in enumerate(eq_rows)
        A[i, :] .= row; b[i] = rhs
    end
    dest.A = A; dest.b = b

    ng = length(gen_rows)
    C = zeros(ng, nv); lg = zeros(ng); ug = zeros(ng)
    for (i, (row, l, u)) in enumerate(gen_rows)
        C[i, :] .= row; lg[i] = l; ug[i] = u
    end
    dest.C = C; dest.lg = lg; dest.ug = ug
    return idxmap
end

# fill H, g from an objective function
_load_objective!(H, g, opt, f::VI) = (g[opt.var_col[f]] += 1.0; nothing)
function _load_objective!(H, g, opt, f::SAF)
    opt.objconst = f.constant
    for t in f.terms
        g[opt.var_col[t.variable]] += t.coefficient
    end
    return nothing
end
function _load_objective!(H, g, opt, f::SQF)
    opt.objconst = f.constant
    for t in f.affine_terms
        g[opt.var_col[t.variable]] += t.coefficient
    end
    for t in f.quadratic_terms
        i = opt.var_col[t.variable_1]
        j = opt.var_col[t.variable_2]
        # MOI: diagonal term coef α ⇒ contributes ½α xᵢ²; off-diagonal α ⇒ α xᵢxⱼ.
        # HPIPM minimises ½xᵀHx, so H[i,i]=α, H[i,j]=H[j,i]=α.
        if i == j
            H[i, i] += t.coefficient
        else
            H[i, j] += t.coefficient
            H[j, i] += t.coefficient
        end
    end
    return nothing
end

# variable bounds
function _load_constraints!(opt, src, ::Type{VI}, ::Type{S}, lb, ub, eq_rows,
                           gen_rows, idxmap) where {S<:_SCALAR_SETS}
    for ci in MOI.get(src, MOI.ListOfConstraintIndices{VI,S}())
        f = MOI.get(src, MOI.ConstraintFunction(), ci)
        s = MOI.get(src, MOI.ConstraintSet(), ci)
        col = opt.var_col[f]
        _apply_bound!(lb, ub, col, s)
        opt.bnd_col[ci] = col
        idxmap[ci] = ci
    end
    return nothing
end

# affine constraints
function _load_constraints!(opt, src, ::Type{SAF}, ::Type{S}, lb, ub, eq_rows,
                           gen_rows, idxmap) where {S<:_SCALAR_SETS}
    for ci in MOI.get(src, MOI.ListOfConstraintIndices{SAF,S}())
        f = MOI.get(src, MOI.ConstraintFunction(), ci)
        s = MOI.get(src, MOI.ConstraintSet(), ci)
        row = zeros(opt.nv)
        for t in f.terms
            row[opt.var_col[t.variable]] += t.coefficient
        end
        if S === MOI.EqualTo{Float64}
            push!(eq_rows, (row, s.value - f.constant))
            push!(opt.eq_cis, ci)
        else
            l, u = _set_bounds(s)
            push!(gen_rows, (row, l - f.constant, u - f.constant))
            push!(opt.gen_cis, (ci, length(gen_rows)))
        end
        idxmap[ci] = ci
    end
    return nothing
end

_apply_bound!(lb, ub, c, s::MOI.LessThan) = (ub[c] = min(ub[c], s.upper))
_apply_bound!(lb, ub, c, s::MOI.GreaterThan) = (lb[c] = max(lb[c], s.lower))
_apply_bound!(lb, ub, c, s::MOI.EqualTo) = (lb[c] = ub[c] = s.value)
_apply_bound!(lb, ub, c, s::MOI.Interval) = (lb[c] = s.lower; ub[c] = s.upper)

_set_bounds(s::MOI.LessThan) = (-Inf, s.upper)
_set_bounds(s::MOI.GreaterThan) = (s.lower, Inf)
_set_bounds(s::MOI.Interval) = (s.lower, s.upper)

# ---- solve ----
function MOI.optimize!(opt::Optimizer)
    nv = opt.nv
    ne = length(opt.b)
    ng = length(opt.lg)
    nb = length(opt.idxb)

    qp = DenseQP(nv; ne, nb, ng, mode = _mode(opt), iter_max = _iter_max(opt))
    set!(qp; H = opt.H, g = opt.g,
         A = ne > 0 ? opt.A : nothing, b = ne > 0 ? opt.b : nothing,
         C = ng > 0 ? opt.C : nothing,
         lg = ng > 0 ? opt.lg : nothing, ug = ng > 0 ? opt.ug : nothing,
         lb = nb > 0 ? opt.lb : nothing, ub = nb > 0 ? opt.ub : nothing,
         idxb = nb > 0 ? opt.idxb : nothing)
    _apply_tols!(qp, opt)

    opt.solve_time = @elapsed (st = solve!(qp))
    opt.iters = iterations(qp)
    opt.raw_status = st
    opt.x = copy(primal(qp))
    opt.obj = opt.objsign * objective(qp) + opt.objconst
    opt.pi = ne > 0 ? copy(dual_eq(qp)) : Float64[]
    _store_ineq_duals!(opt, qp, nb, ng)

    opt.term_status, opt.primal_status = _statuses(st)
    opt.solved = true
    return nothing
end

function _store_ineq_duals!(opt::Optimizer, qp::DenseQP, nb, ng)
    opt.lam_lb = zeros(nb); opt.lam_ub = zeros(nb)
    opt.lam_lg = zeros(ng); opt.lam_ug = zeros(ng)
    GC.@preserve qp begin
        nb > 0 && LibHPIPM.d_dense_qp_sol_get_lam_lb(qp.sol.ptr, pointer(opt.lam_lb))
        nb > 0 && LibHPIPM.d_dense_qp_sol_get_lam_ub(qp.sol.ptr, pointer(opt.lam_ub))
        ng > 0 && LibHPIPM.d_dense_qp_sol_get_lam_lg(qp.sol.ptr, pointer(opt.lam_lg))
        ng > 0 && LibHPIPM.d_dense_qp_sol_get_lam_ug(qp.sol.ptr, pointer(opt.lam_ug))
    end
    return nothing
end

function _mode(opt::Optimizer)
    m = get(opt.options, "mode", "BALANCE")
    m isa LibHPIPM.hpipm_mode && return m
    return getfield(LibHPIPM, Symbol(m))::LibHPIPM.hpipm_mode
end
_iter_max(opt::Optimizer) = Int(get(opt.options, "iter_max", 50))

function _apply_tols!(qp::DenseQP, opt::Optimizer)
    for (name, key) in (("tol_stat", :tol_stat), ("tol_eq", :tol_eq),
                        ("tol_ineq", :tol_ineq), ("tol_comp", :tol_comp),
                        ("mu0", :mu0))
        haskey(opt.options, name) && set!(qp; (key => Float64(opt.options[name]),)...)
    end
    return nothing
end

function _statuses(st::Symbol)
    st === :success && return (MOI.OPTIMAL, MOI.FEASIBLE_POINT)
    st === :max_iter && return (MOI.ITERATION_LIMIT, MOI.UNKNOWN_RESULT_STATUS)
    st === :min_step && return (MOI.SLOW_PROGRESS, MOI.UNKNOWN_RESULT_STATUS)
    st === :nan_sol && return (MOI.NUMERICAL_ERROR, MOI.UNKNOWN_RESULT_STATUS)
    st === :incons_eq && return (MOI.INFEASIBLE, MOI.NO_SOLUTION)
    return (MOI.OTHER_ERROR, MOI.UNKNOWN_RESULT_STATUS)
end

# ---- result attributes ----
MOI.get(opt::Optimizer, ::MOI.TerminationStatus) = opt.term_status
MOI.get(opt::Optimizer, ::MOI.RawStatusString) = String(opt.raw_status)
MOI.get(opt::Optimizer, ::MOI.SolveTimeSec) = opt.solve_time
MOI.get(opt::Optimizer, ::MOI.BarrierIterations) = Int64(opt.iters)
MOI.get(opt::Optimizer, ::MOI.ResultCount) = opt.solved ? 1 : 0

function MOI.get(opt::Optimizer, attr::MOI.PrimalStatus)
    return attr.result_index == 1 ? opt.primal_status : MOI.NO_SOLUTION
end
function MOI.get(opt::Optimizer, attr::MOI.DualStatus)
    return attr.result_index == 1 && opt.primal_status == MOI.FEASIBLE_POINT ?
           MOI.FEASIBLE_POINT : MOI.NO_SOLUTION
end

function MOI.get(opt::Optimizer, attr::MOI.ObjectiveValue)
    MOI.check_result_index_bounds(opt, attr)
    return opt.obj
end

function MOI.get(opt::Optimizer, attr::MOI.VariablePrimal, vi::VI)
    MOI.check_result_index_bounds(opt, attr)
    return opt.x[opt.var_col[vi]]
end

# equality-constraint dual (π). MOI minimisation convention; flip for maximise.
function MOI.get(opt::Optimizer, attr::MOI.ConstraintDual,
                 ci::MOI.ConstraintIndex{SAF,MOI.EqualTo{Float64}})
    MOI.check_result_index_bounds(opt, attr)
    i = findfirst(==(ci), opt.eq_cis)
    return opt.objsign * opt.pi[i]
end
