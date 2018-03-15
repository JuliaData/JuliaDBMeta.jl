# JuliaDBMeta.jl

## Overview

A set of macros to simplify data manipulation with [JuliaDB](https://github.com/JuliaComputing/JuliaDB.jl), heavily inspired on [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl). It basically is a port of that package from DataFrames to IndexedTables, exploiting some of the advantages of JuliaDB:

- Table have full type information, so extracting a column is type stable
- Iterating rows is fast
- Parallel data storage and parallel computations.

Some ideas also come from [Query.jl](https://github.com/davidanthoff/Query.jl), in particular the curly bracket syntax is from there.

The macro packages [Lazy](https://github.com/MikeInnes/Lazy.jl) and [MacroTools](https://github.com/MikeInnes/MacroTools.jl) were also very useful in designing this package: the `@apply` macro is inspired by the concatenation macros in Lazy.

## Installation

To install, simply type the following command in the Julia REPL:

```julia
Pkg.add("JuliaDBMeta")
```
