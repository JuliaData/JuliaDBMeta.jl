"""
`@=>(expr...)`

Create a selector based on expressions `expr`. Symbols are used to select columns and infer an appropriate anonymous function.
In this context, `_` refers to the whole row. To use actual symbols, escape them with `^`, as in `^(:a)`.
Use `cols(c)` to refer to field `c` where `c` is a variable that evaluates to a symbol. `c` must be available in
the scope where the macro is called.

## Examples

```jldoctest pair
julia> t = table((a = [1,2,3], b = [4,5,6]));

julia> select(t, @=>(:a, :a + :b))
Table with 3 rows, 2 columns:
a  a + b
────────
1  5
2  7
3  9
```
"""
macro =>(args...)
    esc(pair_helper(args...))
end

function pair_helper(expr; name = nothing)
    isquotenode(expr) && (name == nothing) && return expr
    ispair(expr) && (name == nothing) && return pair_helper(expr.args[3]; name = expr.args[2]) #Expr(:call, :(=>), expr.args[2], pair_helper(expr.args[3]))
    istuple(expr)  && return Expr(:tuple, map(pair_helper, expr.args)...)
    anon_func, syms = extract_anonymous_function(expr, replace_field)
    fields = (:(_) in syms || isempty(syms)) ? Expr(:call, :(JuliaDBMeta.All)) : Expr(:call, :(JuliaDBMeta.distinct_tuple), syms...)
    name == nothing && (name = Expr(:quote, Symbol(filter(t -> t != ':', string(expr)))))
    :($name => $fields => $anon_func)
end

pair_helper(expr...) = pair_helper(Expr(:tuple, expr...))

"""
`@select(d, x)`

Short-hand for `select(d, @=>(x))`

## Examples

```jldoctest select
julia> t = table((a = [1,2,3], b = [4,5,6]));

julia> @select(t, (:a, :a + :b))
Table with 3 rows, 2 columns:
a  a + b
────────
1  5
2  7
3  9
```
"""
macro select(args...)
    esc(select_helper(args...))
end

function select_helper(x)
    i = gensym()
    Expr(:(->), i, select_helper(i, x))
end

function select_helper(d, x)
    :(JuliaDBMeta.select($d, $(pair_helper(x))))
end
