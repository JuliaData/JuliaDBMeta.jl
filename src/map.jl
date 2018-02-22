macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    :($i -> @map($i, $x))
end

#Optimize: avoid intermediate array of tuples (groupreduceto!)
map_helper(d, x) = use_anonymous_function(d, x, replace_column, :(JuliaDBMeta._map))

_map(f, args...) = _table(map(f, args...))

_table(x::AbstractArray{<:NamedTuples.NamedTuple}) = table(convert(Columns, x), copy = false)
_table(x::AbstractArray) = x
