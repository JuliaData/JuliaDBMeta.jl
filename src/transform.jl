transform_col(t, s, col) = s in colnames(t) ? setcol(t, s, col) : pushcol(t, s, col)
function transform_col(t, col::NamedTuples.NamedTuple)
    for (key, val) in zip(keys(col), values(col))
        t = transform_col(t, key, val)
    end
    t
end
transform_col(t, col::Union{Columns, IndexedTables.AbstractIndexedTable}) = transform_col(t, columns(col))

macro transform_vec(d, x)
    res = with_helper(d, x)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, res))
end

macro transform_vec(x)
    i = gensym()
    :($i -> @transform_vec($i, $x))
end

macro transform(d, x)
    res = map_helper(d, x)
    esc(Expr(:call, :(JuliaDBMeta.transform_col), d, res))
end

macro transform(x)
    i = gensym()
    :($i -> @transform($i, $x))
end
