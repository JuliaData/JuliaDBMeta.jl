"""
`@with(d, x)`

Replace all symbols in expression `x` with the respective column in `d`. In this context,
`_` refers to the whole table `d`. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to column `c` where `c` is a variable that evaluates to a symbol.

## Examples

```jldoctest with
julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @with t mean(:a)
2.0

julia> @with t mean(:a)*length(_)
6.0

julia> @with t join(:b)
"xyz"

julia> @with t @show ^(:a) != :a
:a != getfield(JuliaDBMeta.columns(t), :a) = true
true
```
"""
macro with(d, x)
    esc(with_helper(d, x))
end

macro with(x)
    i = gensym()
    esc(Expr(:(->), i, with_helper(i, x)))
end

with_helper(d, x) = parse_function_call(d, helper_namedtuples_replacement(x), replace_column)

replace_column(d, x) = Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x)
replace_column(d) = d
