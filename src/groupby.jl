_groupby(f, d::AbstractDataset, args...) = IndexedTables.groupby(f, d, args..., flatten = true, usekey = true)
_groupby(f, d::AbstractDataset, syms::NTuple{N, Symbol}, args...) where {N} =
    IndexedTables.groupby(f, d, args..., flatten = true, usekey = true, select = syms)
_groupby(f, syms::NTuple{N, Symbol}, d::AbstractDataset, args...) where {N} =
    _groupby(f, d, syms, args...)
_groupby(f, args...) = d::AbstractDataset -> _groupby(f, d, args...)

function groupby_helper(args...)
    x = helper_namedtuples_replacement(last(args))
    anon_func, syms = extract_anonymous_function(x, replace_column, usekey = true)
    if !isempty(syms) && !(:(_) in syms)
        Expr(:call, :(JuliaDBMeta._groupby), anon_func, :(Tuple($syms)), args[1:end-1]...)
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
