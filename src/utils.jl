parse_function_call(args...) = parse_function_call!([], args...)

parse_function_call!(syms, d, x, func, args...) = x == :(_) ? d : x

isquotenode(x) = false
isquotenode(x::Expr) = x.head == :quote

function parse_function_call!(syms, d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2 && isquotenode(x.args[2])
        return Expr(x.head, parse_function_call!(syms, d, x.args[1], func, args...), x.args[2])
    end
    if x.head == :quote
        push!(syms, x)
        return func(d, x, args...)
    end
    return Expr(x.head, (parse_function_call!(syms, d, arg, func, args...) for arg in x.args)...)
end

function extract_anonymous_function(d, x, func)
    syms = Any[]
    iter = gensym()
    function_call = parse_function_call!(syms, iter, x, func)
    unique_syms = unique(syms)
    Expr(:(->), iter, function_call), Expr(:tuple, unique_syms...)
end
