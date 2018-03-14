# JuliaDBMeta

[![Build Status](https://travis-ci.org/piever/JuliaDBMeta.jl.svg?branch=master)](https://travis-ci.org/piever/JuliaDBMeta.jl)

[![codecov.io](http://codecov.io/github/piever/JuliaDBMeta.jl/coverage.svg?branch=master)](http://codecov.io/github/piever/JuliaDBMeta.jl?branch=master)

A set of macros to simplify data manipulation with [IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl), heavily inspired on [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl). It basically is a port of that package from DataFrames to IndexedTables, exploiting some of the advantages of IndexedTables:

- Table have full type information, so extracting a column is type stable
- Iterating rows is fast

Some ideas also come from [Query.jl](https://github.com/davidanthoff/Query.jl), in particular the curly bracket syntax is from there.

The macro packages [Lazy](https://github.com/MikeInnes/Lazy.jl) and [MacroTools](https://github.com/MikeInnes/MacroTools.jl) were also very useful in designing this package: the `@apply` macro is a slight modification of the concatenation macros in Lazy.

## Replacing symbols with columns

The first important macro is `@with`, to replace symbols with columns:

```julia
julia> using JuliaDBMeta

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
julia> @with t :x .= :x .+ :y .+ 1
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

The `{}` syntax simplifies the creation of NamedTuples:

```julia
julia> @with t {:x, sum = :x+:y, :x-:y}
(x = [1, 2, 3], sum = [0, 2, 4], x - y = [2, 2, 2])
```

To escape symbols that do no refer to columns, use `^`:

```julia
julia> @with(t, ^(:a))
:a
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

The `{}` syntax is also available:

 ```julia
 julia> @map t {:x+:y, :x-:y}
Table with 3 rows, 2 columns:
x + y  x - y
────────────
5      -3
7      -3
9      -3
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

julia> @transform_vec t  {:y .* :z}
Table with 3 rows, 4 columns:
x  y  z    y .* z
─────────────────
1  4  0.1  0.4
2  5  0.2  1.0
3  6  0.3  1.8
```

with its row-wise variant `@transform`:

```julia
julia> @transform t  {:y*exp(:z)}
Table with 3 rows, 4 columns:
x  y  z    y * exp(z)
─────────────────────
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

## Grouping

To group data and apply some summary function to it, use the `@groupby` macro. It's just like `@with` but before extracting the data, it groups it. The second argument is optional (defaults to `Keys()`) and specifies on which column(s) to group.

```julia
julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);

julia> @groupby t :x {maximum(:y - :z)}
Table with 2 rows, 2 columns:
x  maximum(y - z)
─────────────────
1  5.7
2  6.6
```

The `key` column(s) can be accessed with `_.key`:

```julia
julia> @groupby t :x {m = maximum(:y - :z)/_.key.x}
Table with 2 rows, 2 columns:
x  m
──────
1  5.7
2  3.3
```

## Pipeline

All these macros have a currified version, so they can be easily concatenated using `|>`. For example:

```julia
julia> t |> @where(:x >= 2) |> @transform({:x+:y})
Table with 2 rows, 4 columns:
x  y  z    x + y
────────────────
2  5  0.2  7
3  6  0.3  9
```

To avoid the parenthesis and to use the `_` curryfication syntax, you can use the `@apply` macro instead:

```julia
julia> @apply t begin
       @where :x >= 2
       @transform {:x+:y}
       sort(_, :z)
       end
Table with 2 rows, 4 columns:
x  y  z    x + y
────────────────
2  5  0.2  7
3  6  0.3  9
```

`@apply` can also take an optional second argument, in which case the data is grouped according to that argument before applying the various transformations. Here for example we split by `:Species`, select the rows with the 3 larges `SepalWidth`, select the fields `:SepalWidth` and `Ratio = :SepalLength / :SepalWidth`, sort by `:SepalWidth`. To have the result as one long table (instead of a table of tables) use `@applycombine`

```julia
julia> iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"));

julia> @applycombine iris :Species begin
           select(_, 1:3, by = i -> i.SepalWidth, rev = true)
           @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}
           sort(_, by = i -> i.SepalWidth, rev = true)
       end
Table with 9 rows, 3 columns:
Species       SepalWidth  Ratio
─────────────────────────────────
"setosa"      4.4         1.29545
"setosa"      4.2         1.30952
"setosa"      4.1         1.26829
"versicolor"  3.4         1.76471
"versicolor"  3.3         1.90909
"versicolor"  3.2         1.84375
"virginica"   3.8         2.07895
"virginica"   3.8         2.02632
"virginica"   3.6         2.0
```

## Plotting

Plotting is also available via [StatPlots](https://github.com/JuliaPlots/StatPlots.jl) using the macro `@df` and can be easily integrated in our `@apply`. For example:

```julia
julia> using StatPlots

julia> iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"));

julia> @apply iris begin
       @where :SepalLength > 4
       @transform {ratio = :PetalLength / :PetalWidth}
       @df scatter(:PetalLength, :ratio, group = :Species)
       end
```
![iris](https://user-images.githubusercontent.com/6333339/37232191-d95e8e00-23e5-11e8-9694-d8e669a5b765.png)

Plotting grouped data can also be achieved by:

```julia
julia> plt = plot()

julia> @apply iris :Species begin
       @where :SepalLength > 4
       @transform {ratio = :PetalLength / :PetalWidth}
       @df scatter!(:PetalLength, :ratio)
       end;

julia> plt
```

though at the moment that requires StatPlots master, due to a recently fixed hygiene bug.
