# Out-of-core support

JuliaDBMeta supports out-of-core operations in several different ways. In the following examples, we will have started the REPL with `julia -p 4`

## Row-wise macros parallelize out of the box

[Row-wise macros](@ref) can be trivially implemented in parallel and will work out of the box with out-of-core tables.

```jldoctest distributed
julia> iris = loadtable(Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv"));

julia> iris5 = table(iris, chunks = 5);

julia> @where iris5 :SepalLength == 4.9 && :Species == "setosa"
Distributed Table with 4 rows in 2 chunks:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
──────────────────────────────────────────────────────────
4.9          3.0         1.4          0.2         "setosa"
4.9          3.1         1.5          0.1         "setosa"
4.9          3.1         1.5          0.2         "setosa"
4.9          3.6         1.4          0.1         "setosa"
```

## Grouping operations parallelize with some data shuffling

[Grouping operations](@ref) will work on out-of-core data tables, but may involve some data shuffling as it requires data belonging to the same group to be on the same processor.

```jldoctest distributed
julia> @groupby iris5 :Species {mean(:SepalLength)}
Distributed Table with 3 rows in 3 chunks:
Species       mean(SepalLength)
───────────────────────────────
"setosa"      5.006
"versicolor"  5.936
"virginica"   6.588
```

## Apply a pipeline to your data in chunks

[`@applychunked`](@ref) will apply the analysis pipeline separately to each chunk of data in parallel and collect the result as a distributed table.

```jldoctest distributed
julia> @applychunked iris5 begin
           @where :Species == "setosa" && :SepalLength == 4.9
           @transform {Ratio = :SepalLength / :SepalWidth}
       end
Distributed Table with 4 rows in 2 chunks:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species   Ratio
───────────────────────────────────────────────────────────────────
4.9          3.0         1.4          0.2         "setosa"  1.63333
4.9          3.1         1.5          0.1         "setosa"  1.58065
4.9          3.1         1.5          0.2         "setosa"  1.58065
4.9          3.6         1.4          0.1         "setosa"  1.36111
```

## Column-wise macros do not parallelize yet

[Column-wise macros](@ref) do not have a parallel implementation yet, unless when grouping: they require working on the whole column at the same time which makes it difficult to parallelize them.
