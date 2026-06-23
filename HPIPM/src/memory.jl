# Low-level memory management for HPIPM / BLASFEO.
#
# HPIPM objects follow a manual two-call protocol:
#
#     sz  = d_*_memsize(args...)          # bytes for the object's *data*
#     mem = <64-byte aligned buffer>      # caller-owned data scratch
#     d_*_create(args..., obj, mem)       # placement-construct `obj` into `mem`
#
# `obj` is a pointer to the *struct header* itself. Its size is given by
# `d_*_strsize()`. IMPORTANT: we deliberately do NOT size the header from the
# Clang-generated Julia struct (`sizeof(d_dense_qp_ipm_ws)` etc.) — the generator
# drops some fields, so those sizes are too small and `create` would overflow the
# box and corrupt the Julia heap. Sizing from HPIPM's own `strsize()` is exact.
# We read every result through getter functions, so the struct layout is never
# needed on the Julia side.
#
# BLASFEO wants 64-byte aligned memory. Each buffer is backed by a Julia
# `Vector{UInt8}` (the GC root) with a manually aligned pointer.

const BLASFEO_ALIGN = 64

"""
    AlignedBuffer(nbytes)

A `nbytes`-byte scratch region whose `ptr` is aligned to `BLASFEO_ALIGN` (64).
Keep the struct alive while any HPIPM object placed in it is in use.
"""
mutable struct AlignedBuffer
    raw::Vector{UInt8}      # GC root; do not let it be collected
    ptr::Ptr{Cvoid}         # 64-byte aligned address inside `raw`
end

function AlignedBuffer(nbytes::Integer)
    n = max(Int(nbytes), 0)
    raw = Vector{UInt8}(undef, n + BLASFEO_ALIGN)
    base = UInt(pointer(raw))
    aligned = (base + BLASFEO_ALIGN - 1) & ~(UInt(BLASFEO_ALIGN) - 1)
    return AlignedBuffer(raw, Ptr{Cvoid}(aligned))
end

Base.pointer(b::AlignedBuffer) = b.ptr

"""
    HObj{T}(strsize, memsize)

A managed HPIPM object: a `strsize`-byte header buffer plus a `memsize`-byte data
buffer, both 64-byte aligned. `ptr` is the typed header pointer passed to the C
API; `mem.ptr` is the data pointer passed to the matching `create` call. Both
buffers are GC roots held by this struct.
"""
mutable struct HObj{T}
    hdr::AlignedBuffer
    mem::AlignedBuffer
    ptr::Ptr{T}
end

function HObj{T}(strsize::Integer, memsize::Integer) where {T}
    hdr = AlignedBuffer(strsize)
    mem = AlignedBuffer(memsize)
    return HObj{T}(hdr, mem, Ptr{T}(hdr.ptr))
end

Base.pointer(o::HObj) = o.ptr
