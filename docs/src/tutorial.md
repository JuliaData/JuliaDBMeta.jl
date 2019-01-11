# Tutorial

Flights tutorial with JuliaDBMeta.

## Getting the data

The data is some example flight dataset that you can find [here](https://raw.githubusercontent.com/piever/JuliaDBTutorial/master/hflights.csv).
Simply open the link and choose `Save as` from the `File` menu in your browser to save the data to a folder on your computer.

## Loading the data

Loading a csv file is straightforward with JuliaDB:

```julia
using JuliaDBMeta
flights = loadtable("/home/pietro/Documents/testdata/hflights.csv");
```

Of course, replace the path with the location of the dataset you have just downloaded.

## Filtering the data

In order to select only rows matching certain criteria, use the `where` macro:


```julia
@where flights :Month == 1 && :DayofMonth == 1;
```

To test if one of two conditions is verified:


```julia
@where flights :UniqueCarrier == "AA" || :UniqueCarrier == "UA";

# in this case, you can simply test whether the `UniqueCarrier` is in a given list:

@where flights :UniqueCarrier in ["AA", "UA"];
```

## Applying several operations

If one wants to apply several operations one after the other, there are two main approaches:

- nesting
- piping

Let's assume we want to select `UniqueCarrier` and `DepDelay` columns and filter for delays over 60 minutes. The nesting approach would be:



```julia
@where select(flights, (:UniqueCarrier, :DepDelay)) !ismissing(:DepDelay) && :DepDelay > 60
```




    Table with 10242 rows, 2 columns:
    UniqueCarrier  DepDelay
    ───────────────────────
    "AA"           90
    "AA"           67
    "AA"           74
    "AA"           125
    "AA"           82
    "AA"           99
    "AA"           70
    "AA"           61
    "AA"           74
    "AS"           73
    "B6"           136
    "B6"           68
    ⋮
    "WN"           129
    "WN"           61
    "WN"           70
    "WN"           76
    "WN"           63
    "WN"           144
    "WN"           117
    "WN"           124
    "WN"           72
    "WN"           70
    "WN"           78



Piping:


```julia
select(flights, (:UniqueCarrier, :DepDelay)) |> @where !ismissing(:DepDelay) && :DepDelay > 60
```


where the variable `x` denotes our data at each stage. At the beginning it is `flights`, then it only has the two relevant columns and, at the last step, it is filtered.

To avoid the parenthesis and to use the `_` curryfication syntax, you can use the `@apply` macro instead:


```julia
@apply flights begin
    select(_, (:UniqueCarrier, :DepDelay))
    @where !ismissing(:DepDelay) && :DepDelay > 60
end
```

## Apply a function row by row

To apply a function row by row, use `@map`: the first argument is the dataset, the second is the expression you want to compute (symbols are columns):


```julia
speed = @map flights :Distance / :AirTime * 60
```




    227496-element Array{Union{Missing, Float64},1}:
     336.0  
     298.667
     280.0  
     344.615
     305.455
     298.667
     312.558
     336.0  
     327.805
     298.667
     320.0  
     327.805
     305.455
     ⋮      
     261.818
     508.889
     473.793
     479.302
     496.627
     468.6  
     478.163
     483.093
     498.511
     445.574
     424.688
     460.678



## Add new variables
Use the `@transform` function to add a column to an existing dataset:


```julia
@transform flights {Speed = :Distance / :AirTime * 60}
```

## Reduce variables to values

To get the average delay, we first filter away datapoints where `ArrDelay` is missing, then group by `:Dest`, select `:ArrDelay` and compute the mean:


```julia
using Statistics
@groupby flights :Dest {mean(skipmissing(:ArrDelay))}
```




    Table with 116 rows, 2 columns:
    Dest   mean(skipmissing(ArrDelay))
    ─────────────────────────────
    "ABQ"  7.22626
    "AEX"  5.83944
    "AGS"  4.0
    "AMA"  6.8401
    "ANC"  26.0806
    "ASE"  6.79464
    "ATL"  8.23325
    "AUS"  7.44872
    "AVL"  9.97399
    "BFL"  -13.1988
    "BHM"  8.69583
    "BKG"  -16.2336
    ⋮
    "SJU"  11.5464
    "SLC"  1.10485
    "SMF"  4.66271
    "SNA"  0.35801
    "STL"  7.45488
    "TPA"  4.88038
    "TUL"  6.35171
    "TUS"  7.80168
    "TYS"  11.3659
    "VPS"  12.4572
    "XNA"  6.89628



## Performance tip

If you'll group often by the same variable, you can sort your data by that variable at once to optimize future computations.


```julia
sortedflights = reindex(flights, :Dest)
```


```julia
using BenchmarkTools

println("Presorted timing:")
@benchmark @groupby sortedflights {mean(skipmissing(:ArrDelay))}
```

    Presorted timing:

    BenchmarkTools.Trial:
      memory estimate:  24.77 MiB
      allocs estimate:  1364979
      --------------
      minimum time:     34.392 ms (4.74% GC)
      median time:      36.882 ms (4.72% GC)
      mean time:        37.042 ms (5.33% GC)
      maximum time:     41.001 ms (9.15% GC)
      --------------
      samples:          136
      evals/sample:     1




```julia
println("Non presorted timing:")
@benchmark @groupby flights :Dest {mean(skipmissing(:ArrDelay))}
```

    Non presorted timing:

    BenchmarkTools.Trial:
      memory estimate:  19.37 MiB
      allocs estimate:  782824
      --------------
      minimum time:     139.882 ms (1.21% GC)
      median time:      145.401 ms (1.17% GC)
      mean time:        147.250 ms (1.06% GC)
      maximum time:     170.298 ms (1.23% GC)
      --------------
      samples:          34
      evals/sample:     1



Using `summarize`, we can summarize several columns at the same time:

For each day of the month, count the total number of flights and sort in descending order:


```julia
@apply flights begin
    @groupby :DayofMonth {length = length(_)}
    sort(_, :length, rev = true)
end
```



    Table with 31 rows, 2 columns:
    DayofMonth  length
    ──────────────────
    28          7777
    27          7717
    21          7698
    14          7694
    7           7621
    18          7613
    6           7606
    20          7599
    11          7578
    13          7546
    10          7541
    17          7537
    ⋮
    25          7406
    16          7389
    8           7366
    12          7301
    4           7297
    19          7295
    24          7234
    5           7223
    30          6728
    29          6697
    31          4339



For each destination, count the total number of flights and the number of distinct planes that flew there


```julia
@groupby flights :Dest {length(:TailNum), length(unique(:TailNum))}
```



    Table with 116 rows, 3 columns:
    Dest   length(TailNum)  length(unique(TailNum))
    ───────────────────────────────────────────────
    "ABQ"  2812             716
    "AEX"  724              215
    "AGS"  1                1
    "AMA"  1297             158
    "ANC"  125              38
    "ASE"  125              60
    "ATL"  7886             983
    "AUS"  5022             1015
    "AVL"  350              142
    "BFL"  504              70
    "BHM"  2736             616
    "BKG"  110              63
    ⋮
    "SJU"  391              115
    "SLC"  2033             368
    "SMF"  1014             184
    "SNA"  1661             67
    "STL"  2509             788
    "TPA"  3085             697
    "TUL"  2924             771
    "TUS"  1565             226
    "TYS"  1210             227
    "VPS"  880              224
    "XNA"  1172             177



## Window functions

In the previous section, we always applied functions that reduced a table or vector to a single value.
Window functions instead take a vector and return a vector of the same length, and can also be used to
manipulate data. For example we can rank, within each `UniqueCarrier`, how much
delay a given flight had and figure out the day and month with the two greatest delays:


```julia
using StatsBase
@apply flights :UniqueCarrier flatten = true begin
    # Exclude flights with missing DepDelay
    @where !ismissing(:DepDelay)
    # Select only those whose rank is less than 2
    @where_vec ordinalrank(:DepDelay, rev = true) .<= 2
    # Select appropriate fields
    @map {:Month, :DayofMonth, :DepDelay}    
    # sort
    sort(_, :DepDelay, rev = true)
end
```



    Table with 30 rows, 4 columns:
    UniqueCarrier  Month  DayofMonth  DepDelay
    ──────────────────────────────────────────
    "AA"           12     12          970
    "AA"           11     19          677
    "AS"           2      28          172
    "AS"           7      6           138
    "B6"           10     29          310
    "B6"           8      19          283
    "CO"           8      1           981
    "CO"           1      20          780
    "DL"           10     25          730
    "DL"           4      5           497
    "EV"           6      25          479
    "EV"           1      5           465
    ⋮
    "OO"           4      4           343
    "UA"           6      21          869
    "UA"           9      18          588
    "US"           4      19          425
    "US"           8      26          277
    "WN"           4      8           548
    "WN"           9      29          503
    "XE"           12     29          628
    "XE"           12     29          511
    "YV"           4      22          54
    "YV"           4      30          46



Though in this case, it would have been simpler to use Julia partial sorting:


```julia
@apply flights :UniqueCarrier flatten = true begin
    # Exclude flights with missing DepDelay
    @where !ismissing(:DepDelay)
    # Select appropriate fields
    @map {:Month, :DayofMonth, :DepDelay}
    # select
    @where_vec partialsortperm(:DepDelay, 1:2, rev = true)
end;
```

For each month, calculate the number of flights and the change from the previous month


```julia
using ShiftedArrays
@apply flights begin
    @groupby :Month {length = length(_)}
    @transform_vec {change = :length .- lag(:length)}
end
```


    Table with 12 rows, 3 columns:
    Month  length  change
    ──────────────────────
    1      18910   missing
    2      17128   -1782
    3      19470   2342
    4      18593   -877
    5      19172   579
    6      19600   428
    7      20548   948
    8      20176   -372
    9      18065   -2111
    10     18696   631
    11     18021   -675
    12     19117   1096



You can also use a different default value with ShiftedArrays (for example, with an `Array` of `Float64` you could do:


```julia
v = [1.2, 2.3, 3.4]
lag(v, default = NaN)
```

## Visualizing your data

The [StatPlots](https://github.com/JuliaPlots/StatPlots.jl) package as well as native plotting recipes from JuliaDB using [OnlineStats](https://github.com/joshday/OnlineStats.jl) make a rich set of visualizations possible with an intuitive syntax.

Use the `@df` macro to be able to refer to columns simply by their name. You can work with these symobls as if they are regular vectors. Here for example, we color according to the departure delay renormalized by its maximum.


```julia
using StatPlots
@apply flights begin
    @transform {Far = :Distance > 1000}
    @groupby (:Month, :Far) {MeanDep = mean(skipmissing(:DepDelay)), MeanArr = mean(skipmissing(:ArrDelay))}
    @df scatter(:MeanDep, :MeanArr, group = {:Far}, layout = 2, zcolor = :MeanDep ./maximum(:MeanDep), legend = :topleft)
end
```



![output_42_0](https://user-images.githubusercontent.com/6333339/37535353-60a1121c-293f-11e8-987c-7c5bc0f1580e.png)



For large datasets, summary statistics can be computed using efficient online algorithms implemnted in [OnlineStats](https://github.com/joshday/OnlineStats.jl). Here for example we compute the `extrema` of the travelled distance for each section of the dataset. Using the `by` keyword we can run the analysis separately according to a splitting variable, here we'll be splitting by month. As with `@df`, we can run this plot at the end of our pipeline.


```julia
using OnlineStats
@apply flights begin
    @where 500 < :Distance < 2000
    partitionplot(_, :Distance, stat = Extrema(), by = :Month, layout = 12, legend = false, xticks = [])
end
```


![output_44_0](https://user-images.githubusercontent.com/6333339/37535369-6e76f06e-293f-11e8-8b5d-b950cbf99765.png)
