"""
`@with(d, x)`

Replace all symbols in expression `x` with the respective column in `d`. In this context,
`_` refers to the whole table `d`. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to column `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

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

julia> c = :a
:a

julia> @with t cols(c)
3-element Array{Int64,1}:
 1
 2
 3
```

Note that you can use this syntax to modify columns in place as well:

```jldoctest with
julia> @with t :b .= :b .* string.(:a)
3-element Array{String,1}:
 "x1"
 "y2"
 "z3"

julia> t
Table with 3 rows, 2 columns:
a  b
───────
1  "x1"
2  "y2"
3  "z3"
```
"""
macro with(args...)
    esc(with_helper(args...))
end

function with_helper(args...)
    d = gensym()
    func, _ = extract_anonymous_function(last(args), replace_column)
    Expr(:call, :(JuliaDBMeta._pipe), func, replace_keywords(args[1:end-1])...)
end

replace_column(d, x) = Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x)
replace_column(d) = d
