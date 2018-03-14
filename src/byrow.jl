"""
`@byrow!(d, x)`

Apply the expression `x` row by row in `d` (to modify `d` in place). Symbols refer to fields of the row.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest byrow
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
macro byrow!(args...)
    i = gensym()
    esc(byrow_helper(args...))
end

function byrow_helper(args...)
    d = gensym()
    iter = gensym()
    function_call = parse_function_call(d, args[end], replace_iterator, iter)
    expr = quote
        for $iter in 1:length($d)
            $function_call
        end
        $d
    end
    func = Expr(:(->), d, expr)
    Expr(:call, :(JuliaDBMeta._pipe_chunks), func, args[1:end-1]...)
end

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x), iter)
replace_iterator(d, iter) = Expr(:ref, d, iter)
