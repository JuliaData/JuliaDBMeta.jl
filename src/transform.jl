transform_col(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)

macro transform(d, expr)
    @capture expr x_ = y_
    res = replace_colname(d, y, replace_column)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end

macro transform_byrow(d, expr)
    @capture expr x_ = y_
    iter = gensym()
    function_call = replace_colname(d, y, replace_iterator, iter)
    res = quote
        [$function_call for $iter in 1:length($d)]
    end
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, x, res))
end
