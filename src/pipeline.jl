## Variation on Lazy macros to use _ syntax

_pipe(f, d::AbstractDataset, by) = groupby(f, d, by)
_pipe(f, d::AbstractDataset) = f(d)
_pipe(f, args...) = d::AbstractDataset -> _pipe(f, d, args...)

function pipeline_helper(args...)
     func = thread(args[end])
     Expr(:call, :(JuliaDBMeta._pipe), func, args[1:end-1]...)
end

macro pipeline(args...)
     esc(pipeline_helper(args...))
end

function thread(ex)
     if isexpr(ex, :block)
          thread(rmlines(ex).args...)
     elseif isa(ex, Expr)
          us = find(ex.args .== :(_))
          i = gensym()
          ex.args[us] .= i
          isempty(us) ? ex : Expr(:(->), i, ex)
     else
          ex
     end
end

thread(exs...) = mapreduce(thread, (ex1, ex2) -> Expr(:call, Symbol(∘), ex2, ex1), exs)
