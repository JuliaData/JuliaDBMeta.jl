_groupby(f, d::AbstractDataset, args...) = IndexedTables.groupby(f, d, args..., flatten = true)
_groupby(f, by) = d -> IndexedTables.groupby(f, d, by, flatten = true)

function groupbyhelper(args...)
    i = gensym()
    func = Expr(:(->), i, with_helper(i, last(args)))
    Expr(:call, :(JuliaDBMeta._groupby), func, args[1:end-1]...)
end

macro groupby(args...)
    esc(groupbyhelper(args...))
end
