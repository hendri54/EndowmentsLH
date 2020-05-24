using Documenter, EndowmentsLH

makedocs(
    modules = [EndowmentsLH],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "EndowmentsLH.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/hendri54/EndowmentsLH.jl.git",
    push_preview = true
)
