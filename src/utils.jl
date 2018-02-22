replace_colname(d, x, func, args...) = x

function replace_colname(d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        return func(d, x, args...)
    end
    return Expr(x.head, (replace_colname(d, arg, func, args...) for arg in x.args)...)
end

parse_function_call!(x, syms, vars) = x

# IMP to do: avoid repeating symbols!
function parse_function_call!(x::Expr, syms, vars)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        new_var = gensym(x.args[1])
        push!(syms, x)
        push!(vars, new_var)
        return new_var
    end
    return Expr(x.head, (parse_function_call!(arg, syms, vars) for arg in x.args)...)
end

function use_anonymous_function(d, x, func, args...)
    syms = Any[]
    vars = Symbol[]
    function_call = parse_function_call!(x, syms, vars)
    res = Expr(:(->), Expr(:tuple, vars...), function_call)
    Expr(:call, args..., res, (func(d, sym) for sym in syms)...)
end
