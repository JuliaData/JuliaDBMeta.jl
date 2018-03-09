## Variation on Lazy macros to use _ syntax

macro pipeline(args...)
     esc(thread(args...))
end

thread(x) = isexpr(x, :block) ? thread(rmlines(x).args...) : x

function thread(x, ex)
     if isexpr(ex, :block)
          thread(x, rmlines(ex).args...)
     elseif isa(ex, Expr)
          us = find(ex.args .== :(_))
          i = gensym()
          ex.args[us] .= i
          isempty(us) ? Expr(:call, ex, x) : Expr(:call, Expr(:(->), i, ex), x)
     else
          Expr(:call, ex, x)
     end
end

thread(x, exs...) = reduce(thread, x, exs)
