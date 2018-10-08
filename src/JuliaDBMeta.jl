__precompile__()
module JuliaDBMeta

using IndexedTables, MacroTools, Reexport
import IterTools

import JuliaDB: Dataset, DDataset, fromchunks
import Dagger: delayedmap

@reexport using JuliaDB
export @with, @map, @byrow!, @filter
export @transform, @transform_vec, transformcol
export @where, @where_vec
export @groupby
export @apply, @applychunked
export @=>, @select

include("utils.jl")
include("byrow.jl")
include("with.jl")
include("map.jl")
include("filter.jl")
include("where.jl")
include("transform.jl")
include("groupby.jl")
include("apply.jl")
include("pair.jl")

end
