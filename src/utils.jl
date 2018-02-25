replace_colname(d, x, func, args...) = x

function replace_colname(d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        return func(d, x, args...)
    end
    return Expr(x.head, (replace_colname(d, arg, func, args...) for arg in x.args)...)
end

parse_function_call!(x, syms, iter) = x

function parse_function_call!(x::Expr, syms, iter)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        push!(syms, x)
        return Expr(:call, :getfield, iter, x)
    end
    return Expr(x.head, (parse_function_call!(arg, syms, iter) for arg in x.args)...)
end

function extract_anonymous_function(d, x)
    syms = Any[]
    iter = gensym()
    function_call = parse_function_call!(x, syms, iter)
    res = Expr(:(->), iter, function_call)
    res, Expr(:tuple, syms...)
end
