using Documenter, JuliaDBMeta

makedocs(
    format = :html,
    sitename = "PlugAndPlot",
    authors = "Pietro Vertechi",
    pages = [
        "Introduction" => "index.md",
        "Getting Started" => "getting_started.md",
        "Column-wise macros" => "column_macros.md",
        "Row-wise macros" => "row_macros.md",
    ]
)

deploydocs(
    repo = "github.com/piever/JuliaDBMeta.jl.git",
    target = "build",
    julia  = "0.6",
    osname = "linux",
    deps   = nothing,
    make   = nothing
)
