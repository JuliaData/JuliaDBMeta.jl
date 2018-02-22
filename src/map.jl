macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    :($i -> @map($i, $x))
end

map_helper(d, x) = use_anonymous_function(d, x, replace_column, :(JuliaDBMeta._map))


_table(x::AbstractArray{<:NamedTuples.NamedTuple}) = table(convert(Columns, x), copy = false)
_table(x::Columns) = table(x, copy = false)
_table(x::AbstractArray) = x

function _map(f, args...)
    iter = zip(args...)
    i = first(iter)
    val = f(i...)
    dest = similar(IndexedTables.arrayof(typeof(val)), length(iter))
    dest[1] = val
    _map!(dest, f, IterTools.drop(iter, 1))
    _table(dest)
end

function _map!(dest, f, iter)
    for (ind, i) in enumerate(iter)
        dest[ind+1] = f(i...)
    end
    dest
end
