macro with(d, x)
    esc(with_helper(d, x))
end

macro with(x)
    i = gensym()
    esc(Expr(:(->), i, with_helper(i, x)))
end

with_helper(d, x) = parse_function_call(x, replace_column, d)

replace_column(x, d) = Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x)
