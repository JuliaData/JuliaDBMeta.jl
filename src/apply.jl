## Variation on Lazy macros to use _ syntax

_pipe(f, d::AbstractDataset, by; kwargs...) =  IndexedTables.groupby(f, d, by; kwargs...)
_pipe(f, d::AbstractDataset; kwargs...) = f(d)
_pipe(f, d::Columns, args...; kwargs...) = _pipe(f, _table(d), args...; kwargs...)
_pipe(f, args...; kwargs...) = d::Union{AbstractDataset, Columns} -> _pipe(f, d, args...; kwargs...)

_pipe_chunks(f, d::Dataset) = f(d)
_pipe_chunks(f, d::DDataset) = fromchunks(delayedmap(f, d.chunks))
_pipe_chunks(f, d::Columns) = _pipe_chunks(f, _table(d))
_pipe_chunks(f) = d::Union{AbstractDataset, Columns}  -> _pipe_chunks(f, d)

macro apply(args...)
    esc(Expr(:call, :(JuliaDBMeta._pipe), thread(args[end]), replace_keywords(args[1:end-1])...))
end

macro applycombine(args...)
    Base.depwarn("`@applycombine` is deprecated. Use `@apply` with `flatten = true`", Symbol("@applycombine"))
    esc(Expr(:call, :(JuliaDBMeta._pipe), thread(args[end]), args[1:end-1]..., Expr(:kw, :flatten, true)))
end

macro applychunked(args...)
    esc(Expr(:call, :(JuliaDBMeta._pipe_chunks), thread(args[end]), args[1:end-1]...))
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
