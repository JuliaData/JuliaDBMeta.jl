using JuliaDBMeta, IndexedTables, Compat
using Compat.Test

# write your own tests here
@testset "with" begin
    t = table([1,2,3], [4,5,6], names = [:x, :y])
    @test (@with t :x .+ :y) == column(t, :x) .+ column(t, :y)
    @with t :x .= :y .+ 1
    @test column(t, :x) == [5,6,7]
end
