macro byrow!(d, x)
    esc(byrow_helper!(d, x))
end

macro byrow!(x)
    i = gensym()
    :($i -> @byrow!($i, $x))
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

macro map(d, x)
    esc(map_helper(d, x))
end

macro map(x)
    i = gensym()
    :($i -> @map($i, $x))
end

function map_helper(d, x)
    iter = gensym()
    use_anonymous_function(d, x, replace_column, :map)
end

macro with(d, x)
    esc(with_helper(d, x))
end

macro with(x)
    i = gensym()
    :($i -> @with($i, $x))
end

with_helper(d, x) = replace_colname(d, x, replace_column)

replace_iterator(d, x, iter) = Expr(:ref, Expr(:call, :getfield, :(IndexedTables.columns($d)), x), iter)

replace_column(d, x) = Expr(:call, :getfield, :(IndexedTables.columns($d)), x)
