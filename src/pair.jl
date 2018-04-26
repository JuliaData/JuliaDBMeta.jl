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
