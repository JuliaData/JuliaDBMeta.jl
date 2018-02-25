macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    esc(Expr(:(->), i, map_helper(i, x)))
end

_table(c::Columns) = table(c, copy = false, presorted = true)
_table(c) = c

function map_helper(d, x)
    anon_func, syms = extract_anonymous_function(d, x, (x, iter) -> Expr(:call, :getfield, iter, x))
    :(map($anon_func, (JuliaDBMeta._table)($d), select = $syms))
end
