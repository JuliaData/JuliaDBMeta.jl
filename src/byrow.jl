macro byrow!(d, x)
    esc(byrow_helper!(d, x))
end

function byrow_helper!(d, x)
    iter = gensym()
    function_call = replace_colname(d, x, replace_iterator, iter)
    quote
        for $iter in 1:length($d)
            $function_call
        end
        $d
    end
end

macro byrow(d, x)
    esc(byrow_helper(d, x))
end

function byrow_helper(d, x)
    iter = gensym()
    function_call = replace_colname(d, x, replace_iterator, iter)
    quote
        [$function_call for $iter in 1:length($d)]
    end
end

macro with(d, x)
    esc(with_helper(d, x))
end

with_helper(d, x) = get_anonymous_function(d, x, replace_column)

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(IndexedTables.columns($d)), x), iter)

replace_column(d, x) = Expr(:call, :getfield, :(IndexedTables.columns($d)), x)
