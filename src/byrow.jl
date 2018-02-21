macro byrow!(d, x)
    iter = gensym()
    function_call = replace_colname(d, x, replace_iterator, iter)
    res = quote
        for $iter in 1:length($d)
            $function_call
        end
    end
    esc(res)
end

macro byrow(d, x)
    iter = gensym()
    function_call = replace_colname(d, x, replace_iterator, iter)
    res = quote
        [$function_call for $iter in 1:length($d)]
    end
    esc(res)
end

macro with(d, x)
    esc(replace_colname(d, x, replace_column))
end

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(IndexedTables.columns($d)), x), iter)

replace_column(d, x) = Expr(:call, :getfield, :(IndexedTables.columns($d)), x)
