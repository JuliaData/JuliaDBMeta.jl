transform_col(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)

macro transform(d, expr)
    @capture expr x_ = y_
    res = with_helper(d, y)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end

macro transform_byrow(d, expr)
    @capture expr x_ = y_
    res = byrow_helper(d, y)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end
