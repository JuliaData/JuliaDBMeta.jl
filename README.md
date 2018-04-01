# JuliaDBMeta

[![Build Status](https://travis-ci.org/piever/JuliaDBMeta.jl.svg?branch=master)](https://travis-ci.org/piever/JuliaDBMeta.jl)
[![codecov.io](http://codecov.io/github/piever/JuliaDBMeta.jl/coverage.svg?branch=master)](http://codecov.io/github/piever/JuliaDBMeta.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://piever.github.io/JuliaDBMeta.jl/latest/)
[![JuliaDBMeta](http://pkg.julialang.org/badges/JuliaDBMeta_0.6.svg)](http://pkg.julialang.org/?pkg=JuliaDBMeta)
[![JuliaDBMeta](http://pkg.julialang.org/badges/JuliaDBMeta_0.7.svg)](http://pkg.julialang.org/?pkg=JuliaDBMeta)

JuliaDBMeta is a set of macros to simplify data manipulation with [JuliaDB](https://github.com/JuliaComputing/JuliaDB.jl), heavily inspired on [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl). It exploits the technical advantages of JuliaDB:

- Fully typed tables with type stable column extraction
- Fast row iteration
- Parallel data storage and parallel computations

Some ideas also come from [Query.jl](https://github.com/davidanthoff/Query.jl), in particular the curly bracket syntax is from there.

The macro packages [Lazy](https://github.com/MikeInnes/Lazy.jl) and [MacroTools](https://github.com/MikeInnes/MacroTools.jl) were also very useful in designing this package: the `@apply` macro is inspired by the concatenation macros in Lazy.

## Getting started

To get started, check out the [documentation](https://piever.github.io/JuliaDBMeta.jl/latest/).
