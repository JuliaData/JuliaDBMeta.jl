where_vec_helper(d, expr) = Expr(:call, :view, d, Expr(:call, :find, with_helper(d, expr)))

macro where_vec(d, expr)
    esc(where_vec_helper(d, expr))
end

macro where_vec(x)
    i = gensym()
    esc(Expr(:(->), i, where_vec_helper(i, x)))
end

where_helper(d, expr) = Expr(:call, :view, d, Expr(:call, :find, map_helper(d, expr)))

macro where(d, expr)
    esc(where_helper(d, expr))
end

macro where(x)
    i = gensym()
    esc(Expr(:(->), i, where_helper(i, x)))
end
