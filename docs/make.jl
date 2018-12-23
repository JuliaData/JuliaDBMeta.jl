using Documenter, JuliaDBMeta

makedocs(
    format = :html,
    sitename = "JuliaDBMeta",
    authors = "Pietro Vertechi",
    pages = [
        "Introduction" => "index.md",
        "Getting Started" => "getting_started.md",
        "Row-wise macros" => "row_macros.md",
        "Column-wise macros" => "column_macros.md",
        "Selection" => "selection.md",
        "Pipeline macros" => "pipeline_macros.md",
        "Grouping operations" => "grouping.md",
        "Out-of-core support" => "out_of_core.md",
        "Plotting" => "plotting.md",
        "Tutorial" => "tutorial.md",
    ]
)

deploydocs(
    repo = "github.com/piever/JuliaDBMeta.jl.git",
    target = "build",
)
