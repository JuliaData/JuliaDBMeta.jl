macro byrow!(d, x)
    esc(byrow_helper(d, x))
end

macro byrow!(x)
    i = gensym()
    esc(Expr(:(->), i, byrow_helper(i, x)))
end

function byrow_helper(d, x)
    iter = gensym()
    function_call = parse_function_call(d, x, replace_iterator, iter)
    quote
        for $iter in 1:length($d)
            $function_call
        end
        $d
    end
end

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(JuliaDBMeta.columns($d)), x), iter)
