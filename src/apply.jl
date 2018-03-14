## Variation on Lazy macros to use _ syntax

_pipe(f, d::AbstractDataset, by; flatten = false) =  IndexedTables.groupby(f, d, by, flatten = flatten)
_pipe(f, d::AbstractDataset; flatten = false) = f(d)
_pipe(f, args...; kwargs...) = d::AbstractDataset -> _pipe(f, d, args...; kwargs...)

_pipe_chunks(f, d::Dataset) = f(d)
_pipe_chunks(f, d::DDataset) = fromchunks(delayedmap(f, d.chunks))
_pipe_chunks(f) = d::AbstractDataset -> _pipe_chunks(f, d)

function apply_helper(args...; flatten = false, chunked = false)
     func = thread(args[end])
     if chunked
        Expr(:call, :(JuliaDBMeta._pipe_chunks), func, args[1:end-1]...)
     else
        Expr(:call, :(JuliaDBMeta._pipe), func, args[1:end-1]..., Expr(:kw, :flatten, flatten))
     end
end

macro apply(args...)
     esc(apply_helper(args...; flatten = false))
end

macro applycombine(args...)
     esc(apply_helper(args...; flatten = true))
end

macro applychunked(args...)
    esc(apply_helper(args...; chunked = true))
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
