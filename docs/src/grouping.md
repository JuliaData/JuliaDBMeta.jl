# Grouping

Three approaches are possible for grouping.

## Groupby

```@docs
@groupby
```

## Column-wise macros with grouping argument

All column-wise macros accept an optional grouping argument

```julia
iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"))
@where_vec iris :Species :SepalLength .> mean(:SepalLength)
```

Use `flatten=true` to flatten the result

```julia
@where_vec iris :Species flatten=true :SepalLength .> mean(:SepalLength)
```

## Pipeline with grouping argument

`@apply` also accepts an optional grouping argument:

```julia
@apply iris :Species flatten = true begin
   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}
   sort(_, :SepalWidth, rev = true)
   _[1:3]
end
```
