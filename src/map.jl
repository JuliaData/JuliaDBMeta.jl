"""
`@map(d, x)`

Apply the expression `x` row by row in `d`: return the result as an array or as a table
(if the elements are `Tuples` or `NamedTuples`). Use `{}` syntax for automatically named `NamedTuples`.
Symbols refer to fields of the row.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.

## Examples

```jldoctest map
julia> using JuliaDB

julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @map t :b*string(:a)
3-element Array{String,1}:
 "x1"
 "y2"
 "z3"

julia> @map t {:a, copy = :a, :b}
Table with 3 rows, 3 columns:
a  copy  b
────────────
1  1     "x"
2  2     "y"
3  3     "z"
```
"""
macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    esc(Expr(:(->), i, map_helper(i, x)))
end

_table(c::Columns) = table(c, copy = false, presorted = true)
_table(c) = c

function map_helper(d, x)
    x = helper_namedtuples_replacement(x)
    anon_func, syms = extract_anonymous_function(x, replace_field)
    if !isempty(syms) && !(:(_) in syms)
        :(map($anon_func, (JuliaDBMeta._table)($d), select = Tuple($syms)))
    else
        :(map($anon_func, (JuliaDBMeta._table)($d)))
    end
end

replace_field(iter, x) =  Expr(:call, :getfield, iter, x)
replace_field(iter) = iter
