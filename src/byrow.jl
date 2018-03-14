"""
`@byrow!(d, x)`

Apply the expression `x` row by row in `d` (to modify `d` in place). Symbols refer to fields of the row.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest byrow
julia> using JuliaDB

julia> t = table(@NT(a = [1,2,3], b = ["x","y","z"]));

julia> @byrow! t :b = :b*string(:a)
Table with 3 rows, 2 columns:
a  b
───────
1  "x1"
2  "y2"
3  "z3"
```
"""
macro byrow!(d, x)
    esc(byrow_helper(d, x))
end

macro byrow!(x)
    i = gensym()
    esc(Expr(:(->), i, byrow_helper(i, x)))
end

function byrow_helper(d, x)
    iter = gensym()
    function_call = parse_function_call(d, x, replace_iterator, iter)
    quote
        for $iter in 1:length($d)
            $function_call
        end
        $d
    end
end

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x), iter)
replace_iterator(d, iter) = Expr(:ref, d, iter)
