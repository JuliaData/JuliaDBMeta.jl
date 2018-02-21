macro with(d, x)
    syms = Any[]
    vars = Symbol[]
    function_call = parse_function_call!(d, x, syms, vars)
    compute_vars = Expr(:(=), Expr(:tuple, vars...),
        Expr(:tuple, [Expr(:call, :getfield, :(IndexedTables.columns($d)), sym) for sym in syms]...))
    esc(Expr(:block, compute_vars, function_call))
end

"""
    `@with x`
Curried version of `@with d x`. Outputs an anonymous function `d -> @with d x`.
"""
macro with(x)
    i = gensym()
    :($i -> @with($i, $x))
end

parse_function_call!(d, x, syms, vars) = x

function parse_function_call!(d, x::Expr, syms, vars)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        new_var = gensym(x.args[1])
        push!(syms, x)
        push!(vars, new_var)
        return new_var
    end
    return Expr(x.head, (parse_function_call!(d, arg, syms, vars) for arg in x.args)...)
end
