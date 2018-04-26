addprocs(4)

@everywhere using JuliaDBMeta, Compat, NamedTuples
@everywhere using JuliaDB, Dagger
@everywhere using Compat.Test

iris1 = collect(loadtable(joinpath(@__DIR__, "tables", "iris.csv")))
iris2 = table(iris1, chunks = 5)

@testset "utils" begin
    @test JuliaDBMeta.isquotenode(Expr(:quote, 3))
    @test !JuliaDBMeta.isquotenode(Expr(:call, exp, 3))
    @test !JuliaDBMeta.isquotenode(3)
end

@testset "with" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@with t :x .+ :y) == column(t, :x) .+ column(t, :y)
    @test @with(:x .+ :y)(t) == column(t, :x) .+ column(t, :y)

    f(t) = @with(t, :x .+ :z)
    s = @inferred f(t)
    @test s == [1.1, 2.2, 3.3]
    @with t :x .= :x + :y .+ 1
    @test column(t, :x) == [6,8,10]
    @test @with(t, length(_))== length(t)
    @test @with t Base.string.(:y) == ["4", "5", "6"]
    v = @with t begin
        l = :x
        {l}
    end
    @test v == @NT(l = [6,8,10])
    c = :x
    @with(t, cols(c)) == [6,8,10]
end

@testset "byrow" begin
    t = table([1, 2, 3], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@map t :x + :y) == column(t, :x) .+ column(t, :y)
    @test @map(:x + :y)(t) == column(t, :x) .+ column(t, :y)
    s = @map(:x + :z)
    @test s(t) == [1.1, 2.2, 3.3]
    @test @map(t, {:z}) == select(t, (:z,))
    @test @map(t, :x + :x) == [2, 4, 6]
    @test @map(t, _.y) == @map(t, :y)
    @test @map(t, :x + ^(:s isa Symbol ? 1 : 0)) == [2, 3, 4]
    c = :x
    @test @map(t, cols(c) + ^(:s isa Symbol ? 1 : 0)) == [2, 3, 4]

    @byrow! t :x = :x + :y + 1
    @test t == table([6, 8, 10], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @byrow!(:x = 1)(t)
    @test column(t, :x) == [1,1,1]
    f! = @byrow!(:x = :x + :y + 1)
    @inferred f!(t)
    t = table([1, 2, 3], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    c = :x
    @byrow! t cols(c) = _.x + _.y + 1
    @test t == table([6, 8, 10], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    t1 = table([6, 8, 10], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    t2 = table(t1, chunks = 2)
    @test collect(@byrow! t2 :x = 1) == @byrow! t1 :x = 1
end

@testset "filter" begin
    t = table([1, 2, 3], [4, 5, 6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@filter t 4*:x == :y) == t[1:1]
    @test (@filter :z < 0.25)(t) == t[1:2]
    @test (@filter :z < 0.25)(t) == @filter t _.z < 0.25
end

@testset "transform" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@transform_vec t @NT(a = :x .+ :y)) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test @transform_vec(@NT(a = :x .+ :y))(t) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform_vec t @NT(z = :x .+ :y)) == setcol(t, :z, [1,2,3] .+ [4,5,6])

    @test (@transform t @NT(a = :x .+ :y))  == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test @transform(@NT(a = :x .+ :y))(t)  == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform t @NT(z = :x + :y))  == setcol(t, :z, [1,2,3] .+ [4,5,6])
    @test collect(@transform table(t, chunks = 2) @NT(z = :x + :y)) == (@transform t @NT(z = :x + :y))
end

@testset "where" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@where_vec t (:x .< 3) .& (:z .== 0.2)) == view(t, [2])
    @test @where_vec(t, 1:2) == view(t, 1:2)
    @test @where_vec(rows(t), 1:2) == view(t, 1:2)
    @test JuliaDBMeta._view(rows(t), 1:2) == view(rows(t), 1:2)
    @test @where_vec((:x .< 3) .& (:z .== 0.2))(t) == view(t, [2])
    @test (@where t (:x < 3) .& (:z == 0.2)) == view(t, [2])
    @test @where((:x < 3) .& (:z == 0.2))(t) == view(t, [2])

    t = table([1,1,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    grp = groupby(@map(@NT(z = :z))∘@where(:y != 5), t, :x, flatten = true)
    @test grp == table([1, 3], [0.1, 0.3], names = [:x, :z], pkey = :x)
    @test collect(@where iris2 :SepalLength > 4) == @where iris1 :SepalLength > 4
end

@testset "pair" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test select(t, (:x, :y) => i -> i.x+i.y) == select(t, @=>(:x+:y)) == @select(t, :x+:y) == @select(:x+:y)(t)
    @test select(t, (:x,) => i -> i.x+i.x) == select(t, @=>(:x+:x)) == @select(t, :x+:x)
    @test select(t, @=>(:x, :x+:y)) == select(t, @=>((:x, :x+:y))) == table([1,2,3], [5,7,9], names = [:x, Symbol("x + y")]) == @select(t, (:x, :x+:y))
    @test select(t, @=>(:x, :a => :x+:y)) == table([1,2,3], [5,7,9], names = [:x, :a]) == @select(t, (:x, :a => :x+:y))
end

@testset "apply" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    s = t |> @where(:x >= 2) |> @transform(@NT(s = :x + :y))
    expected = table([2, 3], [5, 6], [0.2, 0.3], [7, 9], names = [:x, :y, :z, :s])
    @test s == expected
    s2 = @apply t begin
        @where :x >= 2
        @transform {s = :x+:y}
    end
    @test s2 == expected
    s3 = @apply t begin
        @where :x >= 2
        @transform {s = :x+:y}
        map(i -> i.s, _)
    end
    @test s3 == [7, 9]
    s4 = @apply rows(t) begin
        @where :x >= 2
        @transform {s = :x+:y}
        map(i -> i.s, _)
    end
    @test s4 == [7, 9]
    @test @apply(sort(_, :y))(t) == sort(t, :y)
    @test @apply(t, sort(_, :y))  == sort(t, :y)
    @test @apply(t, sort) == sort(t)

    t = table([1,2,2], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    t1 = @apply t :x flatten=true begin
        select(_, 1:1, by = i -> i.y)
        @map {:y}
    end
    @test t1 ==  table([1,2], [4,5], names = [:x, :y], pkey = :x)
end

@testset "applychunked" begin
    t1 = @apply iris1 begin
        @where :Species == "setosa"
        @transform {Ratio = :SepalLength / :SepalWidth}
    end
    t2 = @applychunked iris2 begin
        @where :Species == "setosa"
        @transform {Ratio = :SepalLength / :SepalWidth}
    end
    @test t1 == collect(t2)
end

@testset "groupby" begin
    t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z])
    t1 = @groupby t :x {maximum(:y - :z)}
    @test t1 == table([1,2], [5.7,6.6], names = [:x, Symbol("maximum(y - z)")], pkey = :x)
    outcome = table([1,2], [5.7, 3.3], names = [:x, :m], pkey = :x)
    @test @groupby(t, :x, {m = maximum(:y - :z) / _.key.x}) == outcome
    c = :z
    @test @groupby(t, :x, {m = maximum(cols(:y) - cols(c)) / _.key.x}) == outcome
    @test @groupby(:x, {m = maximum(:y - :z) / _.key.x})(t) == outcome
    @test @groupby(reindex(t, :x), {m = maximum(:y - :z) / _.key.x}) == outcome
    @test @groupby({m = maximum(:y - :z) / _.key.x})(reindex(t, :x)) == outcome
    @test @groupby(t, :x, {l = length(_)}) == table([1,2], [2,2], names = [:x, :l], pkey = :l)
    @test @groupby(t, :x, {l = length(_)}) == t |> @groupby(:x, {l = length(_)})
    @test @groupby(t, :x, flatten = true, _) == reindex(t, :x)
    @test @groupby(t, :x, {identity = _}) == groupby(identity, t, :x)
end
