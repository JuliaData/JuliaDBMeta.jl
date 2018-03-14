_groupby(f, d::AbstractDataset, args...; kwargs...) = 
    IndexedTables.groupby(f, d, args...; flatten = true, usekey = true, kwargs...)

_groupby(f, args...; kwargs...) = d::AbstractDataset -> _groupby(f, d, args...; kwargs...)

function groupby_helper(args...)
    anon_func, syms = extract_anonymous_function(last(args), replace_column, usekey = true)
    if !isempty(syms) && !(:(_) in syms)
        fields = Expr(:call, :(JuliaDBMeta.All), syms...)
        Expr(:call, :(JuliaDBMeta._groupby), anon_func, args[1:end-1]..., Expr(:kw, :select, fields))
    else
        Expr(:call, :(JuliaDBMeta._groupby), anon_func, args[1:end-1]...)
    end
end

"""
`@groupby(d, by, x)`

Group data and apply some summary function to it.
Symbols in expression `x` are replaced by the respective column in `d`. In this context,
`_` refers to the whole table `d`. To use actual symbols, escape them with `^`, as in `^(:a)`.

The second argument is optional (defaults to `Keys()`) and specifies on which column(s) to group.
The `key` column(s) can be accessed with `_.key`.
Use `{}` syntax for automatically named `NamedTuples`.
Use `cols(c)` to refer to column `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest groupby
julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);

julia> @groupby t :x {maximum(:y - :z)}
Table with 2 rows, 2 columns:
x  maximum(y - z)
─────────────────
1  5.7
2  6.6

julia> @groupby t :x {m = maximum(:y - :z)/_.key.x}
Table with 2 rows, 2 columns:
x  m
──────
1  5.7
2  3.3
```
"""
macro groupby(args...)
    esc(groupby_helper(args...))
end
