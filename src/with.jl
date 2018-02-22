macro with(d, x)
    esc(with_helper(d, x))
end

macro with(x)
    i = gensym()
    :($i -> @with($i, $x))
end

with_helper(d, x) = replace_colname(d, x, replace_column)
