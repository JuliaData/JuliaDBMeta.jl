_groupby(f, d::AbstractDataset, args...) = IndexedTables.groupby(f, d, args..., flatten = true, usekey = true)
_groupby(f, d::AbstractDataset, syms::NTuple{N, Symbol}, args...) where {N} =
    IndexedTables.groupby(f, d, args..., flatten = true, usekey = true, select = syms)
_groupby(f, syms::NTuple{N, Symbol}, d::AbstractDataset, args...) where {N} =
    _groupby(f, d, syms, args...)
_groupby(f, args...) = d::AbstractDataset -> _groupby(f, d, args...)

function groupbyhelper(args...)
    x = helper_namedtuples_replacement(last(args))
    anon_func, syms = extract_anonymous_function(x, replace_column, usekey = true)
    if !isempty(syms) && !(:(_) in syms)
        Expr(:call, :(JuliaDBMeta._groupby), anon_func, :(Tuple($syms)), args[1:end-1]...)
    else
        Expr(:call, :(JuliaDBMeta._groupby), anon_func, args[1:end-1]...)
    end
end

macro groupby(args...)
    esc(groupbyhelper(args...))
end
