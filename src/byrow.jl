macro byrow!(d, x)
    esc(byrow_helper(d, x))
end

macro byrow!(x)
    i = gensym()
    esc(Expr(:(->), i, byrow_helper(i, x)))
end

function byrow_helper(d, x)
    iter = gensym()
    function_call = replace_colname(d, x, replace_iterator, iter)
    quote
        for $iter in 1:length($d)
            $function_call
        end
        $d
    end
end

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(IndexedTables.columns($d)), x), iter)

replace_column(d, x) = Expr(:call, :getfield, :(IndexedTables.columns($d)), x)
