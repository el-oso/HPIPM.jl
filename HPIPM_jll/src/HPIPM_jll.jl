# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule HPIPM_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("HPIPM")
JLLWrappers.@generate_main_file("HPIPM", UUID("1df8421c-9e67-486d-aaf1-8762a7c80566"))
end  # module HPIPM_jll
