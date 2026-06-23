using Test
using LinearAlgebra

@testset "HPIPM.jl" begin
    include("test_dense_qp.jl")
    include("test_ocp_qp.jl")
    include("test_moi.jl")
end
