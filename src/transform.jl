transformcol(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)
function transformcol(t, col::NamedTuples.NamedTuple)
    for (key, val) in zip(keys(col), values(col))
        t = transformcol(t, key, val)
    end
    t
end
transformcol(t, col::Union{Columns, IndexedTables.AbstractIndexedTable}) = transformcol(t, columns(col))

transform_vec_helper(d, x) = Expr(:call, :(JuliaDBMeta.transformcol), d, with_helper(d, x))

macro transform_vec(d, x)
    esc(transform_vec_helper(d, x))
end

macro transform_vec(x)
    i = gensym()
    esc(Expr(:(->), i, transform_vec_helper(i, x)))
end

transform_helper(d, x) = Expr(:call, :(JuliaDBMeta.transformcol), d, map_helper(d, x))

macro transform(d, x)
    esc(transform_helper(d, x))
end

macro transform(x)
    i = gensym()
    esc(Expr(:(->), i, transform_helper(i, x)))
end
