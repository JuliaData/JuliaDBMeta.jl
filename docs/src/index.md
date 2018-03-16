# Introduction

## Overview

JuliaDBMeta is a set of macros to simplify data manipulation with [JuliaDB](https://github.com/JuliaComputing/JuliaDB.jl), heavily inspired on [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl). It exploit the technical advantages of JuliaDB:

- Fully-type tables with type stable column extraction
- Fast row iteration
- Parallel data storage and parallel computations

Some ideas also come from [Query.jl](https://github.com/davidanthoff/Query.jl), in particular the curly bracket syntax is from there.

The macro packages [Lazy](https://github.com/MikeInnes/Lazy.jl) and [MacroTools](https://github.com/MikeInnes/MacroTools.jl) were also very useful in designing this package: the `@apply` macro is inspired by the concatenation macros in Lazy.

## Installation

To install, simply type the following command in the Julia REPL:

```julia
Pkg.add("JuliaDBMeta")
```
