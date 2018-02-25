macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    esc(Expr(:(->), i, map_helper(i, x)))
end

function map_helper(d, x)
    res, syms = extract_anonymous_function(d, x, (x, iter) -> Expr(:call, :getfield, iter, x))
    :(map($res, $d, select = $syms))
end
