macro where_vec(d, expr)
    res = with_helper(d, expr)
    esc(Expr(:call, :view, d, Expr(:call, :find, res)))
end

macro where_vec(x)
    i = gensym()
    :($i -> @where_vec($i, $x))
end

macro where(d, expr)
    res = map_helper(d, expr)
    esc(Expr(:call, :view, d, Expr(:call, :find, res)))
end

macro where(x)
    i = gensym()
    :($i -> @where($i, $x))
end
