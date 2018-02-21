# JuliaDBMeta

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

The variant `byrow` returns the output as a `Vector`:

```julia
julia> @byrow t :y / :x
3-element Array{Float64,1}:
 0.666667
 0.625   
 0.6   
```

## Transforming columns (or adding new ones)

```julia
julia> t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
Table with 3 rows, 3 columns:
x  y  z
─────────
1  4  0.1
2  5  0.2
3  6  0.3

julia> @transform t :a = :y .* :z
Table with 3 rows, 4 columns:
x  y  z    a
──────────────
1  4  0.1  0.4
2  5  0.2  1.0
3  6  0.3  1.8
```

with its row-wise variant `@transform_byrow` which takes an operation on scalars on the Right Hand Side.
