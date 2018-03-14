transformcol(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)
function transformcol(t, col::NamedTuples.NamedTuple)
    for (key, val) in zip(keys(col), values(col))
        t = transformcol(t, key, val)
    end
    t
end
transformcol(t, col::Union{Columns, IndexedTables.AbstractIndexedTable}) = transformcol(t, columns(col))

transform_vec_helper(d, x) = Expr(:call, :(JuliaDBMeta.transformcol), d, with_helper(d, x))

"""
`@transform_vec(d, x)`

Replace all symbols in expression `x` with the respective column in `d`: the result has to be
 a `NamedTuple` of vectors or a table and is horizontally merged with `d`. In this context,
`_` refers to the whole table `d`. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `{}` syntax for automatically named `NamedTuples`.
Use `cols(c)` to refer to column `c` where `c` is a variable that evaluates to a symbol.

## Examples

```jldoctest transform_vec
julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @transform_vec t {:a .+ 1}
Table with 3 rows, 3 columns:
a  b    a .+ 1
──────────────
1  "x"  2
2  "y"  3
3  "z"  4
```
"""
macro transform_vec(d, x)
    esc(transform_vec_helper(d, x))
end

macro transform_vec(x)
    i = gensym()
    esc(Expr(:(->), i, transform_vec_helper(i, x)))
end

function transform_helper(args...)
    d = gensym() 
    func = Expr(:(->), d, Expr(:call, :(JuliaDBMeta.transformcol), d, map_helper(d, args[end])))
    Expr(:call, :(JuliaDBMeta._pipe_chunks), func, args[1:end-1]...)
end

"""
`@transform(d, x)`

Apply the expression `x` row by row in `d`: collect the result as a table
(elements returned by `x` must be `NamedTuples`) and merge it horizontally with `d`. In this context,
`_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.

Use `{}` syntax for automatically named `NamedTuples`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest transform
julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @transform t {:a + 1}
Table with 3 rows, 3 columns:
a  b    a + 1
──────────────
1  "x"  2
2  "y"  3
3  "z"  4
```
"""
macro transform(d, x)
    esc(transform_helper(d, x))
end

macro transform(x)
    i = gensym()
    esc(Expr(:(->), i, transform_helper(i, x)))
end
