where_vec_helper(d, expr) = Expr(:call, :view, d, Expr(:call, :find, with_helper(d, expr)))

"""
`@where_vec(d, x)`

Replace all symbols in expression `x` with the respective column in `d`: the result has to be
 an `Array` of booleans which is used to get a view of `d`.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
The result has to be a `NamedTuple` of vectors or a table and is horizontally merged with `d`.
Use `{}` syntax for automatically named `NamedTuples`.

## Examples

```jldoctest where_vec
julia> using JuliaDB

julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @where_vec t (:a .>= mean(:a)) .& (:b .!= "y")
Table with 1 rows, 2 columns:
a  b
──────
3  "z"
"""
macro where_vec(d, expr)
    esc(where_vec_helper(d, expr))
end

macro where_vec(x)
    i = gensym()
    esc(Expr(:(->), i, where_vec_helper(i, x)))
end

where_helper(d, expr) = Expr(:call, :view, d, Expr(:call, :find, map_helper(d, expr)))

"""
`@where(d, x)`

Apply the expression `x` row by row in `d`: collect the result as an `Array`
(elements returned by `x` must be booleans) and use it to get a view of `d`. In this context,
`_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.

Use `{}` syntax for automatically named `NamedTuples`.

## Examples

```jldoctest where
julia> using JuliaDB

julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @where t :a <= 2
Table with 2 rows, 2 columns:
a  b
──────
1  "x"
2  "y"
"""
macro where(d, expr)
    esc(where_helper(d, expr))
end

macro where(x)
    i = gensym()
    esc(Expr(:(->), i, where_helper(i, x)))
end
