macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    :($i -> @map($i, $x))
end

function map_helper(d, x)
    iter = gensym()
    use_anonymous_function(d, x, replace_column, :map)
end
