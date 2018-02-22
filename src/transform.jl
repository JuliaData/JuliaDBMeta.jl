transform_col(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)

macro transform_vec(d, expr)
    @capture expr x_ = y_
    res = with_helper(d, y)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end

macro transform_vec(x)
    i = gensym()
    :($i -> @transform_vec($i, $x))
end

macro transform(d, expr)
    @capture expr x_ = y_
    res = map_helper(d, y)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end

macro transform(x)
    i = gensym()
    :($i -> @transform($i, $x))
end
