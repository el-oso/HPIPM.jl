module LibHPIPM

using HPIPM_jll
export HPIPM_jll

using CEnum: CEnum, @cenum

const __time_t = Clong

const __suseconds_t = Clong

struct timeval
    tv_sec::__time_t
    tv_usec::__suseconds_t
end

const hpipm_size_t = Csize_t

@cenum hpipm_mode::UInt32 begin
    SPEED_ABS = 0
    SPEED = 1
    BALANCE = 2
    ROBUST = 3
end

@cenum hpipm_status::UInt32 begin
    SUCCESS = 0
    MAX_ITER = 1
    MIN_STEP = 2
    NAN_SOL = 3
    INCONS_EQ = 4
end

struct blasfeo_timer_
    tic::timeval
    toc::timeval
end

const blasfeo_timer = blasfeo_timer_

"""
    blasfeo_tic(t)

A function for measurement of the current time.
"""
function blasfeo_tic(t)
    @ccall libhpipm.blasfeo_tic(t::Ptr{blasfeo_timer})::Cvoid
end

"""
    blasfeo_toc(t)

A function which returns the elapsed time.
"""
function blasfeo_toc(t)
    @ccall libhpipm.blasfeo_toc(t::Ptr{blasfeo_timer})::Cdouble
end

const hpipm_timer = blasfeo_timer

function hpipm_tic(t)
    @ccall libhpipm.hpipm_tic(t::Ptr{hpipm_timer})::Cvoid
end

function hpipm_toc(t)
    @ccall libhpipm.hpipm_toc(t::Ptr{hpipm_timer})::Cdouble
end

struct d_dense_qp_dim
    nv::Cint
    ne::Cint
    nb::Cint
    ng::Cint
    ns::Cint
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_dense_qp_dim.h:60:14, please use with caution
function d_dense_qp_dim_strsize()
    @ccall libhpipm.d_dense_qp_dim_strsize()::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_dense_qp_dim.h:62:14, please use with caution
function d_dense_qp_dim_memsize()
    @ccall libhpipm.d_dense_qp_dim_memsize()::hpipm_size_t
end

function d_dense_qp_dim_create(qp_dim, memory)
    @ccall libhpipm.d_dense_qp_dim_create(qp_dim::Ptr{d_dense_qp_dim}, memory::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_dim_set_all(nv, ne, nb, ng, ns, dim)
    @ccall libhpipm.d_dense_qp_dim_set_all(nv::Cint, ne::Cint, nb::Cint, ng::Cint, ns::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set(field_name, value, dim)
    @ccall libhpipm.d_dense_qp_dim_set(field_name::Ptr{Cchar}, value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set_nv(value, dim)
    @ccall libhpipm.d_dense_qp_dim_set_nv(value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set_ne(value, dim)
    @ccall libhpipm.d_dense_qp_dim_set_ne(value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set_nb(value, dim)
    @ccall libhpipm.d_dense_qp_dim_set_nb(value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set_ng(value, dim)
    @ccall libhpipm.d_dense_qp_dim_set_ng(value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_set_ns(value, dim)
    @ccall libhpipm.d_dense_qp_dim_set_ns(value::Cint, dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_get_nv(dim, value)
    @ccall libhpipm.d_dense_qp_dim_get_nv(dim::Ptr{d_dense_qp_dim}, value::Ptr{Cint})::Cvoid
end

function d_dense_qp_dim_get_ne(dim, value)
    @ccall libhpipm.d_dense_qp_dim_get_ne(dim::Ptr{d_dense_qp_dim}, value::Ptr{Cint})::Cvoid
end

function d_dense_qp_dim_get_nb(dim, value)
    @ccall libhpipm.d_dense_qp_dim_get_nb(dim::Ptr{d_dense_qp_dim}, value::Ptr{Cint})::Cvoid
end

function d_dense_qp_dim_get_ng(dim, value)
    @ccall libhpipm.d_dense_qp_dim_get_ng(dim::Ptr{d_dense_qp_dim}, value::Ptr{Cint})::Cvoid
end

function d_dense_qp_dim_get_ns(dim, value)
    @ccall libhpipm.d_dense_qp_dim_get_ns(dim::Ptr{d_dense_qp_dim}, value::Ptr{Cint})::Cvoid
end

struct blasfeo_dmat
    mem::Ptr{Cdouble}
    pA::Ptr{Cdouble}
    dA::Ptr{Cdouble}
    m::Cint
    n::Cint
    pm::Cint
    cn::Cint
    use_dA::Cint
    memsize::Cint
end

struct blasfeo_dvec
    mem::Ptr{Cdouble}
    pa::Ptr{Cdouble}
    m::Cint
    pm::Cint
    memsize::Cint
end

struct d_dense_qp
    dim::Ptr{d_dense_qp_dim}
    Hv::Ptr{blasfeo_dmat}
    A::Ptr{blasfeo_dmat}
    Ct::Ptr{blasfeo_dmat}
    gz::Ptr{blasfeo_dvec}
    b::Ptr{blasfeo_dvec}
    d::Ptr{blasfeo_dvec}
    d_mask::Ptr{blasfeo_dvec}
    m::Ptr{blasfeo_dvec}
    Z::Ptr{blasfeo_dvec}
    idxb::Ptr{Cint}
    idxs_rev::Ptr{Cint}
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_dense_qp.h:76:14, please use with caution
function d_dense_qp_strsize()
    @ccall libhpipm.d_dense_qp_strsize()::hpipm_size_t
end

function d_dense_qp_memsize(dim)
    @ccall libhpipm.d_dense_qp_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_create(dim, qp, memory)
    @ccall libhpipm.d_dense_qp_create(dim::Ptr{d_dense_qp_dim}, qp::Ptr{d_dense_qp}, memory::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_copy_all(qp_orig, qp_dest)
    @ccall libhpipm.d_dense_qp_copy_all(qp_orig::Ptr{d_dense_qp}, qp_dest::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_all_zero(qp)
    @ccall libhpipm.d_dense_qp_set_all_zero(qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_rhs_zero(qp)
    @ccall libhpipm.d_dense_qp_set_rhs_zero(qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_all(H, g, A, b, idxb, d_lb, d_ub, C, d_lg, d_ug, Zl, Zu, zl, zu, idxs, idxs_rev, d_ls, d_us, qp)
    @ccall libhpipm.d_dense_qp_set_all(H::Ptr{Cdouble}, g::Ptr{Cdouble}, A::Ptr{Cdouble}, b::Ptr{Cdouble}, idxb::Ptr{Cint}, d_lb::Ptr{Cdouble}, d_ub::Ptr{Cdouble}, C::Ptr{Cdouble}, d_lg::Ptr{Cdouble}, d_ug::Ptr{Cdouble}, Zl::Ptr{Cdouble}, Zu::Ptr{Cdouble}, zl::Ptr{Cdouble}, zu::Ptr{Cdouble}, idxs::Ptr{Cint}, idxs_rev::Ptr{Cint}, d_ls::Ptr{Cdouble}, d_us::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set(field, value, qp)
    @ccall libhpipm.d_dense_qp_set(field::Ptr{Cchar}, value::Ptr{Cvoid}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_H(H, qp)
    @ccall libhpipm.d_dense_qp_set_H(H::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_g(g, qp)
    @ccall libhpipm.d_dense_qp_set_g(g::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_A(A, qp)
    @ccall libhpipm.d_dense_qp_set_A(A::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_b(b, qp)
    @ccall libhpipm.d_dense_qp_set_b(b::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_idxb(idxb, qp)
    @ccall libhpipm.d_dense_qp_set_idxb(idxb::Ptr{Cint}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_Jb(Jb, qp)
    @ccall libhpipm.d_dense_qp_set_Jb(Jb::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lb(lb, qp)
    @ccall libhpipm.d_dense_qp_set_lb(lb::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lb_mask(lb, qp)
    @ccall libhpipm.d_dense_qp_set_lb_mask(lb::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_ub(ub, qp)
    @ccall libhpipm.d_dense_qp_set_ub(ub::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_ub_mask(ub, qp)
    @ccall libhpipm.d_dense_qp_set_ub_mask(ub::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_C(C, qp)
    @ccall libhpipm.d_dense_qp_set_C(C::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lg(lg, qp)
    @ccall libhpipm.d_dense_qp_set_lg(lg::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lg_mask(lg, qp)
    @ccall libhpipm.d_dense_qp_set_lg_mask(lg::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_ug(ug, qp)
    @ccall libhpipm.d_dense_qp_set_ug(ug::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_ug_mask(ug, qp)
    @ccall libhpipm.d_dense_qp_set_ug_mask(ug::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_idxs(idxs, qp)
    @ccall libhpipm.d_dense_qp_set_idxs(idxs::Ptr{Cint}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_idxs_rev(idxs_rev, qp)
    @ccall libhpipm.d_dense_qp_set_idxs_rev(idxs_rev::Ptr{Cint}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_Jsb(Jsb, qp)
    @ccall libhpipm.d_dense_qp_set_Jsb(Jsb::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_Jsg(Jsg, qp)
    @ccall libhpipm.d_dense_qp_set_Jsg(Jsg::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_Zl(Zl, qp)
    @ccall libhpipm.d_dense_qp_set_Zl(Zl::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_Zu(Zu, qp)
    @ccall libhpipm.d_dense_qp_set_Zu(Zu::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_zl(zl, qp)
    @ccall libhpipm.d_dense_qp_set_zl(zl::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_zu(zu, qp)
    @ccall libhpipm.d_dense_qp_set_zu(zu::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lls(ls, qp)
    @ccall libhpipm.d_dense_qp_set_lls(ls::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lls_mask(ls, qp)
    @ccall libhpipm.d_dense_qp_set_lls_mask(ls::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lus(us, qp)
    @ccall libhpipm.d_dense_qp_set_lus(us::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_lus_mask(us, qp)
    @ccall libhpipm.d_dense_qp_set_lus_mask(us::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_all(m, qp)
    @ccall libhpipm.d_dense_qp_set_m_all(m::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_lb(lb, qp)
    @ccall libhpipm.d_dense_qp_set_m_lb(lb::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_ub(ub, qp)
    @ccall libhpipm.d_dense_qp_set_m_ub(ub::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_lg(lg, qp)
    @ccall libhpipm.d_dense_qp_set_m_lg(lg::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_ug(ug, qp)
    @ccall libhpipm.d_dense_qp_set_m_ug(ug::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_lls(ls, qp)
    @ccall libhpipm.d_dense_qp_set_m_lls(ls::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_set_m_lus(us, qp)
    @ccall libhpipm.d_dense_qp_set_m_lus(us::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_get_all(qp, H, g, A, b, idxb, d_lb, d_ub, C, d_lg, d_ug, Zl, Zu, zl, zu, idxs, idxs_rev, d_ls, d_us)
    @ccall libhpipm.d_dense_qp_get_all(qp::Ptr{d_dense_qp}, H::Ptr{Cdouble}, g::Ptr{Cdouble}, A::Ptr{Cdouble}, b::Ptr{Cdouble}, idxb::Ptr{Cint}, d_lb::Ptr{Cdouble}, d_ub::Ptr{Cdouble}, C::Ptr{Cdouble}, d_lg::Ptr{Cdouble}, d_ug::Ptr{Cdouble}, Zl::Ptr{Cdouble}, Zu::Ptr{Cdouble}, zl::Ptr{Cdouble}, zu::Ptr{Cdouble}, idxs::Ptr{Cint}, idxs_rev::Ptr{Cint}, d_ls::Ptr{Cdouble}, d_us::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_H(qp, H)
    @ccall libhpipm.d_dense_qp_get_H(qp::Ptr{d_dense_qp}, H::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_g(qp, g)
    @ccall libhpipm.d_dense_qp_get_g(qp::Ptr{d_dense_qp}, g::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_A(qp, A)
    @ccall libhpipm.d_dense_qp_get_A(qp::Ptr{d_dense_qp}, A::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_b(qp, b)
    @ccall libhpipm.d_dense_qp_get_b(qp::Ptr{d_dense_qp}, b::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_idxb(qp, idxb)
    @ccall libhpipm.d_dense_qp_get_idxb(qp::Ptr{d_dense_qp}, idxb::Ptr{Cint})::Cvoid
end

function d_dense_qp_get_lb(qp, lb)
    @ccall libhpipm.d_dense_qp_get_lb(qp::Ptr{d_dense_qp}, lb::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_lb_mask(qp, lb)
    @ccall libhpipm.d_dense_qp_get_lb_mask(qp::Ptr{d_dense_qp}, lb::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ub(qp, ub)
    @ccall libhpipm.d_dense_qp_get_ub(qp::Ptr{d_dense_qp}, ub::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ub_mask(qp, ub)
    @ccall libhpipm.d_dense_qp_get_ub_mask(qp::Ptr{d_dense_qp}, ub::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_C(qp, C)
    @ccall libhpipm.d_dense_qp_get_C(qp::Ptr{d_dense_qp}, C::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_lg(qp, lg)
    @ccall libhpipm.d_dense_qp_get_lg(qp::Ptr{d_dense_qp}, lg::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_lg_mask(qp, lg)
    @ccall libhpipm.d_dense_qp_get_lg_mask(qp::Ptr{d_dense_qp}, lg::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ug(qp, ug)
    @ccall libhpipm.d_dense_qp_get_ug(qp::Ptr{d_dense_qp}, ug::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ug_mask(qp, ug)
    @ccall libhpipm.d_dense_qp_get_ug_mask(qp::Ptr{d_dense_qp}, ug::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_idxs(qp, idxs)
    @ccall libhpipm.d_dense_qp_get_idxs(qp::Ptr{d_dense_qp}, idxs::Ptr{Cint})::Cvoid
end

function d_dense_qp_get_idxs_rev(qp, idxs_rev)
    @ccall libhpipm.d_dense_qp_get_idxs_rev(qp::Ptr{d_dense_qp}, idxs_rev::Ptr{Cint})::Cvoid
end

function d_dense_qp_get_Zl(qp, Zl)
    @ccall libhpipm.d_dense_qp_get_Zl(qp::Ptr{d_dense_qp}, Zl::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_Zu(qp, Zu)
    @ccall libhpipm.d_dense_qp_get_Zu(qp::Ptr{d_dense_qp}, Zu::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_zl(qp, zl)
    @ccall libhpipm.d_dense_qp_get_zl(qp::Ptr{d_dense_qp}, zl::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_zu(qp, zu)
    @ccall libhpipm.d_dense_qp_get_zu(qp::Ptr{d_dense_qp}, zu::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ls(qp, ls)
    @ccall libhpipm.d_dense_qp_get_ls(qp::Ptr{d_dense_qp}, ls::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_ls_mask(qp, ls)
    @ccall libhpipm.d_dense_qp_get_ls_mask(qp::Ptr{d_dense_qp}, ls::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_us(qp, us)
    @ccall libhpipm.d_dense_qp_get_us(qp::Ptr{d_dense_qp}, us::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_get_us_mask(qp, us)
    @ccall libhpipm.d_dense_qp_get_us_mask(qp::Ptr{d_dense_qp}, us::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_set_all_rowmaj(H, g, A, b, idxb, d_lb, d_ub, C, d_lg, d_ug, Zl, Zu, zl, zu, idxs, idxs_rev, d_ls, d_us, qp)
    @ccall libhpipm.d_dense_qp_set_all_rowmaj(H::Ptr{Cdouble}, g::Ptr{Cdouble}, A::Ptr{Cdouble}, b::Ptr{Cdouble}, idxb::Ptr{Cint}, d_lb::Ptr{Cdouble}, d_ub::Ptr{Cdouble}, C::Ptr{Cdouble}, d_lg::Ptr{Cdouble}, d_ug::Ptr{Cdouble}, Zl::Ptr{Cdouble}, Zu::Ptr{Cdouble}, zl::Ptr{Cdouble}, zu::Ptr{Cdouble}, idxs::Ptr{Cint}, idxs_rev::Ptr{Cint}, d_ls::Ptr{Cdouble}, d_us::Ptr{Cdouble}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_get_all_rowmaj(qp, H, g, A, b, idxb, d_lb, d_ub, C, d_lg, d_ug, Zl, Zu, zl, zu, idxs, idxs_rev, d_ls, d_us)
    @ccall libhpipm.d_dense_qp_get_all_rowmaj(qp::Ptr{d_dense_qp}, H::Ptr{Cdouble}, g::Ptr{Cdouble}, A::Ptr{Cdouble}, b::Ptr{Cdouble}, idxb::Ptr{Cint}, d_lb::Ptr{Cdouble}, d_ub::Ptr{Cdouble}, C::Ptr{Cdouble}, d_lg::Ptr{Cdouble}, d_ug::Ptr{Cdouble}, Zl::Ptr{Cdouble}, Zu::Ptr{Cdouble}, zl::Ptr{Cdouble}, zu::Ptr{Cdouble}, idxs::Ptr{Cint}, idxs_rev::Ptr{Cint}, d_ls::Ptr{Cdouble}, d_us::Ptr{Cdouble})::Cvoid
end

struct d_dense_qp_sol
    dim::Ptr{d_dense_qp_dim}
    v::Ptr{blasfeo_dvec}
    pi::Ptr{blasfeo_dvec}
    lam::Ptr{blasfeo_dvec}
    t::Ptr{blasfeo_dvec}
    misc::Ptr{Cvoid}
    obj::Cdouble
    valid_obj::Cint
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_dense_qp_sol.h:72:14, please use with caution
function d_dense_qp_sol_strsize()
    @ccall libhpipm.d_dense_qp_sol_strsize()::hpipm_size_t
end

function d_dense_qp_sol_memsize(dim)
    @ccall libhpipm.d_dense_qp_sol_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_sol_create(dim, qp_sol, memory)
    @ccall libhpipm.d_dense_qp_sol_create(dim::Ptr{d_dense_qp_dim}, qp_sol::Ptr{d_dense_qp_sol}, memory::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_sol_get_all(qp_sol, v, ls, us, pi, lam_lb, lam_ub, lam_lg, lam_ug, lam_ls, lam_us)
    @ccall libhpipm.d_dense_qp_sol_get_all(qp_sol::Ptr{d_dense_qp_sol}, v::Ptr{Cdouble}, ls::Ptr{Cdouble}, us::Ptr{Cdouble}, pi::Ptr{Cdouble}, lam_lb::Ptr{Cdouble}, lam_ub::Ptr{Cdouble}, lam_lg::Ptr{Cdouble}, lam_ug::Ptr{Cdouble}, lam_ls::Ptr{Cdouble}, lam_us::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get(field, sol, value)
    @ccall libhpipm.d_dense_qp_sol_get(field::Ptr{Cchar}, sol::Ptr{d_dense_qp_sol}, value::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_sol_get_v(sol, v)
    @ccall libhpipm.d_dense_qp_sol_get_v(sol::Ptr{d_dense_qp_sol}, v::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_sl(sol, sl)
    @ccall libhpipm.d_dense_qp_sol_get_sl(sol::Ptr{d_dense_qp_sol}, sl::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_su(sol, su)
    @ccall libhpipm.d_dense_qp_sol_get_su(sol::Ptr{d_dense_qp_sol}, su::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_pi(sol, pi)
    @ccall libhpipm.d_dense_qp_sol_get_pi(sol::Ptr{d_dense_qp_sol}, pi::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_lb(sol, lam_lb)
    @ccall libhpipm.d_dense_qp_sol_get_lam_lb(sol::Ptr{d_dense_qp_sol}, lam_lb::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_ub(sol, lam_ub)
    @ccall libhpipm.d_dense_qp_sol_get_lam_ub(sol::Ptr{d_dense_qp_sol}, lam_ub::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_lg(sol, lam_lg)
    @ccall libhpipm.d_dense_qp_sol_get_lam_lg(sol::Ptr{d_dense_qp_sol}, lam_lg::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_ug(sol, lam_ug)
    @ccall libhpipm.d_dense_qp_sol_get_lam_ug(sol::Ptr{d_dense_qp_sol}, lam_ug::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_ls(sol, lam_ls)
    @ccall libhpipm.d_dense_qp_sol_get_lam_ls(sol::Ptr{d_dense_qp_sol}, lam_ls::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_lam_us(sol, lam_us)
    @ccall libhpipm.d_dense_qp_sol_get_lam_us(sol::Ptr{d_dense_qp_sol}, lam_us::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_get_valid_obj(sol, valid_obj)
    @ccall libhpipm.d_dense_qp_sol_get_valid_obj(sol::Ptr{d_dense_qp_sol}, valid_obj::Ptr{Cint})::Cvoid
end

function d_dense_qp_sol_get_obj(sol, obj)
    @ccall libhpipm.d_dense_qp_sol_get_obj(sol::Ptr{d_dense_qp_sol}, obj::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_sol_set(field, value, qp_sol)
    @ccall libhpipm.d_dense_qp_sol_set(field::Ptr{Cchar}, value::Ptr{Cvoid}, qp_sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_v(v, sol)
    @ccall libhpipm.d_dense_qp_sol_set_v(v::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_sl(sl, sol)
    @ccall libhpipm.d_dense_qp_sol_set_sl(sl::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_su(su, sol)
    @ccall libhpipm.d_dense_qp_sol_set_su(su::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_pi(pi, sol)
    @ccall libhpipm.d_dense_qp_sol_set_pi(pi::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_lb(lam_lb, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_lb(lam_lb::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_ub(lam_ub, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_ub(lam_ub::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_lg(lam_lg, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_lg(lam_lg::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_ug(lam_ug, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_ug(lam_ug::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_ls(lam_ls, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_ls(lam_ls::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_sol_set_lam_us(lam_us, sol)
    @ccall libhpipm.d_dense_qp_sol_set_lam_us(lam_us::Ptr{Cdouble}, sol::Ptr{d_dense_qp_sol})::Cvoid
end

struct d_dense_qp_res
    dim::Ptr{d_dense_qp_dim}
    res_g::Ptr{blasfeo_dvec}
    res_b::Ptr{blasfeo_dvec}
    res_d::Ptr{blasfeo_dvec}
    res_m::Ptr{blasfeo_dvec}
    res_max::NTuple{4, Cdouble}
    res_mu_sum::Cdouble
    res_mu::Cdouble
    obj::Cdouble
    dual_gap::Cdouble
    memsize::hpipm_size_t
end

struct d_dense_qp_res_ws
    tmp_nbg::Ptr{blasfeo_dvec}
    tmp_ns::Ptr{blasfeo_dvec}
    tmp_lam_mask::Ptr{blasfeo_dvec}
    nc_mask_inv::Cdouble
    valid_nc_mask::Cint
    mask_constr::Cint
    memsize::hpipm_size_t
end

function d_dense_qp_res_memsize(dim)
    @ccall libhpipm.d_dense_qp_res_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_res_create(dim, res, mem)
    @ccall libhpipm.d_dense_qp_res_create(dim::Ptr{d_dense_qp_dim}, res::Ptr{d_dense_qp_res}, mem::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_res_ws_memsize(dim)
    @ccall libhpipm.d_dense_qp_res_ws_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_res_ws_create(dim, workspace, mem)
    @ccall libhpipm.d_dense_qp_res_ws_create(dim::Ptr{d_dense_qp_dim}, workspace::Ptr{d_dense_qp_res_ws}, mem::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_res_compute(qp, qp_sol, res, ws)
    @ccall libhpipm.d_dense_qp_res_compute(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, res::Ptr{d_dense_qp_res}, ws::Ptr{d_dense_qp_res_ws})::Cvoid
end

function d_dense_qp_res_compute_lin(qp, qp_sol, qp_step, res, ws)
    @ccall libhpipm.d_dense_qp_res_compute_lin(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, qp_step::Ptr{d_dense_qp_sol}, res::Ptr{d_dense_qp_res}, ws::Ptr{d_dense_qp_res_ws})::Cvoid
end

function d_dense_qp_res_compute_inf_norm(res)
    @ccall libhpipm.d_dense_qp_res_compute_inf_norm(res::Ptr{d_dense_qp_res})::Cvoid
end

function d_dense_qp_res_get_all(res, res_g, res_ls, res_us, res_b, res_d_lb, res_d_ub, res_d_lg, res_d_ug, res_d_ls, res_d_us, res_m_lb, res_m_ub, res_m_lg, res_m_ug, res_m_ls, res_m_us)
    @ccall libhpipm.d_dense_qp_res_get_all(res::Ptr{d_dense_qp_res}, res_g::Ptr{Cdouble}, res_ls::Ptr{Cdouble}, res_us::Ptr{Cdouble}, res_b::Ptr{Cdouble}, res_d_lb::Ptr{Cdouble}, res_d_ub::Ptr{Cdouble}, res_d_lg::Ptr{Cdouble}, res_d_ug::Ptr{Cdouble}, res_d_ls::Ptr{Cdouble}, res_d_us::Ptr{Cdouble}, res_m_lb::Ptr{Cdouble}, res_m_ub::Ptr{Cdouble}, res_m_lg::Ptr{Cdouble}, res_m_ug::Ptr{Cdouble}, res_m_ls::Ptr{Cdouble}, res_m_us::Ptr{Cdouble})::Cvoid
end

struct d_dense_qp_seed
    dim::Ptr{d_dense_qp_dim}
    seed_g::Ptr{blasfeo_dvec}
    seed_b::Ptr{blasfeo_dvec}
    seed_d::Ptr{blasfeo_dvec}
    seed_m::Ptr{blasfeo_dvec}
    memsize::hpipm_size_t
end

function d_dense_qp_seed_memsize(dim)
    @ccall libhpipm.d_dense_qp_seed_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_seed_create(dim, seed, mem)
    @ccall libhpipm.d_dense_qp_seed_create(dim::Ptr{d_dense_qp_dim}, seed::Ptr{d_dense_qp_seed}, mem::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_seed_set(field, value, qp_seed)
    @ccall libhpipm.d_dense_qp_seed_set(field::Ptr{Cchar}, value::Ptr{Cvoid}, qp_seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_g(seed_g, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_g(seed_g::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_zl(seed_zl, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_zl(seed_zl::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_zu(seed_zu, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_zu(seed_zu::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_b(seed_b, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_b(seed_b::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_lb(seed_lb, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_lb(seed_lb::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_ub(seed_ub, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_ub(seed_ub::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_lg(seed_lg, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_lg(seed_lg::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_ug(seed_ug, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_ug(seed_ug::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_ls(seed_ls, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_ls(seed_ls::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_seed_set_seed_us(seed_us, seed)
    @ccall libhpipm.d_dense_qp_seed_set_seed_us(seed_us::Ptr{Cdouble}, seed::Ptr{d_dense_qp_seed})::Cvoid
end

struct d_dense_qp_ipm_arg
    mu0::Cdouble
    alpha_min::Cdouble
    res_g_max::Cdouble
    res_b_max::Cdouble
    res_d_max::Cdouble
    res_m_max::Cdouble
    dual_gap_max::Cdouble
    reg_prim::Cdouble
    reg_dual::Cdouble
    lam_min::Cdouble
    t_min::Cdouble
    tau_min::Cdouble
    lam0_min::Cdouble
    t0_min::Cdouble
    m_safe::Cdouble
    iter_max::Cint
    stat_max::Cint
    pred_corr::Cint
    cond_pred_corr::Cint
    scale::Cint
    itref_pred_max::Cint
    itref_corr_max::Cint
    warm_start::Cint
    lq_fact::Cint
    abs_form::Cint
    comp_res_exit::Cint
    comp_res_pred::Cint
    kkt_fact_alg::Cint
    remove_lin_dep_eq::Cint
    compute_obj::Cint
    split_step::Cint
    t_lam_min::Cint
    t0_init::Cint
    update_fact_exit::Cint
    mode::Cint
    memsize::hpipm_size_t
end

mutable struct d_core_qp_ipm_workspace end

struct d_dense_qp_ipm_ws
    core_workspace::Ptr{d_core_qp_ipm_workspace}
    res_ws::Ptr{d_dense_qp_res_ws}
    sol_step::Ptr{d_dense_qp_sol}
    sol_itref::Ptr{d_dense_qp_sol}
    qp_step::Ptr{d_dense_qp}
    qp_itref::Ptr{d_dense_qp}
    res::Ptr{d_dense_qp_res}
    res_itref::Ptr{d_dense_qp_res}
    res_step::Ptr{d_dense_qp_res}
    Gamma::Ptr{blasfeo_dvec}
    gamma::Ptr{blasfeo_dvec}
    Zs_inv::Ptr{blasfeo_dvec}
    Lv::Ptr{blasfeo_dmat}
    AL::Ptr{blasfeo_dmat}
    Le::Ptr{blasfeo_dmat}
    Ctx::Ptr{blasfeo_dmat}
    lv::Ptr{blasfeo_dvec}
    sv::Ptr{blasfeo_dvec}
    se::Ptr{blasfeo_dvec}
    tmp_nbg::Ptr{blasfeo_dvec}
    lq0::Ptr{blasfeo_dmat}
    lq1::Ptr{blasfeo_dmat}
    tmp_m::Ptr{blasfeo_dvec}
    A_LQ::Ptr{blasfeo_dmat}
    A_Q::Ptr{blasfeo_dmat}
    Zt::Ptr{blasfeo_dmat}
    ZtH::Ptr{blasfeo_dmat}
    ZtHZ::Ptr{blasfeo_dmat}
    xy::Ptr{blasfeo_dvec}
    Yxy::Ptr{blasfeo_dvec}
    xz::Ptr{blasfeo_dvec}
    tmp_nv::Ptr{blasfeo_dvec}
    tmp_2ns::Ptr{blasfeo_dvec}
    tmp_nv2ns::Ptr{blasfeo_dvec}
    A_li::Ptr{blasfeo_dmat}
    b_li::Ptr{blasfeo_dvec}
    A_bkp::Ptr{blasfeo_dmat}
    b_bkp::Ptr{blasfeo_dvec}
    Ab_LU::Ptr{blasfeo_dmat}
    stat::Ptr{Cdouble}
    eig_V::Ptr{Cdouble}
    eig_d::Ptr{Cdouble}
    eig_e::Ptr{Cdouble}
    ipiv_v::Ptr{Cint}
    ipiv_e::Ptr{Cint}
    ipiv_e1::Ptr{Cint}
    lq_work0::Ptr{Cvoid}
    lq_work1::Ptr{Cvoid}
    lq_work_null::Ptr{Cvoid}
    orglq_work_null::Ptr{Cvoid}
    iter::Cint
    stat_max::Cint
    stat_m::Cint
    scale::Cint
    use_hess_fact::Cint
    use_A_fact::Cint
    status::Cint
    lq_fact::Cint
    mask_constr::Cint
    ne_li::Cint
    ne_bkp::Cint
    npd_reg_hess::Cint
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_dense_qp_ipm.h:172:14, please use with caution
function d_dense_qp_ipm_arg_strsize()
    @ccall libhpipm.d_dense_qp_ipm_arg_strsize()::hpipm_size_t
end

function d_dense_qp_ipm_arg_memsize(dim)
    @ccall libhpipm.d_dense_qp_ipm_arg_memsize(dim::Ptr{d_dense_qp_dim})::hpipm_size_t
end

function d_dense_qp_ipm_arg_create(dim, arg, mem)
    @ccall libhpipm.d_dense_qp_ipm_arg_create(dim::Ptr{d_dense_qp_dim}, arg::Ptr{d_dense_qp_ipm_arg}, mem::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_ipm_arg_set_default(mode, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_default(mode::hpipm_mode, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set(field, value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set(field::Ptr{Cchar}, value::Ptr{Cvoid}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_iter_max(iter_max, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_iter_max(iter_max::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_alpha_min(alpha_min, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_alpha_min(alpha_min::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_mu0(mu0, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_mu0(mu0::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tol_stat(tol_stat, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tol_stat(tol_stat::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tol_eq(tol_eq, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tol_eq(tol_eq::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tol_ineq(tol_ineq, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tol_ineq(tol_ineq::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tol_comp(tol_comp, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tol_comp(tol_comp::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tol_dual_gap(tol_dual_gap, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tol_dual_gap(tol_dual_gap::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_reg_prim(reg, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_reg_prim(reg::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_reg_dual(reg, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_reg_dual(reg::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_warm_start(warm_start, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_warm_start(warm_start::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_pred_corr(pred_corr, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_pred_corr(pred_corr::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_cond_pred_corr(cond_pred_corr, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_cond_pred_corr(cond_pred_corr::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_comp_res_pred(comp_res_pred, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_comp_res_pred(comp_res_pred::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_comp_res_exit(comp_res_exit, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_comp_res_exit(comp_res_exit::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_lam_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_lam_min(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_t_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_t_min(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_tau_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_tau_min(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_lam0_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_lam0_min(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_t0_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_t0_min(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_kkt_fact_alg(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_kkt_fact_alg(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_remove_lin_dep_eq(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_remove_lin_dep_eq(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_compute_obj(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_compute_obj(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_split_step(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_split_step(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_m_safe(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_m_safe(value::Ptr{Cdouble}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_t_lam_min(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_t_lam_min(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_t0_init(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_t0_init(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_set_update_fact_exit(value, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_set_update_fact_exit(value::Ptr{Cint}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_ipm_arg_get(field, arg, value)
    @ccall libhpipm.d_dense_qp_ipm_arg_get(field::Ptr{Cchar}, arg::Ptr{d_dense_qp_ipm_arg}, value::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_ipm_arg_get_lam0_min(arg, value)
    @ccall libhpipm.d_dense_qp_ipm_arg_get_lam0_min(arg::Ptr{d_dense_qp_ipm_arg}, value::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_arg_get_t0_min(arg, value)
    @ccall libhpipm.d_dense_qp_ipm_arg_get_t0_min(arg::Ptr{d_dense_qp_ipm_arg}, value::Ptr{Cdouble})::Cvoid
end

# no prototype is found for this function at hpipm_d_dense_qp_ipm.h:245:14, please use with caution
function d_dense_qp_ipm_ws_strsize()
    @ccall libhpipm.d_dense_qp_ipm_ws_strsize()::hpipm_size_t
end

function d_dense_qp_ipm_ws_memsize(qp_dim, arg)
    @ccall libhpipm.d_dense_qp_ipm_ws_memsize(qp_dim::Ptr{d_dense_qp_dim}, arg::Ptr{d_dense_qp_ipm_arg})::hpipm_size_t
end

function d_dense_qp_ipm_ws_create(qp_dim, arg, ws, mem)
    @ccall libhpipm.d_dense_qp_ipm_ws_create(qp_dim::Ptr{d_dense_qp_dim}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws}, mem::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_ipm_get(field, ws, value)
    @ccall libhpipm.d_dense_qp_ipm_get(field::Ptr{Cchar}, ws::Ptr{d_dense_qp_ipm_ws}, value::Ptr{Cvoid})::Cvoid
end

function d_dense_qp_ipm_get_status(ws, status)
    @ccall libhpipm.d_dense_qp_ipm_get_status(ws::Ptr{d_dense_qp_ipm_ws}, status::Ptr{Cint})::Cvoid
end

function d_dense_qp_ipm_get_iter(ws, iter)
    @ccall libhpipm.d_dense_qp_ipm_get_iter(ws::Ptr{d_dense_qp_ipm_ws}, iter::Ptr{Cint})::Cvoid
end

function d_dense_qp_ipm_get_max_res_stat(ws, res_stat)
    @ccall libhpipm.d_dense_qp_ipm_get_max_res_stat(ws::Ptr{d_dense_qp_ipm_ws}, res_stat::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_max_res_eq(ws, res_eq)
    @ccall libhpipm.d_dense_qp_ipm_get_max_res_eq(ws::Ptr{d_dense_qp_ipm_ws}, res_eq::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_max_res_ineq(ws, res_ineq)
    @ccall libhpipm.d_dense_qp_ipm_get_max_res_ineq(ws::Ptr{d_dense_qp_ipm_ws}, res_ineq::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_max_res_comp(ws, res_comp)
    @ccall libhpipm.d_dense_qp_ipm_get_max_res_comp(ws::Ptr{d_dense_qp_ipm_ws}, res_comp::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_dual_gap(ws, dual_gap)
    @ccall libhpipm.d_dense_qp_ipm_get_dual_gap(ws::Ptr{d_dense_qp_ipm_ws}, dual_gap::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_obj(ws, obj)
    @ccall libhpipm.d_dense_qp_ipm_get_obj(ws::Ptr{d_dense_qp_ipm_ws}, obj::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_tau_iter(ws, tau_iter)
    @ccall libhpipm.d_dense_qp_ipm_get_tau_iter(ws::Ptr{d_dense_qp_ipm_ws}, tau_iter::Ptr{Cdouble})::Cvoid
end

function d_dense_qp_ipm_get_stat(ws, stat)
    @ccall libhpipm.d_dense_qp_ipm_get_stat(ws::Ptr{d_dense_qp_ipm_ws}, stat::Ptr{Ptr{Cdouble}})::Cvoid
end

function d_dense_qp_ipm_get_stat_m(ws, stat_m)
    @ccall libhpipm.d_dense_qp_ipm_get_stat_m(ws::Ptr{d_dense_qp_ipm_ws}, stat_m::Ptr{Cint})::Cvoid
end

function d_dense_qp_init_var(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_init_var(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_abs_step(kk, qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_abs_step(kk::Cint, qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_delta_step(kk, qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_delta_step(kk::Cint, qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_solve(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_solve(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_predict(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_predict(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_sens_frw(qp, seed, sens, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_sens_frw(qp::Ptr{d_dense_qp}, seed::Ptr{d_dense_qp_seed}, sens::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_ipm_sens_adj(qp, seed, sens, arg, ws)
    @ccall libhpipm.d_dense_qp_ipm_sens_adj(qp::Ptr{d_dense_qp}, seed::Ptr{d_dense_qp_seed}, sens::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_compute_step_length(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_dense_qp_compute_step_length(qp::Ptr{d_dense_qp}, qp_sol::Ptr{d_dense_qp_sol}, arg::Ptr{d_dense_qp_ipm_arg}, ws::Ptr{d_dense_qp_ipm_ws})::Cvoid
end

function d_dense_qp_dim_print(qp_dim)
    @ccall libhpipm.d_dense_qp_dim_print(qp_dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_dim_codegen(file_name, mode, qp_dim)
    @ccall libhpipm.d_dense_qp_dim_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_dense_qp_dim})::Cvoid
end

function d_dense_qp_print(qp_dim, qp)
    @ccall libhpipm.d_dense_qp_print(qp_dim::Ptr{d_dense_qp_dim}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_codegen(file_name, mode, qp_dim, qp)
    @ccall libhpipm.d_dense_qp_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_dense_qp_dim}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_codegen_matlab(file_name, mode, qp_dim, qp)
    @ccall libhpipm.d_dense_qp_codegen_matlab(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_dense_qp_dim}, qp::Ptr{d_dense_qp})::Cvoid
end

function d_dense_qp_sol_print(qp_dim, dense_qp_sol)
    @ccall libhpipm.d_dense_qp_sol_print(qp_dim::Ptr{d_dense_qp_dim}, dense_qp_sol::Ptr{d_dense_qp_sol})::Cvoid
end

function d_dense_qp_ipm_arg_codegen(file_name, mode, qp_dim, arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_dense_qp_dim}, arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

function d_dense_qp_res_print(qp_dim, dense_qp_res)
    @ccall libhpipm.d_dense_qp_res_print(qp_dim::Ptr{d_dense_qp_dim}, dense_qp_res::Ptr{d_dense_qp_res})::Cvoid
end

function d_dense_qp_seed_print(qp_dim, dense_qp_seed)
    @ccall libhpipm.d_dense_qp_seed_print(qp_dim::Ptr{d_dense_qp_dim}, dense_qp_seed::Ptr{d_dense_qp_seed})::Cvoid
end

function d_dense_qp_ipm_arg_print(qp_dim, qp_ipm_arg)
    @ccall libhpipm.d_dense_qp_ipm_arg_print(qp_dim::Ptr{d_dense_qp_dim}, qp_ipm_arg::Ptr{d_dense_qp_ipm_arg})::Cvoid
end

struct d_ocp_qp_dim
    nx::Ptr{Cint}
    nu::Ptr{Cint}
    nb::Ptr{Cint}
    nbx::Ptr{Cint}
    nbu::Ptr{Cint}
    ng::Ptr{Cint}
    ns::Ptr{Cint}
    nbxe::Ptr{Cint}
    nbue::Ptr{Cint}
    nge::Ptr{Cint}
    N::Cint
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_ocp_qp_dim.h:66:14, please use with caution
function d_ocp_qp_dim_strsize()
    @ccall libhpipm.d_ocp_qp_dim_strsize()::hpipm_size_t
end

function d_ocp_qp_dim_memsize(N)
    @ccall libhpipm.d_ocp_qp_dim_memsize(N::Cint)::hpipm_size_t
end

function d_ocp_qp_dim_create(N, qp_dim, memory)
    @ccall libhpipm.d_ocp_qp_dim_create(N::Cint, qp_dim::Ptr{d_ocp_qp_dim}, memory::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_dim_copy_all(dim_orig, dim_dest)
    @ccall libhpipm.d_ocp_qp_dim_copy_all(dim_orig::Ptr{d_ocp_qp_dim}, dim_dest::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_all(nx, nu, nbx, nbu, ng, ns, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_all(nx::Ptr{Cint}, nu::Ptr{Cint}, nbx::Ptr{Cint}, nbu::Ptr{Cint}, ng::Ptr{Cint}, ns::Ptr{Cint}, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set(field, stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set(field::Ptr{Cchar}, stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nx(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nx(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nu(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nu(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nbx(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nbx(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nbu(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nbu(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_ng(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_ng(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_ns(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_ns(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nbxe(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nbxe(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nbue(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nbue(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_set_nge(stage, value, dim)
    @ccall libhpipm.d_ocp_qp_dim_set_nge(stage::Cint, value::Cint, dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_deepcopy(dim_s, dim_d)
    @ccall libhpipm.d_ocp_qp_dim_deepcopy(dim_s::Ptr{d_ocp_qp_dim}, dim_d::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_get(dim, field, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get(dim::Ptr{d_ocp_qp_dim}, field::Ptr{Cchar}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_N(dim, value)
    @ccall libhpipm.d_ocp_qp_dim_get_N(dim::Ptr{d_ocp_qp_dim}, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nx(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nx(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nu(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nu(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nbx(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nbx(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nbu(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nbu(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_ng(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_ng(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_ns(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_ns(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nbxe(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nbxe(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nbue(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nbue(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

function d_ocp_qp_dim_get_nge(dim, stage, value)
    @ccall libhpipm.d_ocp_qp_dim_get_nge(dim::Ptr{d_ocp_qp_dim}, stage::Cint, value::Ptr{Cint})::Cvoid
end

struct d_ocp_qp
    dim::Ptr{d_ocp_qp_dim}
    BAbt::Ptr{blasfeo_dmat}
    RSQrq::Ptr{blasfeo_dmat}
    DCt::Ptr{blasfeo_dmat}
    b::Ptr{blasfeo_dvec}
    rqz::Ptr{blasfeo_dvec}
    d::Ptr{blasfeo_dvec}
    d_mask::Ptr{blasfeo_dvec}
    m::Ptr{blasfeo_dvec}
    Z::Ptr{blasfeo_dvec}
    idxb::Ptr{Ptr{Cint}}
    idxs_rev::Ptr{Ptr{Cint}}
    idxe::Ptr{Ptr{Cint}}
    diag_H_flag::Ptr{Cint}
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_ocp_qp.h:76:14, please use with caution
function d_ocp_qp_strsize()
    @ccall libhpipm.d_ocp_qp_strsize()::hpipm_size_t
end

function d_ocp_qp_memsize(dim)
    @ccall libhpipm.d_ocp_qp_memsize(dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_create(dim, qp, memory)
    @ccall libhpipm.d_ocp_qp_create(dim::Ptr{d_ocp_qp_dim}, qp::Ptr{d_ocp_qp}, memory::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_copy_all(qp_orig, qp_dest)
    @ccall libhpipm.d_ocp_qp_copy_all(qp_orig::Ptr{d_ocp_qp}, qp_dest::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_all_zero(qp)
    @ccall libhpipm.d_ocp_qp_set_all_zero(qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_rhs_zero(qp)
    @ccall libhpipm.d_ocp_qp_set_rhs_zero(qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_all(A, B, b, Q, S, R, q, r, idxbx, lbx, ubx, idxbu, lbu, ubu, C, D, lg, ug, Zl, Zu, zl, zu, idxs, idxs_rev, ls, us, qp)
    @ccall libhpipm.d_ocp_qp_set_all(A::Ptr{Ptr{Cdouble}}, B::Ptr{Ptr{Cdouble}}, b::Ptr{Ptr{Cdouble}}, Q::Ptr{Ptr{Cdouble}}, S::Ptr{Ptr{Cdouble}}, R::Ptr{Ptr{Cdouble}}, q::Ptr{Ptr{Cdouble}}, r::Ptr{Ptr{Cdouble}}, idxbx::Ptr{Ptr{Cint}}, lbx::Ptr{Ptr{Cdouble}}, ubx::Ptr{Ptr{Cdouble}}, idxbu::Ptr{Ptr{Cint}}, lbu::Ptr{Ptr{Cdouble}}, ubu::Ptr{Ptr{Cdouble}}, C::Ptr{Ptr{Cdouble}}, D::Ptr{Ptr{Cdouble}}, lg::Ptr{Ptr{Cdouble}}, ug::Ptr{Ptr{Cdouble}}, Zl::Ptr{Ptr{Cdouble}}, Zu::Ptr{Ptr{Cdouble}}, zl::Ptr{Ptr{Cdouble}}, zu::Ptr{Ptr{Cdouble}}, idxs::Ptr{Ptr{Cint}}, idxs_rev::Ptr{Ptr{Cint}}, ls::Ptr{Ptr{Cdouble}}, us::Ptr{Ptr{Cdouble}}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_all_rowmaj(A, B, b, Q, S, R, q, r, idxbx, lbx, ubx, idxbu, lbu, ubu, C, D, lg, ug, Zl, Zu, zl, zu, idxs, idxs_rev, ls, us, qp)
    @ccall libhpipm.d_ocp_qp_set_all_rowmaj(A::Ptr{Ptr{Cdouble}}, B::Ptr{Ptr{Cdouble}}, b::Ptr{Ptr{Cdouble}}, Q::Ptr{Ptr{Cdouble}}, S::Ptr{Ptr{Cdouble}}, R::Ptr{Ptr{Cdouble}}, q::Ptr{Ptr{Cdouble}}, r::Ptr{Ptr{Cdouble}}, idxbx::Ptr{Ptr{Cint}}, lbx::Ptr{Ptr{Cdouble}}, ubx::Ptr{Ptr{Cdouble}}, idxbu::Ptr{Ptr{Cint}}, lbu::Ptr{Ptr{Cdouble}}, ubu::Ptr{Ptr{Cdouble}}, C::Ptr{Ptr{Cdouble}}, D::Ptr{Ptr{Cdouble}}, lg::Ptr{Ptr{Cdouble}}, ug::Ptr{Ptr{Cdouble}}, Zl::Ptr{Ptr{Cdouble}}, Zu::Ptr{Ptr{Cdouble}}, zl::Ptr{Ptr{Cdouble}}, zu::Ptr{Ptr{Cdouble}}, idxs::Ptr{Ptr{Cint}}, idxs_rev::Ptr{Ptr{Cint}}, ls::Ptr{Ptr{Cdouble}}, us::Ptr{Ptr{Cdouble}}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set(field_name, stage, value, qp)
    @ccall libhpipm.d_ocp_qp_set(field_name::Ptr{Cchar}, stage::Cint, value::Ptr{Cvoid}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_el(field_name, stage, index, value, qp)
    @ccall libhpipm.d_ocp_qp_set_el(field_name::Ptr{Cchar}, stage::Cint, index::Cint, value::Ptr{Cvoid}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_A(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_A(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_B(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_B(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_b(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_b(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Q(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_Q(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_S(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_S(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_R(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_R(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_q(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_q(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_r(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_r(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lb(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lb(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lb_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lb_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ub(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ub(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ub_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ub_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lbx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lbx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lbx_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lbx_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_el_lbx(stage, index, elem, qp)
    @ccall libhpipm.d_ocp_qp_set_el_lbx(stage::Cint, index::Cint, elem::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ubx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ubx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ubx_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ubx_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_el_ubx(stage, index, elem, qp)
    @ccall libhpipm.d_ocp_qp_set_el_ubx(stage::Cint, index::Cint, elem::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lbu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lbu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lbu_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lbu_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ubu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ubu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ubu_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ubu_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxb(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxb(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxbx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxbx(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jbx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jbx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxbu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxbu(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jbu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jbu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_C(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_C(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_D(stage, mat, qp)
    @ccall libhpipm.d_ocp_qp_set_D(stage::Cint, mat::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lg(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lg(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lg_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lg_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ug(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ug(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_ug_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_ug_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Zl(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Zl(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Zu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Zu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_zl(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_zl(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_zu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_zu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lls(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lls(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lls_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lls_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lus(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lus(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_lus_mask(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_lus_mask(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxs(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxs(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxs_rev(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxs_rev(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jsbu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jsbu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jsbx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jsbx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jsg(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jsg(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxe(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxe(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxbxe(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxbxe(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxbue(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxbue(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_idxge(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_idxge(stage::Cint, vec::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jbxe(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jbxe(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jbue(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jbue(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_Jge(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_Jge(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_diag_H_flag(stage, value, qp)
    @ccall libhpipm.d_ocp_qp_set_diag_H_flag(stage::Cint, value::Ptr{Cint}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_all(m, qp)
    @ccall libhpipm.d_ocp_qp_set_m_all(m::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lb(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lb(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_ub(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_ub(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lbx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lbx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_ubx(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_ubx(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lbu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lbu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_ubu(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_ubu(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lg(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lg(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_ug(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_ug(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lls(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lls(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_set_m_lus(stage, vec, qp)
    @ccall libhpipm.d_ocp_qp_set_m_lus(stage::Cint, vec::Ptr{Cdouble}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_get(field, stage, qp, value)
    @ccall libhpipm.d_ocp_qp_get(field::Ptr{Cchar}, stage::Cint, qp::Ptr{d_ocp_qp}, value::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_get_A(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_A(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_B(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_B(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_b(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_b(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_Q(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_Q(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_S(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_S(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_R(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_R(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_q(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_q(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_r(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_r(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ub(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ub(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ub_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ub_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lb(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lb(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lb_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lb_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lbx(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lbx(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lbx_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lbx_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ubx(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ubx(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ubx_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ubx_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lbu(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lbu(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lbu_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lbu_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ubu(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ubu(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ubu_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ubu_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_idxb(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_idxb(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cint})::Cvoid
end

function d_ocp_qp_get_C(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_C(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_D(stage, qp, mat)
    @ccall libhpipm.d_ocp_qp_get_D(stage::Cint, qp::Ptr{d_ocp_qp}, mat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lg(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lg(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lg_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lg_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ug(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ug(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_ug_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_ug_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_Zl(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_Zl(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_Zu(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_Zu(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_zl(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_zl(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_zu(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_zu(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lls(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lls(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lls_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lls_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lus(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lus(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_lus_mask(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_lus_mask(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_get_idxs(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_idxs(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cint})::Cvoid
end

function d_ocp_qp_get_idxs_rev(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_idxs_rev(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cint})::Cvoid
end

function d_ocp_qp_get_idxe(stage, qp, vec)
    @ccall libhpipm.d_ocp_qp_get_idxe(stage::Cint, qp::Ptr{d_ocp_qp}, vec::Ptr{Cint})::Cvoid
end

struct d_ocp_qp_sol
    dim::Ptr{d_ocp_qp_dim}
    ux::Ptr{blasfeo_dvec}
    pi::Ptr{blasfeo_dvec}
    lam::Ptr{blasfeo_dvec}
    t::Ptr{blasfeo_dvec}
    misc::Ptr{Cvoid}
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_ocp_qp_sol.h:68:14, please use with caution
function d_ocp_qp_sol_strsize()
    @ccall libhpipm.d_ocp_qp_sol_strsize()::hpipm_size_t
end

function d_ocp_qp_sol_memsize(dim)
    @ccall libhpipm.d_ocp_qp_sol_memsize(dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_sol_create(dim, qp_sol, memory)
    @ccall libhpipm.d_ocp_qp_sol_create(dim::Ptr{d_ocp_qp_dim}, qp_sol::Ptr{d_ocp_qp_sol}, memory::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_sol_copy_all(qp_sol_orig, qp_sol_dest)
    @ccall libhpipm.d_ocp_qp_sol_copy_all(qp_sol_orig::Ptr{d_ocp_qp_sol}, qp_sol_dest::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_get_all(qp_sol, u, x, ls, us, pi, lam_lb, lam_ub, lam_lg, lam_ug, lam_ls, lam_us)
    @ccall libhpipm.d_ocp_qp_sol_get_all(qp_sol::Ptr{d_ocp_qp_sol}, u::Ptr{Ptr{Cdouble}}, x::Ptr{Ptr{Cdouble}}, ls::Ptr{Ptr{Cdouble}}, us::Ptr{Ptr{Cdouble}}, pi::Ptr{Ptr{Cdouble}}, lam_lb::Ptr{Ptr{Cdouble}}, lam_ub::Ptr{Ptr{Cdouble}}, lam_lg::Ptr{Ptr{Cdouble}}, lam_ug::Ptr{Ptr{Cdouble}}, lam_ls::Ptr{Ptr{Cdouble}}, lam_us::Ptr{Ptr{Cdouble}})::Cvoid
end

function d_ocp_qp_sol_get_all_rowmaj(qp_sol, u, x, ls, us, pi, lam_lb, lam_ub, lam_lg, lam_ug, lam_ls, lam_us)
    @ccall libhpipm.d_ocp_qp_sol_get_all_rowmaj(qp_sol::Ptr{d_ocp_qp_sol}, u::Ptr{Ptr{Cdouble}}, x::Ptr{Ptr{Cdouble}}, ls::Ptr{Ptr{Cdouble}}, us::Ptr{Ptr{Cdouble}}, pi::Ptr{Ptr{Cdouble}}, lam_lb::Ptr{Ptr{Cdouble}}, lam_ub::Ptr{Ptr{Cdouble}}, lam_lg::Ptr{Ptr{Cdouble}}, lam_ug::Ptr{Ptr{Cdouble}}, lam_ls::Ptr{Ptr{Cdouble}}, lam_us::Ptr{Ptr{Cdouble}})::Cvoid
end

function d_ocp_qp_sol_set_all(u, x, ls, us, pi, lam_lb, lam_ub, lam_lg, lam_ug, lam_ls, lam_us, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_all(u::Ptr{Ptr{Cdouble}}, x::Ptr{Ptr{Cdouble}}, ls::Ptr{Ptr{Cdouble}}, us::Ptr{Ptr{Cdouble}}, pi::Ptr{Ptr{Cdouble}}, lam_lb::Ptr{Ptr{Cdouble}}, lam_ub::Ptr{Ptr{Cdouble}}, lam_lg::Ptr{Ptr{Cdouble}}, lam_ug::Ptr{Ptr{Cdouble}}, lam_ls::Ptr{Ptr{Cdouble}}, lam_us::Ptr{Ptr{Cdouble}}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_zero(qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_zero(qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_get(field, stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get(field::Ptr{Cchar}, stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_u(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_u(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_x(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_x(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_sl(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_sl(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_su(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_su(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_pi(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_pi(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_lb(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_lb(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_lbu(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_lbu(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_lbx(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_lbx(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_ub(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_ub(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_ubu(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_ubu(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_ubx(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_ubx(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_lg(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_lg(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_ug(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_ug(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_ls(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_ls(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_get_lam_us(stage, qp_sol, vec)
    @ccall libhpipm.d_ocp_qp_sol_get_lam_us(stage::Cint, qp_sol::Ptr{d_ocp_qp_sol}, vec::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_sol_set(field, stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set(field::Ptr{Cchar}, stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_u(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_u(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_x(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_x(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_sl(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_sl(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_su(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_su(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_pi(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_pi(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_lb(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_lb(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_lbu(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_lbu(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_lbx(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_lbx(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_ub(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_ub(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_ubu(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_ubu(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_ubx(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_ubx(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_lg(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_lg(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_ug(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_ug(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_ls(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_ls(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_set_lam_us(stage, vec, qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_set_lam_us(stage::Cint, vec::Ptr{Cdouble}, qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

struct d_ocp_qp_res
    dim::Ptr{d_ocp_qp_dim}
    res_g::Ptr{blasfeo_dvec}
    res_b::Ptr{blasfeo_dvec}
    res_d::Ptr{blasfeo_dvec}
    res_m::Ptr{blasfeo_dvec}
    res_max::NTuple{4, Cdouble}
    res_mu_sum::Cdouble
    res_mu::Cdouble
    obj::Cdouble
    dual_gap::Cdouble
    memsize::hpipm_size_t
end

struct d_ocp_qp_res_ws
    tmp_nbgM::Ptr{blasfeo_dvec}
    tmp_nsM::Ptr{blasfeo_dvec}
    tmp_lam_mask::Ptr{blasfeo_dvec}
    nc_mask_inv::Cdouble
    valid_nc_mask::Cint
    mask_constr::Cint
    memsize::hpipm_size_t
end

function d_ocp_qp_res_memsize(ocp_dim)
    @ccall libhpipm.d_ocp_qp_res_memsize(ocp_dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_res_create(ocp_dim, res, mem)
    @ccall libhpipm.d_ocp_qp_res_create(ocp_dim::Ptr{d_ocp_qp_dim}, res::Ptr{d_ocp_qp_res}, mem::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_res_ws_memsize(ocp_dim)
    @ccall libhpipm.d_ocp_qp_res_ws_memsize(ocp_dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_res_ws_create(ocp_dim, workspace, mem)
    @ccall libhpipm.d_ocp_qp_res_ws_create(ocp_dim::Ptr{d_ocp_qp_dim}, workspace::Ptr{d_ocp_qp_res_ws}, mem::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_res_compute(qp, qp_sol, res, ws)
    @ccall libhpipm.d_ocp_qp_res_compute(qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, res::Ptr{d_ocp_qp_res}, ws::Ptr{d_ocp_qp_res_ws})::Cvoid
end

function d_ocp_qp_res_compute_lin(qp, qp_sol, qp_step, res, ws)
    @ccall libhpipm.d_ocp_qp_res_compute_lin(qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, qp_step::Ptr{d_ocp_qp_sol}, res::Ptr{d_ocp_qp_res}, ws::Ptr{d_ocp_qp_res_ws})::Cvoid
end

function d_ocp_qp_res_compute_inf_norm(res)
    @ccall libhpipm.d_ocp_qp_res_compute_inf_norm(res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_get_all(res, res_r, res_q, res_ls, res_us, res_b, res_d_lb, res_d_ub, res_d_lg, res_d_ug, res_d_ls, res_d_us, res_m_lb, res_m_ub, res_m_lg, res_m_ug, res_m_ls, res_m_us)
    @ccall libhpipm.d_ocp_qp_res_get_all(res::Ptr{d_ocp_qp_res}, res_r::Ptr{Ptr{Cdouble}}, res_q::Ptr{Ptr{Cdouble}}, res_ls::Ptr{Ptr{Cdouble}}, res_us::Ptr{Ptr{Cdouble}}, res_b::Ptr{Ptr{Cdouble}}, res_d_lb::Ptr{Ptr{Cdouble}}, res_d_ub::Ptr{Ptr{Cdouble}}, res_d_lg::Ptr{Ptr{Cdouble}}, res_d_ug::Ptr{Ptr{Cdouble}}, res_d_ls::Ptr{Ptr{Cdouble}}, res_d_us::Ptr{Ptr{Cdouble}}, res_m_lb::Ptr{Ptr{Cdouble}}, res_m_ub::Ptr{Ptr{Cdouble}}, res_m_lg::Ptr{Ptr{Cdouble}}, res_m_ug::Ptr{Ptr{Cdouble}}, res_m_ls::Ptr{Ptr{Cdouble}}, res_m_us::Ptr{Ptr{Cdouble}})::Cvoid
end

function d_ocp_qp_res_get_max_res_stat(res, value)
    @ccall libhpipm.d_ocp_qp_res_get_max_res_stat(res::Ptr{d_ocp_qp_res}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_res_get_max_res_eq(res, value)
    @ccall libhpipm.d_ocp_qp_res_get_max_res_eq(res::Ptr{d_ocp_qp_res}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_res_get_max_res_ineq(res, value)
    @ccall libhpipm.d_ocp_qp_res_get_max_res_ineq(res::Ptr{d_ocp_qp_res}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_res_get_max_res_comp(res, value)
    @ccall libhpipm.d_ocp_qp_res_get_max_res_comp(res::Ptr{d_ocp_qp_res}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_res_set_zero(res)
    @ccall libhpipm.d_ocp_qp_res_set_zero(res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set(field, stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set(field::Ptr{Cchar}, stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_r(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_r(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_q(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_q(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_zl(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_zl(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_zu(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_zu(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_b(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_b(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_lb(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_lb(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_lbu(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_lbu(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_lbx(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_lbx(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_ub(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_ub(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_ubu(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_ubu(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_ubx(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_ubx(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_lg(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_lg(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_ug(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_ug(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_ls(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_ls(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_res_set_res_us(stage, vec, qp_res)
    @ccall libhpipm.d_ocp_qp_res_set_res_us(stage::Cint, vec::Ptr{Cdouble}, qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

struct d_ocp_qp_seed
    dim::Ptr{d_ocp_qp_dim}
    seed_g::Ptr{blasfeo_dvec}
    seed_b::Ptr{blasfeo_dvec}
    seed_d::Ptr{blasfeo_dvec}
    seed_m::Ptr{blasfeo_dvec}
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_ocp_qp_seed.h:68:14, please use with caution
function d_ocp_qp_seed_strsize()
    @ccall libhpipm.d_ocp_qp_seed_strsize()::hpipm_size_t
end

function d_ocp_qp_seed_memsize(ocp_dim)
    @ccall libhpipm.d_ocp_qp_seed_memsize(ocp_dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_seed_create(ocp_dim, seed, mem)
    @ccall libhpipm.d_ocp_qp_seed_create(ocp_dim::Ptr{d_ocp_qp_dim}, seed::Ptr{d_ocp_qp_seed}, mem::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_seed_set_zero(seed)
    @ccall libhpipm.d_ocp_qp_seed_set_zero(seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set(field, stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set(field::Ptr{Cchar}, stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_r(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_r(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_q(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_q(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_zl(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_zl(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_zu(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_zu(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_b(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_b(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_lb(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_lb(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_lbu(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_lbu(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_lbx(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_lbx(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_ub(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_ub(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_ubu(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_ubu(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_ubx(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_ubx(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_lg(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_lg(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_ug(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_ug(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_ls(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_ls(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

function d_ocp_qp_seed_set_seed_us(stage, vec, qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_set_seed_us(stage::Cint, vec::Ptr{Cdouble}, qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

struct d_ocp_qp_ipm_arg
    dim::Ptr{d_ocp_qp_dim}
    mu0::Cdouble
    alpha_min::Cdouble
    res_g_max::Cdouble
    res_b_max::Cdouble
    res_d_max::Cdouble
    res_m_max::Cdouble
    dual_gap_max::Cdouble
    reg_prim::Cdouble
    lam_min::Cdouble
    t_min::Cdouble
    tau_min::Cdouble
    lam0_min::Cdouble
    t0_min::Cdouble
    m_safe::Cdouble
    iter_max::Cint
    stat_max::Cint
    pred_corr::Cint
    cond_pred_corr::Cint
    itref_pred_max::Cint
    itref_corr_max::Cint
    warm_start::Cint
    square_root_alg::Cint
    lq_fact::Cint
    abs_form::Cint
    comp_dual_sol_eq::Cint
    comp_res_exit::Cint
    comp_res_pred::Cint
    split_step::Cint
    var_init_scheme::Cint
    t_lam_min::Cint
    t0_init::Cint
    update_fact_exit::Cint
    mode::Cint
    memsize::hpipm_size_t
end

struct d_ocp_qp_ipm_ws
    qp_res::NTuple{4, Cdouble}
    core_workspace::Ptr{d_core_qp_ipm_workspace}
    dim::Ptr{d_ocp_qp_dim}
    res_workspace::Ptr{d_ocp_qp_res_ws}
    sol_step::Ptr{d_ocp_qp_sol}
    sol_itref::Ptr{d_ocp_qp_sol}
    qp_step::Ptr{d_ocp_qp}
    qp_itref::Ptr{d_ocp_qp}
    res_itref::Ptr{d_ocp_qp_res}
    res::Ptr{d_ocp_qp_res}
    Gamma::Ptr{blasfeo_dvec}
    gamma::Ptr{blasfeo_dvec}
    tmp_nuxM::Ptr{blasfeo_dvec}
    tmp_nbgM::Ptr{blasfeo_dvec}
    Pb::Ptr{blasfeo_dvec}
    Zs_inv::Ptr{blasfeo_dvec}
    tmp_m::Ptr{blasfeo_dvec}
    l::Ptr{blasfeo_dvec}
    L::Ptr{blasfeo_dmat}
    Ls::Ptr{blasfeo_dmat}
    P::Ptr{blasfeo_dmat}
    Lh::Ptr{blasfeo_dmat}
    AL::Ptr{blasfeo_dmat}
    lq0::Ptr{blasfeo_dmat}
    tmp_nxM_nxM::Ptr{blasfeo_dmat}
    stat::Ptr{Cdouble}
    use_hess_fact::Ptr{Cint}
    lq_work0::Ptr{Cvoid}
    iter::Cint
    stat_max::Cint
    stat_m::Cint
    use_Pb::Cint
    status::Cint
    square_root_alg::Cint
    lq_fact::Cint
    mask_constr::Cint
    valid_ric_vec::Cint
    valid_ric_p::Cint
    memsize::hpipm_size_t
end

# no prototype is found for this function at hpipm_d_ocp_qp_ipm.h:146:14, please use with caution
function d_ocp_qp_ipm_arg_strsize()
    @ccall libhpipm.d_ocp_qp_ipm_arg_strsize()::hpipm_size_t
end

function d_ocp_qp_ipm_arg_memsize(ocp_dim)
    @ccall libhpipm.d_ocp_qp_ipm_arg_memsize(ocp_dim::Ptr{d_ocp_qp_dim})::hpipm_size_t
end

function d_ocp_qp_ipm_arg_create(ocp_dim, arg, mem)
    @ccall libhpipm.d_ocp_qp_ipm_arg_create(ocp_dim::Ptr{d_ocp_qp_dim}, arg::Ptr{d_ocp_qp_ipm_arg}, mem::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_ipm_arg_set_default(mode, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_default(mode::hpipm_mode, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set(field, value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set(field::Ptr{Cchar}, value::Ptr{Cvoid}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_iter_max(iter_max, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_iter_max(iter_max::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_alpha_min(alpha_min, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_alpha_min(alpha_min::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_mu0(mu0, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_mu0(mu0::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tol_stat(tol_stat, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tol_stat(tol_stat::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tol_eq(tol_eq, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tol_eq(tol_eq::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tol_ineq(tol_ineq, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tol_ineq(tol_ineq::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tol_comp(tol_comp, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tol_comp(tol_comp::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tol_dual_gap(tol_dual_gap, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tol_dual_gap(tol_dual_gap::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_reg_prim(reg_prim, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_reg_prim(reg_prim::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_warm_start(warm_start, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_warm_start(warm_start::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_pred_corr(pred_corr, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_pred_corr(pred_corr::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_cond_pred_corr(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_cond_pred_corr(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_ric_alg(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_ric_alg(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_comp_dual_sol_eq(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_comp_dual_sol_eq(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_comp_res_exit(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_comp_res_exit(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_comp_res_pred(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_comp_res_pred(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_lam_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_lam_min(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_t_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_t_min(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_tau_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_tau_min(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_lam0_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_lam0_min(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_t0_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_t0_min(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_split_step(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_split_step(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_m_safe(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_m_safe(value::Ptr{Cdouble}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_var_init_scheme(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_var_init_scheme(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_t_lam_min(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_t_lam_min(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_t0_init(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_t0_init(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_set_update_fact_exit(value, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_set_update_fact_exit(value::Ptr{Cint}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_get(field, arg, value)
    @ccall libhpipm.d_ocp_qp_ipm_arg_get(field::Ptr{Cchar}, arg::Ptr{d_ocp_qp_ipm_arg}, value::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_ipm_arg_get_lam0_min(arg, value)
    @ccall libhpipm.d_ocp_qp_ipm_arg_get_lam0_min(arg::Ptr{d_ocp_qp_ipm_arg}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_arg_get_t0_min(arg, value)
    @ccall libhpipm.d_ocp_qp_ipm_arg_get_t0_min(arg::Ptr{d_ocp_qp_ipm_arg}, value::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_arg_deepcopy(arg_s, arg_d)
    @ccall libhpipm.d_ocp_qp_ipm_arg_deepcopy(arg_s::Ptr{d_ocp_qp_ipm_arg}, arg_d::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

# no prototype is found for this function at hpipm_d_ocp_qp_ipm.h:219:14, please use with caution
function d_ocp_qp_ipm_ws_strsize()
    @ccall libhpipm.d_ocp_qp_ipm_ws_strsize()::hpipm_size_t
end

function d_ocp_qp_ipm_ws_memsize(ocp_dim, arg)
    @ccall libhpipm.d_ocp_qp_ipm_ws_memsize(ocp_dim::Ptr{d_ocp_qp_dim}, arg::Ptr{d_ocp_qp_ipm_arg})::hpipm_size_t
end

function d_ocp_qp_ipm_ws_create(ocp_dim, arg, ws, mem)
    @ccall libhpipm.d_ocp_qp_ipm_ws_create(ocp_dim::Ptr{d_ocp_qp_dim}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, mem::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_ipm_get(field, ws, value)
    @ccall libhpipm.d_ocp_qp_ipm_get(field::Ptr{Cchar}, ws::Ptr{d_ocp_qp_ipm_ws}, value::Ptr{Cvoid})::Cvoid
end

function d_ocp_qp_ipm_get_status(ws, status)
    @ccall libhpipm.d_ocp_qp_ipm_get_status(ws::Ptr{d_ocp_qp_ipm_ws}, status::Ptr{Cint})::Cvoid
end

function d_ocp_qp_ipm_get_iter(ws, iter)
    @ccall libhpipm.d_ocp_qp_ipm_get_iter(ws::Ptr{d_ocp_qp_ipm_ws}, iter::Ptr{Cint})::Cvoid
end

function d_ocp_qp_ipm_get_max_res_stat(ws, res_stat)
    @ccall libhpipm.d_ocp_qp_ipm_get_max_res_stat(ws::Ptr{d_ocp_qp_ipm_ws}, res_stat::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_max_res_eq(ws, res_eq)
    @ccall libhpipm.d_ocp_qp_ipm_get_max_res_eq(ws::Ptr{d_ocp_qp_ipm_ws}, res_eq::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_max_res_ineq(ws, res_ineq)
    @ccall libhpipm.d_ocp_qp_ipm_get_max_res_ineq(ws::Ptr{d_ocp_qp_ipm_ws}, res_ineq::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_max_res_comp(ws, res_comp)
    @ccall libhpipm.d_ocp_qp_ipm_get_max_res_comp(ws::Ptr{d_ocp_qp_ipm_ws}, res_comp::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_dual_gap(ws, dual_gap)
    @ccall libhpipm.d_ocp_qp_ipm_get_dual_gap(ws::Ptr{d_ocp_qp_ipm_ws}, dual_gap::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_obj(ws, obj)
    @ccall libhpipm.d_ocp_qp_ipm_get_obj(ws::Ptr{d_ocp_qp_ipm_ws}, obj::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_tau_iter(ws, tau_iter)
    @ccall libhpipm.d_ocp_qp_ipm_get_tau_iter(ws::Ptr{d_ocp_qp_ipm_ws}, tau_iter::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_stat(ws, stat)
    @ccall libhpipm.d_ocp_qp_ipm_get_stat(ws::Ptr{d_ocp_qp_ipm_ws}, stat::Ptr{Ptr{Cdouble}})::Cvoid
end

function d_ocp_qp_ipm_get_stat_m(ws, stat_m)
    @ccall libhpipm.d_ocp_qp_ipm_get_stat_m(ws::Ptr{d_ocp_qp_ipm_ws}, stat_m::Ptr{Cint})::Cvoid
end

function d_ocp_qp_ipm_get_ric_Lr(qp, arg, ws, stage, Lr)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_Lr(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, Lr::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_Ls(qp, arg, ws, stage, Ls)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_Ls(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, Ls::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_P(qp, arg, ws, stage, P)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_P(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, P::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_lr(qp, arg, ws, stage, lr)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_lr(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, lr::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_p(qp, arg, ws, stage, p)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_p(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, p::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_K(qp, arg, ws, stage, K)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_K(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, K::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_ipm_get_ric_k(qp, arg, ws, stage, k)
    @ccall libhpipm.d_ocp_qp_ipm_get_ric_k(qp::Ptr{d_ocp_qp}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws}, stage::Cint, k::Ptr{Cdouble})::Cvoid
end

function d_ocp_qp_init_var(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_ocp_qp_init_var(qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_abs_step(kk, qp, qp_sol, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_abs_step(kk::Cint, qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_delta_step(kk, qp, qp_sol, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_delta_step(kk::Cint, qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_solve(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_solve(qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_predict(qp, qp_sol, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_predict(qp::Ptr{d_ocp_qp}, qp_sol::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_sens_frw(qp, seed, sens, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_sens_frw(qp::Ptr{d_ocp_qp}, seed::Ptr{d_ocp_qp_seed}, sens::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_ipm_sens_adj(qp, seed, sens, arg, ws)
    @ccall libhpipm.d_ocp_qp_ipm_sens_adj(qp::Ptr{d_ocp_qp}, seed::Ptr{d_ocp_qp_seed}, sens::Ptr{d_ocp_qp_sol}, arg::Ptr{d_ocp_qp_ipm_arg}, ws::Ptr{d_ocp_qp_ipm_ws})::Cvoid
end

function d_ocp_qp_dim_print(qp_dim)
    @ccall libhpipm.d_ocp_qp_dim_print(qp_dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_dim_codegen(file_name, mode, qp_dim)
    @ccall libhpipm.d_ocp_qp_dim_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_ocp_qp_dim})::Cvoid
end

function d_ocp_qp_print(qp_dim, qp)
    @ccall libhpipm.d_ocp_qp_print(qp_dim::Ptr{d_ocp_qp_dim}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_codegen(file_name, mode, qp_dim, qp)
    @ccall libhpipm.d_ocp_qp_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_ocp_qp_dim}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_codegen_matlab(file_name, mode, qp_dim, qp)
    @ccall libhpipm.d_ocp_qp_codegen_matlab(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_ocp_qp_dim}, qp::Ptr{d_ocp_qp})::Cvoid
end

function d_ocp_qp_sol_print(qp_dim, ocp_qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_print(qp_dim::Ptr{d_ocp_qp_dim}, ocp_qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_sol_print_exp(qp_dim, ocp_qp_sol)
    @ccall libhpipm.d_ocp_qp_sol_print_exp(qp_dim::Ptr{d_ocp_qp_dim}, ocp_qp_sol::Ptr{d_ocp_qp_sol})::Cvoid
end

function d_ocp_qp_ipm_arg_print(qp_dim, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_print(qp_dim::Ptr{d_ocp_qp_dim}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_ipm_arg_codegen(file_name, mode, qp_dim, arg)
    @ccall libhpipm.d_ocp_qp_ipm_arg_codegen(file_name::Ptr{Cchar}, mode::Ptr{Cchar}, qp_dim::Ptr{d_ocp_qp_dim}, arg::Ptr{d_ocp_qp_ipm_arg})::Cvoid
end

function d_ocp_qp_res_print(qp_dim, ocp_qp_res)
    @ccall libhpipm.d_ocp_qp_res_print(qp_dim::Ptr{d_ocp_qp_dim}, ocp_qp_res::Ptr{d_ocp_qp_res})::Cvoid
end

function d_ocp_qp_seed_print(qp_dim, ocp_qp_seed)
    @ccall libhpipm.d_ocp_qp_seed_print(qp_dim::Ptr{d_ocp_qp_dim}, ocp_qp_seed::Ptr{d_ocp_qp_seed})::Cvoid
end

struct blasfeo_smat
    mem::Ptr{Cfloat}
    pA::Ptr{Cfloat}
    dA::Ptr{Cfloat}
    m::Cint
    n::Cint
    pm::Cint
    cn::Cint
    use_dA::Cint
    memsize::Cint
end

struct blasfeo_svec
    mem::Ptr{Cfloat}
    pa::Ptr{Cfloat}
    m::Cint
    pm::Cint
    memsize::Cint
end

struct blasfeo_pm_dmat
    mem::Ptr{Cdouble}
    pA::Ptr{Cdouble}
    dA::Ptr{Cdouble}
    m::Cint
    n::Cint
    pm::Cint
    cn::Cint
    use_dA::Cint
    ps::Cint
    memsize::Cint
end

struct blasfeo_pm_smat
    mem::Ptr{Cfloat}
    pA::Ptr{Cfloat}
    dA::Ptr{Cfloat}
    m::Cint
    n::Cint
    pm::Cint
    cn::Cint
    use_dA::Cint
    ps::Cint
    memsize::Cint
end

struct blasfeo_pm_dvec
    mem::Ptr{Cdouble}
    pa::Ptr{Cdouble}
    m::Cint
    pm::Cint
    memsize::Cint
end

struct blasfeo_pm_svec
    mem::Ptr{Cfloat}
    pa::Ptr{Cfloat}
    m::Cint
    pm::Cint
    memsize::Cint
end

struct blasfeo_cm_dmat
    mem::Ptr{Cdouble}
    pA::Ptr{Cdouble}
    dA::Ptr{Cdouble}
    m::Cint
    n::Cint
    use_dA::Cint
    memsize::Cint
end

struct blasfeo_cm_smat
    mem::Ptr{Cfloat}
    pA::Ptr{Cfloat}
    dA::Ptr{Cfloat}
    m::Cint
    n::Cint
    use_dA::Cint
    memsize::Cint
end

struct blasfeo_cm_dvec
    mem::Ptr{Cdouble}
    pa::Ptr{Cdouble}
    m::Cint
    memsize::Cint
end

struct blasfeo_cm_svec
    mem::Ptr{Cfloat}
    pa::Ptr{Cfloat}
    m::Cint
    memsize::Cint
end

function dtrcp_l_lib(m, alpha, offsetA, A, sda, offsetB, B, sdb)
    @ccall libhpipm.dtrcp_l_lib(m::Cint, alpha::Cdouble, offsetA::Cint, A::Ptr{Cdouble}, sda::Cint, offsetB::Cint, B::Ptr{Cdouble}, sdb::Cint)::Cvoid
end

function dgead_lib(m, n, alpha, offsetA, A, sda, offsetB, B, sdb)
    @ccall libhpipm.dgead_lib(m::Cint, n::Cint, alpha::Cdouble, offsetA::Cint, A::Ptr{Cdouble}, sda::Cint, offsetB::Cint, B::Ptr{Cdouble}, sdb::Cint)::Cvoid
end

function ddiain_sqrt_lib(kmax, x, offset, pD, sdd)
    @ccall libhpipm.ddiain_sqrt_lib(kmax::Cint, x::Ptr{Cdouble}, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function ddiareg_lib(kmax, reg, offset, pD, sdd)
    @ccall libhpipm.ddiareg_lib(kmax::Cint, reg::Cdouble, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function dgetr_lib(m, n, alpha, offsetA, pA, sda, offsetC, pC, sdc)
    @ccall libhpipm.dgetr_lib(m::Cint, n::Cint, alpha::Cdouble, offsetA::Cint, pA::Ptr{Cdouble}, sda::Cint, offsetC::Cint, pC::Ptr{Cdouble}, sdc::Cint)::Cvoid
end

function dtrtr_l_lib(m, alpha, offsetA, pA, sda, offsetC, pC, sdc)
    @ccall libhpipm.dtrtr_l_lib(m::Cint, alpha::Cdouble, offsetA::Cint, pA::Ptr{Cdouble}, sda::Cint, offsetC::Cint, pC::Ptr{Cdouble}, sdc::Cint)::Cvoid
end

function dtrtr_u_lib(m, alpha, offsetA, pA, sda, offsetC, pC, sdc)
    @ccall libhpipm.dtrtr_u_lib(m::Cint, alpha::Cdouble, offsetA::Cint, pA::Ptr{Cdouble}, sda::Cint, offsetC::Cint, pC::Ptr{Cdouble}, sdc::Cint)::Cvoid
end

function ddiaex_lib(kmax, alpha, offset, pD, sdd, x)
    @ccall libhpipm.ddiaex_lib(kmax::Cint, alpha::Cdouble, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint, x::Ptr{Cdouble})::Cvoid
end

function ddiaad_lib(kmax, alpha, x, offset, pD, sdd)
    @ccall libhpipm.ddiaad_lib(kmax::Cint, alpha::Cdouble, x::Ptr{Cdouble}, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function ddiain_libsp(kmax, idx, alpha, x, pD, sdd)
    @ccall libhpipm.ddiain_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function ddiaex_libsp(kmax, idx, alpha, pD, sdd, x)
    @ccall libhpipm.ddiaex_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, pD::Ptr{Cdouble}, sdd::Cint, x::Ptr{Cdouble})::Cvoid
end

function ddiaad_libsp(kmax, idx, alpha, x, pD, sdd)
    @ccall libhpipm.ddiaad_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function ddiaadin_libsp(kmax, idx, alpha, x, y, pD, sdd)
    @ccall libhpipm.ddiaadin_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, y::Ptr{Cdouble}, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function drowin_lib(kmax, alpha, x, pD)
    @ccall libhpipm.drowin_lib(kmax::Cint, alpha::Cdouble, x::Ptr{Cdouble}, pD::Ptr{Cdouble})::Cvoid
end

function drowex_lib(kmax, alpha, pD, x)
    @ccall libhpipm.drowex_lib(kmax::Cint, alpha::Cdouble, pD::Ptr{Cdouble}, x::Ptr{Cdouble})::Cvoid
end

function drowad_lib(kmax, alpha, x, pD)
    @ccall libhpipm.drowad_lib(kmax::Cint, alpha::Cdouble, x::Ptr{Cdouble}, pD::Ptr{Cdouble})::Cvoid
end

function drowin_libsp(kmax, alpha, idx, x, pD)
    @ccall libhpipm.drowin_libsp(kmax::Cint, alpha::Cdouble, idx::Ptr{Cint}, x::Ptr{Cdouble}, pD::Ptr{Cdouble})::Cvoid
end

function drowad_libsp(kmax, idx, alpha, x, pD)
    @ccall libhpipm.drowad_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, pD::Ptr{Cdouble})::Cvoid
end

function drowadin_libsp(kmax, idx, alpha, x, y, pD)
    @ccall libhpipm.drowadin_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, y::Ptr{Cdouble}, pD::Ptr{Cdouble})::Cvoid
end

function dcolin_lib(kmax, x, offset, pD, sdd)
    @ccall libhpipm.dcolin_lib(kmax::Cint, x::Ptr{Cdouble}, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function dcolad_lib(kmax, alpha, x, offset, pD, sdd)
    @ccall libhpipm.dcolad_lib(kmax::Cint, alpha::Cdouble, x::Ptr{Cdouble}, offset::Cint, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function dcolin_libsp(kmax, idx, x, pD, sdd)
    @ccall libhpipm.dcolin_libsp(kmax::Cint, idx::Ptr{Cint}, x::Ptr{Cdouble}, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function dcolad_libsp(kmax, alpha, idx, x, pD, sdd)
    @ccall libhpipm.dcolad_libsp(kmax::Cint, alpha::Cdouble, idx::Ptr{Cint}, x::Ptr{Cdouble}, pD::Ptr{Cdouble}, sdd::Cint)::Cvoid
end

function dcolsw_lib(kmax, offsetA, pA, sda, offsetC, pC, sdc)
    @ccall libhpipm.dcolsw_lib(kmax::Cint, offsetA::Cint, pA::Ptr{Cdouble}, sda::Cint, offsetC::Cint, pC::Ptr{Cdouble}, sdc::Cint)::Cvoid
end

function dvecin_libsp(kmax, idx, x, y)
    @ccall libhpipm.dvecin_libsp(kmax::Cint, idx::Ptr{Cint}, x::Ptr{Cdouble}, y::Ptr{Cdouble})::Cvoid
end

function dvecad_libsp(kmax, idx, alpha, x, y)
    @ccall libhpipm.dvecad_libsp(kmax::Cint, idx::Ptr{Cint}, alpha::Cdouble, x::Ptr{Cdouble}, y::Ptr{Cdouble})::Cvoid
end

function blasfeo_memsize_dmat(m, n)
    @ccall libhpipm.blasfeo_memsize_dmat(m::Cint, n::Cint)::Csize_t
end

function blasfeo_memsize_diag_dmat(m, n)
    @ccall libhpipm.blasfeo_memsize_diag_dmat(m::Cint, n::Cint)::Csize_t
end

function blasfeo_memsize_dvec(m)
    @ccall libhpipm.blasfeo_memsize_dvec(m::Cint)::Csize_t
end

function blasfeo_create_dmat(m, n, sA, memory)
    @ccall libhpipm.blasfeo_create_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, memory::Ptr{Cvoid})::Cvoid
end

function blasfeo_create_dvec(m, sA, memory)
    @ccall libhpipm.blasfeo_create_dvec(m::Cint, sA::Ptr{blasfeo_dvec}, memory::Ptr{Cvoid})::Cvoid
end

function blasfeo_pack_dmat(m, n, A, lda, sB, bi, bj)
    @ccall libhpipm.blasfeo_pack_dmat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_pack_l_dmat(m, n, A, lda, sB, bi, bj)
    @ccall libhpipm.blasfeo_pack_l_dmat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_pack_u_dmat(m, n, A, lda, sB, bi, bj)
    @ccall libhpipm.blasfeo_pack_u_dmat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_pack_tran_dmat(m, n, A, lda, sB, bi, bj)
    @ccall libhpipm.blasfeo_pack_tran_dmat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_pack_dvec(m, x, incx, sy, yi)
    @ccall libhpipm.blasfeo_pack_dvec(m::Cint, x::Ptr{Cdouble}, incx::Cint, sy::Ptr{blasfeo_dvec}, yi::Cint)::Cvoid
end

function blasfeo_unpack_dmat(m, n, sA, ai, aj, B, ldb)
    @ccall libhpipm.blasfeo_unpack_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, B::Ptr{Cdouble}, ldb::Cint)::Cvoid
end

function blasfeo_unpack_tran_dmat(m, n, sA, ai, aj, B, ldb)
    @ccall libhpipm.blasfeo_unpack_tran_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, B::Ptr{Cdouble}, ldb::Cint)::Cvoid
end

function blasfeo_unpack_dvec(m, sx, xi, y, incy)
    @ccall libhpipm.blasfeo_unpack_dvec(m::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, y::Ptr{Cdouble}, incy::Cint)::Cvoid
end

function blasfeo_dgein1(a, sA, ai, aj)
    @ccall libhpipm.blasfeo_dgein1(a::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dgeex1(sA, ai, aj)
    @ccall libhpipm.blasfeo_dgeex1(sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cdouble
end

function blasfeo_dgese(m, n, alpha, sA, ai, aj)
    @ccall libhpipm.blasfeo_dgese(m::Cint, n::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dgecp(m, n, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dgecp(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dgesc(m, n, alpha, sA, ai, aj)
    @ccall libhpipm.blasfeo_dgesc(m::Cint, n::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dgecpsc(m, n, alpha, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dgecpsc(m::Cint, n::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dtrcp_l(m, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dtrcp_l(m::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dtrcpsc_l(m, alpha, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dtrcpsc_l(m::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dtrsc_l(m, alpha, sA, ai, aj)
    @ccall libhpipm.blasfeo_dtrsc_l(m::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dgead(m, n, alpha, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dgead(m::Cint, n::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dvecad(m, alpha, sx, xi, sy, yi)
    @ccall libhpipm.blasfeo_dvecad(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sy::Ptr{blasfeo_dvec}, yi::Cint)::Cvoid
end

function blasfeo_dgetr(m, n, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dgetr(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dtrtr_l(m, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dtrtr_l(m::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_dtrtr_u(m, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_dtrtr_u(m::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function blasfeo_ddiare(kmax, alpha, sA, ai, aj)
    @ccall libhpipm.blasfeo_ddiare(kmax::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_ddiain(kmax, alpha, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_ddiain(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_ddiain_sp(kmax, alpha, sx, xi, idx, sD, di, dj)
    @ccall libhpipm.blasfeo_ddiain_sp(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, idx::Ptr{Cint}, sD::Ptr{blasfeo_dmat}, di::Cint, dj::Cint)::Cvoid
end

function blasfeo_ddiaex(kmax, alpha, sA, ai, aj, sx, xi)
    @ccall libhpipm.blasfeo_ddiaex(kmax::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_ddiaex_sp(kmax, alpha, idx, sD, di, dj, sx, xi)
    @ccall libhpipm.blasfeo_ddiaex_sp(kmax::Cint, alpha::Cdouble, idx::Ptr{Cint}, sD::Ptr{blasfeo_dmat}, di::Cint, dj::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_ddiaad(kmax, alpha, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_ddiaad(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_ddiaad_sp(kmax, alpha, sx, xi, idx, sD, di, dj)
    @ccall libhpipm.blasfeo_ddiaad_sp(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, idx::Ptr{Cint}, sD::Ptr{blasfeo_dmat}, di::Cint, dj::Cint)::Cvoid
end

function blasfeo_ddiaadin_sp(kmax, alpha, sx, xi, sy, yi, idx, sD, di, dj)
    @ccall libhpipm.blasfeo_ddiaadin_sp(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sy::Ptr{blasfeo_dvec}, yi::Cint, idx::Ptr{Cint}, sD::Ptr{blasfeo_dmat}, di::Cint, dj::Cint)::Cvoid
end

function blasfeo_drowin(kmax, alpha, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_drowin(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_drowex(kmax, alpha, sA, ai, aj, sx, xi)
    @ccall libhpipm.blasfeo_drowex(kmax::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_drowad(kmax, alpha, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_drowad(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_drowad_sp(kmax, alpha, sx, xi, idx, sD, di, dj)
    @ccall libhpipm.blasfeo_drowad_sp(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, idx::Ptr{Cint}, sD::Ptr{blasfeo_dmat}, di::Cint, dj::Cint)::Cvoid
end

function blasfeo_drowsw(kmax, sA, ai, aj, sC, ci, cj)
    @ccall libhpipm.blasfeo_drowsw(kmax::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sC::Ptr{blasfeo_dmat}, ci::Cint, cj::Cint)::Cvoid
end

function blasfeo_drowpe(kmax, ipiv, sA)
    @ccall libhpipm.blasfeo_drowpe(kmax::Cint, ipiv::Ptr{Cint}, sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_drowpei(kmax, ipiv, sA)
    @ccall libhpipm.blasfeo_drowpei(kmax::Cint, ipiv::Ptr{Cint}, sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_dcolex(kmax, sA, ai, aj, sx, xi)
    @ccall libhpipm.blasfeo_dcolex(kmax::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_dcolin(kmax, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_dcolin(kmax::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dcolad(kmax, alpha, sx, xi, sA, ai, aj)
    @ccall libhpipm.blasfeo_dcolad(kmax::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dcolsc(kmax, alpha, sA, ai, aj)
    @ccall libhpipm.blasfeo_dcolsc(kmax::Cint, alpha::Cdouble, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_dcolsw(kmax, sA, ai, aj, sC, ci, cj)
    @ccall libhpipm.blasfeo_dcolsw(kmax::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint, sC::Ptr{blasfeo_dmat}, ci::Cint, cj::Cint)::Cvoid
end

function blasfeo_dcolpe(kmax, ipiv, sA)
    @ccall libhpipm.blasfeo_dcolpe(kmax::Cint, ipiv::Ptr{Cint}, sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_dcolpei(kmax, ipiv, sA)
    @ccall libhpipm.blasfeo_dcolpei(kmax::Cint, ipiv::Ptr{Cint}, sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_dvecse(m, alpha, sx, xi)
    @ccall libhpipm.blasfeo_dvecse(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_dvecin1(a, sx, xi)
    @ccall libhpipm.blasfeo_dvecin1(a::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_dvecex1(sx, xi)
    @ccall libhpipm.blasfeo_dvecex1(sx::Ptr{blasfeo_dvec}, xi::Cint)::Cdouble
end

function blasfeo_dveccp(m, sx, xi, sy, yi)
    @ccall libhpipm.blasfeo_dveccp(m::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, sy::Ptr{blasfeo_dvec}, yi::Cint)::Cvoid
end

function blasfeo_dvecsc(m, alpha, sx, xi)
    @ccall libhpipm.blasfeo_dvecsc(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_dveccpsc(m, alpha, sx, xi, sy, yi)
    @ccall libhpipm.blasfeo_dveccpsc(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, sy::Ptr{blasfeo_dvec}, yi::Cint)::Cvoid
end

function blasfeo_dvecad_sp(m, alpha, sx, xi, idx, sz, zi)
    @ccall libhpipm.blasfeo_dvecad_sp(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, idx::Ptr{Cint}, sz::Ptr{blasfeo_dvec}, zi::Cint)::Cvoid
end

function blasfeo_dvecin_sp(m, alpha, sx, xi, idx, sz, zi)
    @ccall libhpipm.blasfeo_dvecin_sp(m::Cint, alpha::Cdouble, sx::Ptr{blasfeo_dvec}, xi::Cint, idx::Ptr{Cint}, sz::Ptr{blasfeo_dvec}, zi::Cint)::Cvoid
end

function blasfeo_dvecex_sp(m, alpha, idx, sx, xi, sz, zi)
    @ccall libhpipm.blasfeo_dvecex_sp(m::Cint, alpha::Cdouble, idx::Ptr{Cint}, sx::Ptr{blasfeo_dvec}, xi::Cint, sz::Ptr{blasfeo_dvec}, zi::Cint)::Cvoid
end

function blasfeo_dvecexad_sp(m, alpha, idx, sx, xi, sz, zi)
    @ccall libhpipm.blasfeo_dvecexad_sp(m::Cint, alpha::Cdouble, idx::Ptr{Cint}, sx::Ptr{blasfeo_dvec}, xi::Cint, sz::Ptr{blasfeo_dvec}, zi::Cint)::Cvoid
end

function blasfeo_dveccl(m, sxm, xim, sx, xi, sxp, xip, sz, zi)
    @ccall libhpipm.blasfeo_dveccl(m::Cint, sxm::Ptr{blasfeo_dvec}, xim::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, sxp::Ptr{blasfeo_dvec}, xip::Cint, sz::Ptr{blasfeo_dvec}, zi::Cint)::Cvoid
end

function blasfeo_dveccl_mask(m, sxm, xim, sx, xi, sxp, xip, sz, zi, sm, mi)
    @ccall libhpipm.blasfeo_dveccl_mask(m::Cint, sxm::Ptr{blasfeo_dvec}, xim::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, sxp::Ptr{blasfeo_dvec}, xip::Cint, sz::Ptr{blasfeo_dvec}, zi::Cint, sm::Ptr{blasfeo_dvec}, mi::Cint)::Cvoid
end

function blasfeo_dvecze(m, sm, mi, sv, vi, se, ei)
    @ccall libhpipm.blasfeo_dvecze(m::Cint, sm::Ptr{blasfeo_dvec}, mi::Cint, sv::Ptr{blasfeo_dvec}, vi::Cint, se::Ptr{blasfeo_dvec}, ei::Cint)::Cvoid
end

function blasfeo_dvecnrm_inf(m, sx, xi, ptr_norm)
    @ccall libhpipm.blasfeo_dvecnrm_inf(m::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, ptr_norm::Ptr{Cdouble})::Cvoid
end

function blasfeo_dvecnrm_2(m, sx, xi, ptr_norm)
    @ccall libhpipm.blasfeo_dvecnrm_2(m::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, ptr_norm::Ptr{Cdouble})::Cvoid
end

function blasfeo_dvecnrm_1(m, sx, xi, ptr_norm)
    @ccall libhpipm.blasfeo_dvecnrm_1(m::Cint, sx::Ptr{blasfeo_dvec}, xi::Cint, ptr_norm::Ptr{Cdouble})::Cvoid
end

function blasfeo_dvecpe(kmax, ipiv, sx, xi)
    @ccall libhpipm.blasfeo_dvecpe(kmax::Cint, ipiv::Ptr{Cint}, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_dvecpei(kmax, ipiv, sx, xi)
    @ccall libhpipm.blasfeo_dvecpei(kmax::Cint, ipiv::Ptr{Cint}, sx::Ptr{blasfeo_dvec}, xi::Cint)::Cvoid
end

function blasfeo_pm_memsize_dmat(ps, m, n)
    @ccall libhpipm.blasfeo_pm_memsize_dmat(ps::Cint, m::Cint, n::Cint)::Csize_t
end

function blasfeo_pm_create_dmat(ps, m, n, sA, memory)
    @ccall libhpipm.blasfeo_pm_create_dmat(ps::Cint, m::Cint, n::Cint, sA::Ptr{blasfeo_pm_dmat}, memory::Ptr{Cvoid})::Cvoid
end

function blasfeo_pm_print_dmat(m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_pm_print_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_pm_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_cm_memsize_dmat(m, n)
    @ccall libhpipm.blasfeo_cm_memsize_dmat(m::Cint, n::Cint)::Csize_t
end

function blasfeo_cm_create_dmat(m, n, sA, memory)
    @ccall libhpipm.blasfeo_cm_create_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_pm_dmat}, memory::Ptr{Cvoid})::Cvoid
end

function blasfeo_cm_dgetr(m, n, sA, ai, aj, sB, bi, bj)
    @ccall libhpipm.blasfeo_cm_dgetr(m::Cint, n::Cint, sA::Ptr{blasfeo_cm_dmat}, ai::Cint, aj::Cint, sB::Ptr{blasfeo_cm_dmat}, bi::Cint, bj::Cint)::Cvoid
end

function d_zeros(pA, row, col)
    @ccall libhpipm.d_zeros(pA::Ptr{Ptr{Cdouble}}, row::Cint, col::Cint)::Cvoid
end

function d_zeros_align(pA, row, col)
    @ccall libhpipm.d_zeros_align(pA::Ptr{Ptr{Cdouble}}, row::Cint, col::Cint)::Cvoid
end

function d_zeros_align_bytes(pA, size)
    @ccall libhpipm.d_zeros_align_bytes(pA::Ptr{Ptr{Cdouble}}, size::Cint)::Cvoid
end

function d_free(pA)
    @ccall libhpipm.d_free(pA::Ptr{Cdouble})::Cvoid
end

function d_free_align(pA)
    @ccall libhpipm.d_free_align(pA::Ptr{Cdouble})::Cvoid
end

function d_print_mat(m, n, A, lda)
    @ccall libhpipm.d_print_mat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_exp_mat(m, n, A, lda)
    @ccall libhpipm.d_print_exp_mat(m::Cint, n::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_tran_mat(row, col, A, lda)
    @ccall libhpipm.d_print_tran_mat(row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_exp_tran_mat(row, col, A, lda)
    @ccall libhpipm.d_print_exp_tran_mat(row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_to_file_mat(file, row, col, A, lda)
    @ccall libhpipm.d_print_to_file_mat(file::Ptr{Libc.FILE}, row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_to_file_exp_mat(file, row, col, A, lda)
    @ccall libhpipm.d_print_to_file_exp_mat(file::Ptr{Libc.FILE}, row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_tran_to_file_mat(file, row, col, A, lda)
    @ccall libhpipm.d_print_tran_to_file_mat(file::Ptr{Libc.FILE}, row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_tran_to_file_exp_mat(file, row, col, A, lda)
    @ccall libhpipm.d_print_tran_to_file_exp_mat(file::Ptr{Libc.FILE}, row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function d_print_to_string_mat(buf_out, row, col, A, lda)
    @ccall libhpipm.d_print_to_string_mat(buf_out::Ptr{Ptr{Cchar}}, row::Cint, col::Cint, A::Ptr{Cdouble}, lda::Cint)::Cvoid
end

function blasfeo_allocate_dmat(m, n, sA)
    @ccall libhpipm.blasfeo_allocate_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_allocate_dvec(m, sa)
    @ccall libhpipm.blasfeo_allocate_dvec(m::Cint, sa::Ptr{blasfeo_dvec})::Cvoid
end

function blasfeo_free_dmat(sA)
    @ccall libhpipm.blasfeo_free_dmat(sA::Ptr{blasfeo_dmat})::Cvoid
end

function blasfeo_free_dvec(sa)
    @ccall libhpipm.blasfeo_free_dvec(sa::Ptr{blasfeo_dvec})::Cvoid
end

function blasfeo_print_dmat(m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_exp_dmat(m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_exp_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_tran_dmat(m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_tran_dmat(m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_dvec(m, sa, ai)
    @ccall libhpipm.blasfeo_print_dvec(m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_exp_dvec(m, sa, ai)
    @ccall libhpipm.blasfeo_print_exp_dvec(m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_tran_dvec(m, sa, ai)
    @ccall libhpipm.blasfeo_print_tran_dvec(m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_exp_tran_dvec(m, sa, ai)
    @ccall libhpipm.blasfeo_print_exp_tran_dvec(m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_to_file_dmat(file, m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_to_file_dmat(file::Ptr{Libc.FILE}, m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_to_file_exp_dmat(file, m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_to_file_exp_dmat(file::Ptr{Libc.FILE}, m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_to_file_dvec(file, m, sa, ai)
    @ccall libhpipm.blasfeo_print_to_file_dvec(file::Ptr{Libc.FILE}, m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_to_file_tran_dvec(file, m, sa, ai)
    @ccall libhpipm.blasfeo_print_to_file_tran_dvec(file::Ptr{Libc.FILE}, m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_to_string_dvec(buf_out, m, sa, ai)
    @ccall libhpipm.blasfeo_print_to_string_dvec(buf_out::Ptr{Ptr{Cchar}}, m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

function blasfeo_print_to_string_dmat(buf_out, m, n, sA, ai, aj)
    @ccall libhpipm.blasfeo_print_to_string_dmat(buf_out::Ptr{Ptr{Cchar}}, m::Cint, n::Cint, sA::Ptr{blasfeo_dmat}, ai::Cint, aj::Cint)::Cvoid
end

function blasfeo_print_to_string_tran_dvec(buf_out, m, sa, ai)
    @ccall libhpipm.blasfeo_print_to_string_tran_dvec(buf_out::Ptr{Ptr{Cchar}}, m::Cint, sa::Ptr{blasfeo_dvec}, ai::Cint)::Cvoid
end

const D_EL_SIZE = 8

const S_EL_SIZE = 4

const CACHE_LINE_SIZE = 64

const L1_CACHE_SIZE = 32 * 1024

const L2_CACHE_SIZE = 256 * 1024

const LLC_CACHE_SIZE = 6 * 1024 * 1024

const D_PS = 4

const D_PLD = 4

const D_M_KERNEL = 12

const D_N_KERNEL = 8

const D_KC = 256

const D_NC = 64

const D_MC = 1500

const S_PS = 8

const S_PLD = 4

const S_M_KERNEL = 24

const S_N_KERNEL = 8

const S_KC = 256

const S_NC = 144

const S_MC = 3000

const D_CACHE_LINE_EL = CACHE_LINE_SIZE ÷ D_EL_SIZE

const D_L1_CACHE_EL = L1_CACHE_SIZE ÷ D_EL_SIZE

const D_L2_CACHE_EL = L2_CACHE_SIZE ÷ D_EL_SIZE

const D_LLC_CACHE_EL = LLC_CACHE_SIZE ÷ D_EL_SIZE

const S_CACHE_LINE_EL = CACHE_LINE_SIZE ÷ S_EL_SIZE

const S_L1_CACHE_EL = L1_CACHE_SIZE ÷ S_EL_SIZE

const S_L2_CACHE_EL = L2_CACHE_SIZE ÷ S_EL_SIZE

const S_LLC_CACHE_EL = LLC_CACHE_SIZE ÷ S_EL_SIZE

const TARGET_NEED_FEATURE_AVX2 = 1

const TARGET_NEED_FEATURE_FMA = 1

const ON = 1

const OFF = 0

# exports
const PREFIXES = ["hpipm_", "blasfeo_", "d_ocp_", "d_dense_", "d_", "OCP_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
