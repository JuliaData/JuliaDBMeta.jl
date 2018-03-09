using JuliaDBMeta, IndexedTables, Compat, NamedTuples
using Compat.Test

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

    f! = @byrow!(:x = :x + :y + 1)
    @byrow! t :x = :x + :y + 1
    @test column(t, :x) == [6,8,10]
    @byrow!(:x = 1)(t)
    @test column(t, :x) == [1,1,1]
    @inferred f!(t)
end

@testset "transform" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@transform_vec t @NT(a = :x .+ :y)) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test @transform_vec(@NT(a = :x .+ :y))(t) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform_vec t @NT(z = :x .+ :y)) == setcol(t, :z, [1,2,3] .+ [4,5,6])

    @test (@transform t @NT(a = :x .+ :y))  == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test @transform(@NT(a = :x .+ :y))(t)  == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform t @NT(z = :x + :y))  == setcol(t, :z, [1,2,3] .+ [4,5,6])
end

@testset "where" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@where_vec t (:x .< 3) .& (:z .== 0.2)) == view(t, [2])
    @test @where_vec((:x .< 3) .& (:z .== 0.2))(t) == view(t, [2])
    @test (@where t (:x < 3) .& (:z == 0.2)) == view(t, [2])
    @test @where((:x < 3) .& (:z == 0.2))(t) == view(t, [2])

    t = table([1,1,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    grp = groupby(@map(@NT(z = :z))∘@where(:y != 5), t, :x, flatten = true)
    @test grp == table([1, 3], [0.1, 0.3], names = [:x, :z], pkey = :x)
end

@testset "pipeline" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    s = t |> @where(:x >= 2) |> @transform(@NT(s = :x + :y))
    expected = table([2, 3], [5, 6], [0.2, 0.3], [7, 9], names = [:x, :y, :z, :s])
    @test s == expected
    s2 = @pipeline t begin
        @where :x >= 2
        @transform {s = :x+:y}
    end
    @test s2 == expected
    s3 = @pipeline t begin
        @where :x >= 2
        @transform {s = :x+:y}
        map(i -> i.s, _)
    end
    @test s3 == [7, 9]

    @test @pipeline(3) == 3
    @test 6 == @pipeline begin
        1
        _ + 1
        _ * 3
    end
    @test @pipeline(2, exp) ≈ exp(2)
end

@testset "groupby" begin
    t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z])
    t1 = @groupby t :x {maximum(:y - :z)}
    @test t1 == table([1,2], [5.7,6.6], names = [:x, Symbol("maximum(y - z)")], pkey = :x)
    outcome = table([1,2], [5.7, 3.3], names = [:x, :m], pkey = :x)
    @test @groupby(t, :x, {m = maximum(:y - :z) / _.key.x}) == outcome
    @test @groupby(:x, {m = maximum(:y - :z) / _.key.x})(t) == outcome
    @test @groupby(reindex(t, :x), {m = maximum(:y - :z) / _.key.x}) == outcome
    @test @groupby({m = maximum(:y - :z) / _.key.x})(reindex(t, :x)) == outcome
    @test @groupby(t, :x, {l = length(_)}) == table([1,2], [2,2], names = [:x, :l], pkey = :l)
    @test @groupby(t, :x, {l = length(_)}) == t |> @groupby(:x, {l = length(_)})
end
