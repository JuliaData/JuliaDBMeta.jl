replace_colname(d, x, func, args...) = x

function replace_colname(d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2
        isa(x.args[2], Expr) && (x.args[2].head == :quote) && return x
    elseif x.head == :quote
        return func(d, x, args...)
    end
    return Expr(x.head, (replace_colname(d, arg, func, args...) for arg in x.args)...)
end
