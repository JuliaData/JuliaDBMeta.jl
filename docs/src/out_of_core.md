# Out-of-core support

[Row-wise macros](@ref) can be trivially implemented in parallel and will work out of the box with out-of-core tables.

[Grouping operations](@ref) will work on out-of-core data tables, but may involve some data shuffling as it requires data belonging to the same group to be on the same processor.

[`@applychunked`](@ref) will apply the analysis pipeline separately to each chunk of data in parallel and collect the result as a distributed table.

[Column-wise macros](@ref) do not have a parallel implementation yet (they require working on the whole column at the same time which makes it difficult to parallelize them).
