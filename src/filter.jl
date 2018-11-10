"""
`@filter(d, x)`

Filter rows according to the expression `x` row by row in `d`.
Symbols refer to fields of the row.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest filter
julia> t = table((a = [1,2,3], b=[2,3,4]));

julia> @filter t :a < 3
Table with 2 rows, 2 columns:
a  b
────
1  2
2  3

julia> @filter t 2*:a > :b
Table with 2 rows, 2 columns:
a  b
────
2  3
3  4
```
"""
macro filter(args...)
    esc(filter_helper(args...))
end

function filter_helper(d, x)
    anon_func, syms = extract_anonymous_function(x, replace_field)
    if !isempty(syms) && !(:(_) in syms)
        fields = Expr(:call, :(JuliaDBMeta.All), syms...)
        :(filter($anon_func, (JuliaDBMeta._table)($d), select = $fields))
    else
        :(filter($anon_func, (JuliaDBMeta._table)($d)))
    end
end

function filter_helper(x)
    i = gensym()
    Expr(:(->), i, filter_helper(i, x))
end
