# Pipeline macros

All macros have a currified version, so they can be easily concatenated using `|>`. For example:

```jldoctest pipe
julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);

julia> t |> @where(:x >= 2) |> @transform({:x+:y})
Table with 2 rows, 4 columns:
x  y  z    x + y
────────────────
2  5  0.2  7
2  7  0.4  9
```

To avoid the parenthesis and to use the `_` curryfication syntax, you can use the `@apply` macro instead:

```@docs
@apply
```

Use `@applychunked` to apply your pipeline independently on different processors:

```@docs
@applychunked
```
