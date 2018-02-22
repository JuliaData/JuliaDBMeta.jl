using JuliaDBMeta, IndexedTables, Compat
using Compat.Test

@testset "with" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@with t :x .+ :y) == column(t, :x) .+ column(t, :y)
    f(t) = @with(t, :x .+ :z)
    s = @inferred f(t)
    @test s == [1.1, 2.2, 3.3]
    @with t :x .= :x + :y .+ 1
    @test column(t, :x) == [6,8,10]
end

@testset "byrow" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@map t :x + :y) == column(t, :x) .+ column(t, :y)
    f = @map(:x + :z)
    s = @inferred f(t)
    @test s == [1.1, 2.2, 3.3]
    f! = @byrow!(:x = :x + :y + 1)
    @byrow! t :x = :x + :y + 1
    @test column(t, :x) == [6,8,10]
    @inferred f!(t)
end


@testset "transform" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@transform_vec t :a = :x .+ :y) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform t :a = :x .+ :y)  == pushcol(t, :a, [1,2,3] .+ [4,5,6])
    @test (@transform_vec t :z = :x .+ :y) == setcol(t, :z, [1,2,3] .+ [4,5,6])
    @test (@transform t :z = :x .+ :y)  == setcol(t, :z, [1,2,3] .+ [4,5,6])
end
