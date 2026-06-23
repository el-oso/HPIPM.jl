using HPIPM
using Documenter
using DocumenterVitepress

makedocs(;
    modules = [HPIPM],
    authors = "ursus.est@pm.me",
    sitename = "HPIPM.jl",
    format = DocumenterVitepress.MarkdownVitepress(;
        repo = "github.com/el-oso/HPIPM.jl",
        devbranch = "main",
        devurl = "dev",
        inventory_version = "0.1.0",   # avoid git-tag version lookup (non-git tree)
    ),
    remotes = nothing,   # repo may not be git-initialised yet; disables src links
    pages = [
        "Home" => "index.md",
        "Installation & transport" => "installation.md",
        "Dense QP" => "dense_qp.md",
        "OCP QP" => "ocp_qp.md",
        "JuMP / MathOptInterface" => "moi.md",
        "Benchmarking another solver" => "benchmarking.md",
        "API reference" => "api.md",
    ],
    warnonly = true,   # don't fail the build on missing-docstring cross-refs
)

# IMPORTANT: deploy with DocumenterVitepress.deploydocs, NOT Documenter.deploydocs,
# or the published site 404s.
DocumenterVitepress.deploydocs(;
    repo = "github.com/el-oso/HPIPM.jl",
    target = joinpath(@__DIR__, "build"),
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)
