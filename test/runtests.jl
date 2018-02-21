using JuliaDBMeta, IndexedTables, Compat
using Compat.Test

# write your own tests here
@testset "with" begin
    t = table([1,2,3], [4,5,6], [0.1, 0.2, 0.3], names = [:x, :y, :z])
    @test (@with t :x .+ :y) == column(t, :x) .+ column(t, :y)
    f(t) = @with(t, :x .+ :z)
    s = @inferred f(t)
    @test s == [1.1, 2.2, 3.3]
    @with t :x .= :y .+ 1
    @test column(t, :x) == [5,6,7]
end
