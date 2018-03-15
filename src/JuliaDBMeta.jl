__precompile__()
module JuliaDBMeta

using IndexedTables, MacroTools, NamedTuples, Reexport
import IterTools

import JuliaDB: Dataset, DDataset, fromchunks
import Dagger: delayedmap

@reexport using JuliaDB
export @with, @map, @byrow!
export @transform, @transform_vec, transformcol
export @where, @where_vec
export @groupby
export @apply, @applycombine, @applychunked

include("utils.jl")
include("byrow.jl")
include("with.jl")
include("map.jl")
include("where.jl")
include("transform.jl")
include("groupby.jl")
include("apply.jl")

end
