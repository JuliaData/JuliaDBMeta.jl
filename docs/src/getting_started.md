# Getting started

## Installation

To install the package simply type:

```julia
Pkg.add("JuliaDBMeta")
```

in a Julia REPL.

To have the latest feature, you can checkout the unreleased version with:

```julia
Pkg.checkout("JuliaDBMeta")
```

## Example use

As a simple example, let's select rows according to some conditions. This is done using the macro [`@where`](@ref). As with all macros, the first argument is the data table (if omitted, the macro is automatically curried) and the last argument is an expression whose symbols will correspond to the various fields of the data.

```julia
iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"))
@where iris :Species == "versicolor" && :SepalLength > 6
```

To combine many operations use `@apply`:

```julia
@apply iris begin
    @where :Species == "versicolor" && :SepalLength > 6
    # add new column Ratio = SepalLength / SepalWidth
    @transform {Ratio = :SepalLength/:SepalWidth}
    @where :Ratio > 2
end
```

Pass an optional grouping argument to `@apply` to also group your data before running the pipeline:

```julia
@apply iris :Species flatten = true begin
    # select existing column SepalWidth and new column Ratio = SepalLength / SepalWidth
   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}
   # sort by SepalWidth
   sort(_, :SepalWidth, rev = true)
   # select first three rows of each group
   _[1:3]
end
```
