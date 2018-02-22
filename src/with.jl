macro with(d, x)
    esc(with_helper(d, x))
end

macro with(x)
    i = gensym()
    esc(Expr(:(->), i, with_helper(i, x)))
end

with_helper(d, x) = replace_colname(d, x, replace_column)
