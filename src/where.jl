function where_vec_helper(args...)
    d = gensym()
    func = Expr(:(->), d,  Expr(:call, :(JuliaDBMeta._view), d, with_helper(d, args[end])))
    Expr(:call, :(JuliaDBMeta._pipe), func, replace_keywords(args[1:end-1])...)
end

"""
`@where_vec(d, x)`

Replace all symbols in expression `x` with the respective column in `d`: the result has to be
 an `Array` of booleans which is used to get a view of `d`.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
The result has to be a `NamedTuple` of vectors or a table and is horizontally merged with `d`.
Use `{}` syntax for automatically named `NamedTuples`.
Use `cols(c)` to refer to column `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest where_vec
julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @where_vec t (:a .>= 2) .& (:b .!= "y")
Table with 1 rows, 2 columns:
a  b
──────
3  "z"
```
"""
macro where_vec(args...)
    esc(where_vec_helper(args...))
end

function where_helper(args...)
    d = gensym()
    func = Expr(:(->), d,  Expr(:call, :(JuliaDBMeta._view), d, map_helper(d, args[end])))
    Expr(:call, :(JuliaDBMeta._pipe_chunks), func, args[1:end-1]...)
end

"""
`@where(d, x)`

Apply the expression `x` row by row in `d`: collect the result as an `Array`
(elements returned by `x` must be booleans) and use it to get a view of `d`. In this context,
`_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.

Use `{}` syntax for automatically named `NamedTuples`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest where
julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @where t :a <= 2
Table with 2 rows, 2 columns:
a  b
──────
1  "x"
2  "y"
```
"""
macro where(args...)
    esc(where_helper(args...))
end
