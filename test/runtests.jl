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
    @test (@byrow t :x + :y) == column(t, :x) .+ column(t, :y)
    f(t) = @byrow(t, :x + :z)
    s = @inferred f(t)
    @test s == [1.1, 2.2, 3.3]
    @byrow! t :x = :x + :y + 1
    @test column(t, :x) == [6,8,10]
end


@testset "transform" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@transform t :a = :x .+ :y) == pushcol(t, :a, [1,2,3] .+ [4,5,6])
end
