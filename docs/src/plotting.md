# Plotting

Plotting is supported via the `@df` macro from [StatPlots](https://github.com/JuliaPlots/StatPlots.jl) and can be easily integrated in an [`@apply`](@ref) call.

```julia
using StatPlots
iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"));
@apply iris begin
    @where :SepalLength > 4
    @transform {ratio = :PetalLength / :PetalWidth}
    @df scatter(:PetalLength, :ratio, group = :Species)
end
```

![iris](https://user-images.githubusercontent.com/6333339/37232191-d95e8e00-23e5-11e8-9694-d8e669a5b765.png)

Plotting grouped data can also be achieved by:

```julia
plt = plot()

@apply iris :Species begin
    @where :SepalLength > 4
    @transform {ratio = :PetalLength / :PetalWidth}
    @df scatter!(:PetalLength, :ratio)
end

display(plt)
```
