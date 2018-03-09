## Variation on Lazy macros to use _ syntax

macro pipeline(x, ex, args...)
     esc(thread(x, ex, args...))
end

macro pipeline(ex)
     i = gensym()
     esc(Expr(:(->), i, thread(i, ex)))
end

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
