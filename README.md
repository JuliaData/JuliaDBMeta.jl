# JuliaDBMeta

[![Build Status](https://travis-ci.org/piever/JuliaDBMeta.jl.svg?branch=master)](https://travis-ci.org/piever/JuliaDBMeta.jl)

[![codecov.io](http://codecov.io/github/piever/JuliaDBMeta.jl/coverage.svg?branch=master)](http://codecov.io/github/piever/JuliaDBMeta.jl?branch=master)

A set of macros to simplify data manipulation with [IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl), heavily inspired on [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl). It basically is a port of that package from DataFrames to IndexedTables, exploiting some of the advantages of IndexedTables:

- Table have full type information, so extracting a column is type stable
- Iterating rows is fast

## Replacing symbols with columns

The first important macro is `@with`, to replace symbols with columns:

```julia
julia> using JuliaDBMeta, IndexedTables

julia> t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
Table with 3 rows, 3 columns:
x  y  z
─────────
1  4  0.1
2  5  0.2
3  6  0.3

julia> @with t :x .+ :y
3-element Array{Int64,1}:
 5
 7
 9
```

Note that you can use this syntax to modify columns in place as well:

```julia
julia> @with t :x .= :x + :y .+ 1
3-element Array{Int64,1}:
  6
  8
 10

julia> t
Table with 3 rows, 3 columns:
x   y  z
──────────
6   4  0.1
8   5  0.2
10  6  0.3
```

In a `@with` contex, `_` represents the original data. For example:

```julia
julia> t = table(1:3, -1:1, names = [:x, :y]);

julia> @with t length(_)
3
```

## Row by row operations

`byrow!` applies an operation to every row, to modify the column in place:

```julia
julia> @byrow! t :z = :y / :x

julia> t
Table with 3 rows, 3 columns:
x   y  z
───────────────
6   4  0.666667
8   5  0.625
10  6  0.6
```

Note that you can pass a `begin ... end` block for more complex manipulations:

```julia
julia> t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z]);

julia> @byrow! t begin
       :z *= :y
       a = :x + :y
       :x = a - 33
       end
Table with 3 rows, 3 columns:
x    y  z
───────────
-28  4  0.4
-26  5  1.0
-24  6  1.8
```

## Map

JuliaDBMeta also provides simplified notation for `map`:

```julia
julia> @map t :x + :y
3-element Array{Int64,1}:
 5
 7
 9
```

Or, with NamedTuples to select multiple columns:

```julia
julia> @map t @NT(sum = :x+:y, diff = :x-:y)
Table with 3 rows, 2 columns:
sum  diff
─────────
5    -3
7    -3
9    -3
```

## Transforming columns (or adding new ones)

Use `@transform_vec` for vectorized operations

```julia
julia> t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
Table with 3 rows, 3 columns:
x  y  z
─────────
1  4  0.1
2  5  0.2
3  6  0.3

julia> @transform_vec t @NT(a = :y .* :z)
Table with 3 rows, 4 columns:
x  y  z    a
──────────────
1  4  0.1  0.4
2  5  0.2  1.0
3  6  0.3  1.8
```

with its row-wise variant `@transform`:

```julia
julia> @transform t @NT(a = :y * exp(:z))
Table with 3 rows, 4 columns:
x  y  z    a
──────────────────
1  4  0.1  4.42068
2  5  0.2  6.10701
3  6  0.3  8.09915
```

## Taking a view

You can take a view (like filtering, but without copying) with `@where` (on scalars) and `@where_vec` (on vectors):

```julia
julia> @where t :x > 1 && :y < 6
Table with 1 rows, 3 columns:
x  y  z
─────────
2  5  0.2

julia> @where_vec t :x .> mean(:y) .- 3
Table with 1 rows, 3 columns:
x  y  z
─────────
3  6  0.3
```

## Pipeline

All these macros have a currified version, so they can be easily concatenated using `|>`. For example:

```julia
julia> t |> @where(:x >= 2) |> @transform(@NT(s = :x + :y))
Table with 2 rows, 4 columns:
x  y  z    s
────────────
2  5  0.2  7
3  6  0.3  9
```
