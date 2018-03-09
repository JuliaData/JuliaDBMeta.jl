_groupby(f, d::AbstractDataset, args...) = IndexedTables.groupby(f, d, args..., flatten = true)
_groupby(f, args...) = d -> IndexedTables.groupby(f, d, args..., flatten = true)

function groupbyhelper(args...)
    anon_func, syms = extract_anonymous_function(last(args), replace_column)
    Expr(:call, :(JuliaDBMeta._groupby), anon_func, args[1:end-1]...)
end

macro groupby(args...)
    esc(groupbyhelper(args...))
end
