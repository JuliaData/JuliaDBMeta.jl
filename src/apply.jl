## Variation on Lazy macros to use _ syntax

_pipe(f, d::AbstractDataset, by; kwargs...) =  IndexedTables.groupby(f, d, by; kwargs...)
_pipe(f, d::AbstractDataset; kwargs...) = f(d)
_pipe(f, d::Columns, args...; kwargs...) = _pipe(f, _table(d), args...; kwargs...)
_pipe(f, args...; kwargs...) = d::Union{AbstractDataset, Columns} -> _pipe(f, d, args...; kwargs...)

_pipe_chunks(f, d::Dataset) = f(d)
_pipe_chunks(f, d::DDataset) = fromchunks(delayedmap(f, d.chunks))
_pipe_chunks(f, d::Columns) = _pipe_chunks(f, _table(d))
_pipe_chunks(f) = d::Union{AbstractDataset, Columns}  -> _pipe_chunks(f, d)

"""
`@apply(args...)`

Concatenate a series of operations. Non-macro operations from JuliaDB, are supported via
 the `_` curryfication syntax. A second optional argument is used for grouping:

```jldoctest apply
julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);

julia> @apply t begin
          @where :x >= 2
          @transform {:x+:y}
          sort(_, :z)
       end
Table with 2 rows, 4 columns:
x  y  z    x + y
────────────────
2  5  0.2  7
2  7  0.4  9

julia> @apply t :x flatten=true begin
          @transform {w = :y + 1}
          sort(_, :w)
       end
Table with 4 rows, 4 columns:
x  y  z    w
────────────
1  4  0.1  5
1  6  0.3  7
2  5  0.2  6
2  7  0.4  8
```
"""
macro apply(args...)
    esc(Expr(:call, :(JuliaDBMeta._pipe), thread(args[end]), replace_keywords(args[1:end-1])...))
end

"""
`@applychunked(args...)`

Split the table into chunks, apply the processing pipeline separately to each chunk and return the result
as a distributed table.

```jldoctest applychunked
julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z], chunks = 2);

julia> @applychunked t begin
          @where :x >= 2
          @transform {:x+:y}
          sort(_, :z)
       end
Distributed Table with 2 rows in 2 chunks:
x  y  z    x + y
────────────────
2  5  0.2  7
2  7  0.4  9
```
"""
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
