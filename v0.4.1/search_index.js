var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "JuliaDBMeta is a set of macros to simplify data manipulation with JuliaDB, heavily inspired on DataFramesMeta. It exploit the technical advantages of JuliaDB:Fully-type tables with type stable column extraction\nFast row iteration\nParallel data storage and parallel computationsSome ideas also come from Query.jl, in particular the curly bracket syntax is from there.The macro packages Lazy and MacroTools were also very useful in designing this package: the @apply macro is inspired by the concatenation macros in Lazy."
},

{
    "location": "#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "To install, simply type the following command in the Julia REPL:Pkg.add(\"JuliaDBMeta\")"
},

{
    "location": "getting_started/#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started/#Getting-started-1",
    "page": "Getting Started",
    "title": "Getting started",
    "category": "section",
    "text": ""
},

{
    "location": "getting_started/#Installation-1",
    "page": "Getting Started",
    "title": "Installation",
    "category": "section",
    "text": "To install the package simply type:Pkg.add(\"JuliaDBMeta\")in a Julia REPL.To have the latest feature, you can checkout the unreleased version with:Pkg.checkout(\"JuliaDBMeta\")"
},

{
    "location": "getting_started/#Example-use-1",
    "page": "Getting Started",
    "title": "Example use",
    "category": "section",
    "text": "As a simple example, let\'s select rows according to some conditions. This is done using the macro @where. As with all macros, the first argument is the data table (if omitted, the macro is automatically curried) and the last argument is an expression whose symbols will correspond to the various fields of the data.iris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"))\n@where iris :Species == \"versicolor\" && :SepalLength > 6To combine many operations use @apply:@apply iris begin\n    @where :Species == \"versicolor\" && :SepalLength > 6\n    # add new column Ratio = SepalLength / SepalWidth\n    @transform {Ratio = :SepalLength/:SepalWidth}\n    @where :Ratio > 2\nendPass an optional grouping argument to @apply to also group your data before running the pipeline:@apply iris :Species flatten = true begin\n    # select existing column SepalWidth and new column Ratio = SepalLength / SepalWidth\n   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}\n   # sort by SepalWidth\n   sort(_, :SepalWidth, rev = true)\n   # select first three rows of each group\n   _[1:3]\nend"
},

{
    "location": "row_macros/#",
    "page": "Row-wise macros",
    "title": "Row-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "row_macros/#Row-wise-macros-1",
    "page": "Row-wise macros",
    "title": "Row-wise macros",
    "category": "section",
    "text": "Row-wise macros allow using symbols to refer to fields of a row. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a begin ... end block). If the table is omitted, the macro is automatically curried (useful for piping).Shared features across all row-wise macros:Symbols refer to fields of the row.\n_ refers to the whole row.\nTo use actual symbols, escape them with ^, as in ^(:a).\nUse cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\nOut-of-core tables are supported out of the box"
},

{
    "location": "row_macros/#JuliaDBMeta.@byrow!",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@byrow!",
    "category": "macro",
    "text": "@byrow!(d, x)\n\nApply the expression x row by row in d (to modify d in place). Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @byrow! t :b = :b*string(:a)\nTable with 3 rows, 2 columns:\na  b\n───────\n1  \"x1\"\n2  \"y2\"\n3  \"z3\"\n\njulia> @byrow! t begin\n       :a = :a*2\n       :b = \"x\"^:a\n       end\nTable with 3 rows, 2 columns:\na  b\n───────────\n2  \"xx\"\n4  \"xxxx\"\n6  \"xxxxxx\"\n\n\n\n\n\n"
},

{
    "location": "row_macros/#Modify-data-in-place-1",
    "page": "Row-wise macros",
    "title": "Modify data in place",
    "category": "section",
    "text": "@byrow!"
},

{
    "location": "row_macros/#JuliaDBMeta.@map",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@map",
    "category": "macro",
    "text": "@map(d, x)\n\nApply the expression x row by row in d: return the result as an array or as a table (if the elements are Tuples or NamedTuples). Use {} syntax for automatically named NamedTuples. Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @map t :b*string(:a)\n3-element Array{String,1}:\n \"x1\"\n \"y2\"\n \"z3\"\n\njulia> @map t {:a, copy = :a, :b}\nTable with 3 rows, 3 columns:\na  copy  b\n────────────\n1  1     \"x\"\n2  2     \"y\"\n3  3     \"z\"\n\n\n\n\n\n"
},

{
    "location": "row_macros/#Apply-a-function-1",
    "page": "Row-wise macros",
    "title": "Apply a function",
    "category": "section",
    "text": "@map"
},

{
    "location": "row_macros/#JuliaDBMeta.@transform",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@transform",
    "category": "macro",
    "text": "@transform(d, x)\n\nApply the expression x row by row in d: collect the result as a table (elements returned by x must be NamedTuples) and merge it horizontally with d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform t {:a + 1}\nTable with 3 rows, 3 columns:\na  b    a + 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n\n\n"
},

{
    "location": "row_macros/#Add-or-modify-a-column-1",
    "page": "Row-wise macros",
    "title": "Add or modify a column",
    "category": "section",
    "text": "@transform"
},

{
    "location": "row_macros/#JuliaDBMeta.@where",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@where",
    "category": "macro",
    "text": "@where(d, x)\n\nApply the expression x row by row in d: collect the result as an Array (elements returned by x must be booleans) and use it to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where t :a <= 2\nTable with 2 rows, 2 columns:\na  b\n──────\n1  \"x\"\n2  \"y\"\n\n\n\n\n\n"
},

{
    "location": "row_macros/#JuliaDBMeta.@filter",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@filter",
    "category": "macro",
    "text": "@filter(d, x)\n\nFilter rows according to the expression x row by row in d. Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b=[2,3,4]));\n\njulia> @filter t :a < 3\nTable with 2 rows, 2 columns:\na  b\n────\n1  2\n2  3\n\njulia> @filter t 2*:a > :b\nTable with 2 rows, 2 columns:\na  b\n────\n2  3\n3  4\n\n\n\n\n\n"
},

{
    "location": "row_macros/#Select-data-1",
    "page": "Row-wise macros",
    "title": "Select data",
    "category": "section",
    "text": "@where@filter"
},

{
    "location": "column_macros/#",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "column_macros/#Column-wise-macros-1",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "section",
    "text": "Column-wise macros allow using symbols instead of columns. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a begin ... end block). If the table is omitted, the macro is automatically curried (useful for piping).Shared features across all row-wise macros:Symbols refer to fields of the row.\n_ refers to the whole table.\nTo use actual symbols, escape them with ^, as in ^(:a).\nUse cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\nAn optional grouping argument is allowed: see Column-wise macros with grouping argument\nOut-of-core tables are not supported out of the box, except when grouping"
},

{
    "location": "column_macros/#JuliaDBMeta.@with",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@with",
    "category": "macro",
    "text": "@with(d, x)\n\nReplace all symbols in expression x with the respective column in d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @with t mean(:a)\n2.0\n\njulia> @with t mean(:a)*length(_)\n6.0\n\njulia> @with t join(:b)\n\"xyz\"\n\njulia> @with t @show ^(:a) != :a\n:a != getfield(JuliaDBMeta.columns(t), :a) = true\ntrue\n\njulia> c = :a\n:a\n\njulia> @with t cols(c)\n3-element Array{Int64,1}:\n 1\n 2\n 3\n\nNote that you can use this syntax to modify columns in place as well:\n\njulia> @with t :b .= :b .* string.(:a)\n3-element Array{String,1}:\n \"x1\"\n \"y2\"\n \"z3\"\n\njulia> t\nTable with 3 rows, 2 columns:\na  b\n───────\n1  \"x1\"\n2  \"y2\"\n3  \"z3\"\n\n\n\n\n\n"
},

{
    "location": "column_macros/#Replace-symbols-with-columns-1",
    "page": "Column-wise macros",
    "title": "Replace symbols with columns",
    "category": "section",
    "text": "@with"
},

{
    "location": "column_macros/#JuliaDBMeta.@transform_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@transform_vec",
    "category": "macro",
    "text": "@transform_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  a NamedTuple of vectors or a table and is horizontally merged with d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform_vec t {:a .+ 1}\nTable with 3 rows, 3 columns:\na  b    a .+ 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n\n\n"
},

{
    "location": "column_macros/#Add-or-modify-a-column-1",
    "page": "Column-wise macros",
    "title": "Add or modify a column",
    "category": "section",
    "text": "@transform_vec"
},

{
    "location": "column_macros/#JuliaDBMeta.@where_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@where_vec",
    "category": "macro",
    "text": "@where_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  an Array of booleans which is used to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). The result has to be a NamedTuple of vectors or a table and is horizontally merged with d. Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where_vec t (:a .>= 2) .& (:b .!= \"y\")\nTable with 1 rows, 2 columns:\na  b\n──────\n3  \"z\"\n\n\n\n\n\n"
},

{
    "location": "column_macros/#Select-data-1",
    "page": "Column-wise macros",
    "title": "Select data",
    "category": "section",
    "text": "@where_vec"
},

{
    "location": "selection/#",
    "page": "Selection",
    "title": "Selection",
    "category": "page",
    "text": ""
},

{
    "location": "selection/#JuliaDBMeta.@=>",
    "page": "Selection",
    "title": "JuliaDBMeta.@=>",
    "category": "macro",
    "text": "@=>(expr...)\n\nCreate a selector based on expressions expr. Symbols are used to select columns and infer an appropriate anonymous function. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [4,5,6]));\n\njulia> select(t, @=>(:a, :a + :b))\nTable with 3 rows, 2 columns:\na  a + b\n────────\n1  5\n2  7\n3  9\n\n\n\n\n\n"
},

{
    "location": "selection/#JuliaDBMeta.@select",
    "page": "Selection",
    "title": "JuliaDBMeta.@select",
    "category": "macro",
    "text": "@select(d, x)\n\nShort-hand for select(d, @=>(x))\n\nExamples\n\njulia> t = table((a = [1,2,3], b = [4,5,6]));\n\njulia> @select(t, (:a, :a + :b))\nTable with 3 rows, 2 columns:\na  a + b\n────────\n1  5\n2  7\n3  9\n\n\n\n\n\n"
},

{
    "location": "selection/#Selection-1",
    "page": "Selection",
    "title": "Selection",
    "category": "section",
    "text": "Experimentally, there is a new macro to simplify the creation of selector objects:@=>@select"
},

{
    "location": "pipeline_macros/#",
    "page": "Pipeline macros",
    "title": "Pipeline macros",
    "category": "page",
    "text": ""
},

{
    "location": "pipeline_macros/#JuliaDBMeta.@apply",
    "page": "Pipeline macros",
    "title": "JuliaDBMeta.@apply",
    "category": "macro",
    "text": "@apply(args...)\n\nConcatenate a series of operations. Non-macro operations from JuliaDB, are supported via  the _ curryfication syntax. A second optional argument is used for grouping:\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);\n\njulia> @apply t begin\n          @where :x >= 2\n          @transform {:x+:y}\n          sort(_, :z)\n       end\nTable with 2 rows, 4 columns:\nx  y  z    x + y\n────────────────\n2  5  0.2  7\n2  7  0.4  9\n\njulia> @apply t :x flatten=true begin\n          @transform {w = :y + 1}\n          sort(_, :w)\n       end\nTable with 4 rows, 4 columns:\nx  y  z    w\n────────────\n1  4  0.1  5\n1  6  0.3  7\n2  5  0.2  6\n2  7  0.4  8\n\n\n\n\n\n"
},

{
    "location": "pipeline_macros/#JuliaDBMeta.@applychunked",
    "page": "Pipeline macros",
    "title": "JuliaDBMeta.@applychunked",
    "category": "macro",
    "text": "@applychunked(args...)\n\nSplit the table into chunks, apply the processing pipeline separately to each chunk and return the result as a distributed table.\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z], chunks = 2);\n\njulia> @applychunked t begin\n          @where :x >= 2\n          @transform {:x+:y}\n          sort(_, :z)\n       end\nDistributed Table with 2 rows in 2 chunks:\nx  y  z    x + y\n────────────────\n2  5  0.2  7\n2  7  0.4  9\n\n\n\n\n\n"
},

{
    "location": "pipeline_macros/#Pipeline-macros-1",
    "page": "Pipeline macros",
    "title": "Pipeline macros",
    "category": "section",
    "text": "All macros have a currified version, so they can be easily concatenated using |>. For example:julia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);\n\njulia> t |> @where(:x >= 2) |> @transform({:x+:y})\nTable with 2 rows, 4 columns:\nx  y  z    x + y\n────────────────\n2  5  0.2  7\n2  7  0.4  9To avoid the parenthesis and to use the _ curryfication syntax, you can use the @apply macro instead:@applyUse @applychunked to apply your pipeline independently on different processors:@applychunked"
},

{
    "location": "grouping/#",
    "page": "Grouping operations",
    "title": "Grouping operations",
    "category": "page",
    "text": ""
},

{
    "location": "grouping/#Grouping-operations-1",
    "page": "Grouping operations",
    "title": "Grouping operations",
    "category": "section",
    "text": "Three approaches are possible for grouping."
},

{
    "location": "grouping/#JuliaDBMeta.@groupby",
    "page": "Grouping operations",
    "title": "JuliaDBMeta.@groupby",
    "category": "macro",
    "text": "@groupby(d, by, x)\n\nGroup data and apply some summary function to it. Symbols in expression x are replaced by the respective column in d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a).\n\nThe second argument is optional (defaults to Keys()) and specifies on which column(s) to group. The key column(s) can be accessed with _.key. Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);\n\njulia> @groupby t :x {maximum(:y - :z)}\nTable with 2 rows, 2 columns:\nx  maximum(y - z)\n─────────────────\n1  5.7\n2  6.6\n\njulia> @groupby t :x {m = maximum(:y - :z)/_.key.x}\nTable with 2 rows, 2 columns:\nx  m\n──────\n1  5.7\n2  3.3\n\nWhen the summary function returns an iterable, use flatten=true to flatten the result:\n\njulia> @groupby(t, :x, flatten = true, select = {:y+1})\nTable with 4 rows, 2 columns:\nx  y + 1\n────────\n1  5\n1  7\n2  6\n2  8\n\n\n\n\n\n"
},

{
    "location": "grouping/#Groupby-1",
    "page": "Grouping operations",
    "title": "Groupby",
    "category": "section",
    "text": "@groupby"
},

{
    "location": "grouping/#Column-wise-macros-with-grouping-argument-1",
    "page": "Grouping operations",
    "title": "Column-wise macros with grouping argument",
    "category": "section",
    "text": "Column-wise macros accept an optional grouping argument:iris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"))\n@where_vec iris :Species :SepalLength .> mean(:SepalLength)Use flatten=true to flatten the result:@where_vec iris :Species flatten=true :SepalLength .> mean(:SepalLength)"
},

{
    "location": "grouping/#Pipeline-with-grouping-argument-1",
    "page": "Grouping operations",
    "title": "Pipeline with grouping argument",
    "category": "section",
    "text": "@apply also accepts an optional grouping argument:@apply iris :Species flatten = true begin\n   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}\n   sort(_, :SepalWidth, rev = true)\n   _[1:3]\nend"
},

{
    "location": "out_of_core/#",
    "page": "Out-of-core support",
    "title": "Out-of-core support",
    "category": "page",
    "text": ""
},

{
    "location": "out_of_core/#Out-of-core-support-1",
    "page": "Out-of-core support",
    "title": "Out-of-core support",
    "category": "section",
    "text": "JuliaDBMeta supports out-of-core operations in several different ways. In the following examples, we will have started the REPL with julia -p 4"
},

{
    "location": "out_of_core/#Row-wise-macros-parallelize-out-of-the-box-1",
    "page": "Out-of-core support",
    "title": "Row-wise macros parallelize out of the box",
    "category": "section",
    "text": "Row-wise macros can be trivially implemented in parallel and will work out of the box with out-of-core tables.julia> iris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"));\n\njulia> iris5 = table(iris, chunks = 5);\n\njulia> @where iris5 :SepalLength == 4.9 && :Species == \"setosa\"\nDistributed Table with 4 rows in 2 chunks:\nSepalLength  SepalWidth  PetalLength  PetalWidth  Species\n──────────────────────────────────────────────────────────\n4.9          3.0         1.4          0.2         \"setosa\"\n4.9          3.1         1.5          0.1         \"setosa\"\n4.9          3.1         1.5          0.2         \"setosa\"\n4.9          3.6         1.4          0.1         \"setosa\""
},

{
    "location": "out_of_core/#Grouping-operations-parallelize-with-some-data-shuffling-1",
    "page": "Out-of-core support",
    "title": "Grouping operations parallelize with some data shuffling",
    "category": "section",
    "text": "Grouping operations will work on out-of-core data tables, but may involve some data shuffling as it requires data belonging to the same group to be on the same processor.julia> @groupby iris5 :Species {mean(:SepalLength)}\nDistributed Table with 3 rows in 3 chunks:\nSpecies       mean(SepalLength)\n───────────────────────────────\n\"setosa\"      5.006\n\"versicolor\"  5.936\n\"virginica\"   6.588"
},

{
    "location": "out_of_core/#Apply-a-pipeline-to-your-data-in-chunks-1",
    "page": "Out-of-core support",
    "title": "Apply a pipeline to your data in chunks",
    "category": "section",
    "text": "@applychunked will apply the analysis pipeline separately to each chunk of data in parallel and collect the result as a distributed table.julia> @applychunked iris5 begin\n           @where :Species == \"setosa\" && :SepalLength == 4.9\n           @transform {Ratio = :SepalLength / :SepalWidth}\n       end\nDistributed Table with 4 rows in 2 chunks:\nSepalLength  SepalWidth  PetalLength  PetalWidth  Species   Ratio\n───────────────────────────────────────────────────────────────────\n4.9          3.0         1.4          0.2         \"setosa\"  1.63333\n4.9          3.1         1.5          0.1         \"setosa\"  1.58065\n4.9          3.1         1.5          0.2         \"setosa\"  1.58065\n4.9          3.6         1.4          0.1         \"setosa\"  1.36111"
},

{
    "location": "out_of_core/#Column-wise-macros-do-not-parallelize-yet-1",
    "page": "Out-of-core support",
    "title": "Column-wise macros do not parallelize yet",
    "category": "section",
    "text": "Column-wise macros do not have a parallel implementation yet, unless when grouping: they require working on the whole column at the same time which makes it difficult to parallelize them."
},

{
    "location": "plotting/#",
    "page": "Plotting",
    "title": "Plotting",
    "category": "page",
    "text": ""
},

{
    "location": "plotting/#Plotting-1",
    "page": "Plotting",
    "title": "Plotting",
    "category": "section",
    "text": "Plotting is supported via the @df macro from StatPlots and can be easily integrated in an @apply call.using StatPlots\niris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"));\n@apply iris begin\n    @where :SepalLength > 4\n    @transform {ratio = :PetalLength / :PetalWidth}\n    @df scatter(:PetalLength, :ratio, group = :Species)\nend(Image: iris)Plotting grouped data can also be achieved by:plt = plot()\n\n@apply iris :Species begin\n    @where :SepalLength > 4\n    @transform {ratio = :PetalLength / :PetalWidth}\n    @df scatter!(:PetalLength, :ratio)\nend\n\ndisplay(plt)"
},

{
    "location": "tutorial/#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "tutorial/#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": "Flights tutorial with JuliaDBMeta."
},

{
    "location": "tutorial/#Getting-the-data-1",
    "page": "Tutorial",
    "title": "Getting the data",
    "category": "section",
    "text": "The data is some example flight dataset that you can find here. Simply open the link and choose Save as from the File menu in your browser to save the data to a folder on your computer."
},

{
    "location": "tutorial/#Loading-the-data-1",
    "page": "Tutorial",
    "title": "Loading the data",
    "category": "section",
    "text": "Loading a csv file is straightforward with JuliaDB:using JuliaDBMeta\nflights = loadtable(\"/home/pietro/Documents/testdata/hflights.csv\");Of course, replace the path with the location of the dataset you have just downloaded."
},

{
    "location": "tutorial/#Filtering-the-data-1",
    "page": "Tutorial",
    "title": "Filtering the data",
    "category": "section",
    "text": "In order to select only rows matching certain criteria, use the where macro:@where flights :Month == 1 && :DayofMonth == 1;To test if one of two conditions is verified:@where flights :UniqueCarrier == \"AA\" || :UniqueCarrier == \"UA\";\n\n# in this case, you can simply test whether the `UniqueCarrier` is in a given list:\n\n@where flights :UniqueCarrier in [\"AA\", \"UA\"];"
},

{
    "location": "tutorial/#Applying-several-operations-1",
    "page": "Tutorial",
    "title": "Applying several operations",
    "category": "section",
    "text": "If one wants to apply several operations one after the other, there are two main approaches:nesting\npipingLet\'s assume we want to select UniqueCarrier and DepDelay columns and filter for delays over 60 minutes. The nesting approach would be:@where select(flights, (:UniqueCarrier, :DepDelay)) !ismissing(:DepDelay) && :DepDelay > 60Table with 10242 rows, 2 columns:\nUniqueCarrier  DepDelay\n───────────────────────\n\"AA\"           90\n\"AA\"           67\n\"AA\"           74\n\"AA\"           125\n\"AA\"           82\n\"AA\"           99\n\"AA\"           70\n\"AA\"           61\n\"AA\"           74\n\"AS\"           73\n\"B6\"           136\n\"B6\"           68\n⋮\n\"WN\"           129\n\"WN\"           61\n\"WN\"           70\n\"WN\"           76\n\"WN\"           63\n\"WN\"           144\n\"WN\"           117\n\"WN\"           124\n\"WN\"           72\n\"WN\"           70\n\"WN\"           78Piping:select(flights, (:UniqueCarrier, :DepDelay)) |> @where !ismissing(:DepDelay) && :DepDelay > 60where the variable x denotes our data at each stage. At the beginning it is flights, then it only has the two relevant columns and, at the last step, it is filtered.To avoid the parenthesis and to use the _ curryfication syntax, you can use the @apply macro instead:@apply flights begin\n    select(_, (:UniqueCarrier, :DepDelay))\n    @where !ismissing(:DepDelay) && :DepDelay > 60\nend"
},

{
    "location": "tutorial/#Apply-a-function-row-by-row-1",
    "page": "Tutorial",
    "title": "Apply a function row by row",
    "category": "section",
    "text": "To apply a function row by row, use @map: the first argument is the dataset, the second is the expression you want to compute (symbols are columns):speed = @map flights :Distance / :AirTime * 60227496-element DataValues.DataValueArray{Float64,1}:\n 336.0  \n 298.667\n 280.0  \n 344.615\n 305.455\n 298.667\n 312.558\n 336.0  \n 327.805\n 298.667\n 320.0  \n 327.805\n 305.455\n ⋮      \n 261.818\n 508.889\n 473.793\n 479.302\n 496.627\n 468.6  \n 478.163\n 483.093\n 498.511\n 445.574\n 424.688\n 460.678"
},

{
    "location": "tutorial/#Add-new-variables-1",
    "page": "Tutorial",
    "title": "Add new variables",
    "category": "section",
    "text": "Use the @transform function to add a column to an existing dataset:@transform flights {Speed = :Distance / :AirTime * 60}"
},

{
    "location": "tutorial/#Reduce-variables-to-values-1",
    "page": "Tutorial",
    "title": "Reduce variables to values",
    "category": "section",
    "text": "To get the average delay, we first filter away datapoints where ArrDelay is missing, then group by :Dest, select :ArrDelay and compute the mean:using Statistics\n@groupby flights :Dest {mean(skipmissing(:ArrDelay))}Table with 116 rows, 2 columns:\nDest   mean(dropna(ArrDelay))\n─────────────────────────────\n\"ABQ\"  7.22626\n\"AEX\"  5.83944\n\"AGS\"  4.0\n\"AMA\"  6.8401\n\"ANC\"  26.0806\n\"ASE\"  6.79464\n\"ATL\"  8.23325\n\"AUS\"  7.44872\n\"AVL\"  9.97399\n\"BFL\"  -13.1988\n\"BHM\"  8.69583\n\"BKG\"  -16.2336\n⋮\n\"SJU\"  11.5464\n\"SLC\"  1.10485\n\"SMF\"  4.66271\n\"SNA\"  0.35801\n\"STL\"  7.45488\n\"TPA\"  4.88038\n\"TUL\"  6.35171\n\"TUS\"  7.80168\n\"TYS\"  11.3659\n\"VPS\"  12.4572\n\"XNA\"  6.89628"
},

{
    "location": "tutorial/#Performance-tip-1",
    "page": "Tutorial",
    "title": "Performance tip",
    "category": "section",
    "text": "If you\'ll group often by the same variable, you can sort your data by that variable at once to optimize future computations.sortedflights = reindex(flights, :Dest)using BenchmarkTools\n\nprintln(\"Presorted timing:\")\n@benchmark @groupby sortedflights {mean(skipmissing(:ArrDelay))}Presorted timing:\n\nBenchmarkTools.Trial:\n  memory estimate:  24.77 MiB\n  allocs estimate:  1364979\n  --------------\n  minimum time:     34.392 ms (4.74% GC)\n  median time:      36.882 ms (4.72% GC)\n  mean time:        37.042 ms (5.33% GC)\n  maximum time:     41.001 ms (9.15% GC)\n  --------------\n  samples:          136\n  evals/sample:     1println(\"Non presorted timing:\")\n@benchmark @groupby flights :Dest {mean(skipmissing(:ArrDelay))}Non presorted timing:\n\nBenchmarkTools.Trial:\n  memory estimate:  19.37 MiB\n  allocs estimate:  782824\n  --------------\n  minimum time:     139.882 ms (1.21% GC)\n  median time:      145.401 ms (1.17% GC)\n  mean time:        147.250 ms (1.06% GC)\n  maximum time:     170.298 ms (1.23% GC)\n  --------------\n  samples:          34\n  evals/sample:     1Using summarize, we can summarize several columns at the same time:For each day of the month, count the total number of flights and sort in descending order:@apply flights begin\n    @groupby :DayofMonth {length = length(_)}\n    sort(_, :length, rev = true)\nendTable with 31 rows, 2 columns:\nDayofMonth  length\n──────────────────\n28          7777\n27          7717\n21          7698\n14          7694\n7           7621\n18          7613\n6           7606\n20          7599\n11          7578\n13          7546\n10          7541\n17          7537\n⋮\n25          7406\n16          7389\n8           7366\n12          7301\n4           7297\n19          7295\n24          7234\n5           7223\n30          6728\n29          6697\n31          4339For each destination, count the total number of flights and the number of distinct planes that flew there@groupby flights :Dest {length(:TailNum), length(unique(:TailNum))}Table with 116 rows, 3 columns:\nDest   length(TailNum)  length(unique(TailNum))\n───────────────────────────────────────────────\n\"ABQ\"  2812             716\n\"AEX\"  724              215\n\"AGS\"  1                1\n\"AMA\"  1297             158\n\"ANC\"  125              38\n\"ASE\"  125              60\n\"ATL\"  7886             983\n\"AUS\"  5022             1015\n\"AVL\"  350              142\n\"BFL\"  504              70\n\"BHM\"  2736             616\n\"BKG\"  110              63\n⋮\n\"SJU\"  391              115\n\"SLC\"  2033             368\n\"SMF\"  1014             184\n\"SNA\"  1661             67\n\"STL\"  2509             788\n\"TPA\"  3085             697\n\"TUL\"  2924             771\n\"TUS\"  1565             226\n\"TYS\"  1210             227\n\"VPS\"  880              224\n\"XNA\"  1172             177"
},

{
    "location": "tutorial/#Window-functions-1",
    "page": "Tutorial",
    "title": "Window functions",
    "category": "section",
    "text": "In the previous section, we always applied functions that reduced a table or vector to a single value. Window functions instead take a vector and return a vector of the same length, and can also be used to manipulate data. For example we can rank, within each UniqueCarrier, how much delay a given flight had and figure out the day and month with the two greatest delays:using StatsBase\n@apply flights :UniqueCarrier flatten = true begin\n    # Exclude flights with missing DepDelay\n    @where !ismissing(:DepDelay)\n    # Select only those whose rank is less than 2\n    @where_vec ordinalrank(:DepDelay, rev = true) .<= 2\n    # Select appropriate fields\n    @map {:Month, :DayofMonth, :DepDelay}    \n    # sort\n    sort(_, :DepDelay, rev = true)\nendTable with 30 rows, 4 columns:\nUniqueCarrier  Month  DayofMonth  DepDelay\n──────────────────────────────────────────\n\"AA\"           12     12          970\n\"AA\"           11     19          677\n\"AS\"           2      28          172\n\"AS\"           7      6           138\n\"B6\"           10     29          310\n\"B6\"           8      19          283\n\"CO\"           8      1           981\n\"CO\"           1      20          780\n\"DL\"           10     25          730\n\"DL\"           4      5           497\n\"EV\"           6      25          479\n\"EV\"           1      5           465\n⋮\n\"OO\"           4      4           343\n\"UA\"           6      21          869\n\"UA\"           9      18          588\n\"US\"           4      19          425\n\"US\"           8      26          277\n\"WN\"           4      8           548\n\"WN\"           9      29          503\n\"XE\"           12     29          628\n\"XE\"           12     29          511\n\"YV\"           4      22          54\n\"YV\"           4      30          46Though in this case, it would have been simpler to use Julia partial sorting:@apply flights :UniqueCarrier flatten = true begin\n    # Exclude flights with missing DepDelay\n    @where !ismissing(:DepDelay)\n    # Select appropriate fields\n    @map {:Month, :DayofMonth, :DepDelay}\n    # select\n    @where_vec partialsortperm(:DepDelay, 1:2, rev = true)\nend;For each month, calculate the number of flights and the change from the previous monthusing ShiftedArrays\n@apply flights begin\n    @groupby :Month {length = length(_)}\n    @transform_vec {change = :length .- lag(:length)}\nendTable with 12 rows, 3 columns:\nMonth  length  change\n──────────────────────\n1      18910   missing\n2      17128   -1782\n3      19470   2342\n4      18593   -877\n5      19172   579\n6      19600   428\n7      20548   948\n8      20176   -372\n9      18065   -2111\n10     18696   631\n11     18021   -675\n12     19117   1096You can also use a different default value with ShiftedArrays (for example, with an Array of Float64 you could do:v = [1.2, 2.3, 3.4]\nlag(v, default = NaN)"
},

{
    "location": "tutorial/#Visualizing-your-data-1",
    "page": "Tutorial",
    "title": "Visualizing your data",
    "category": "section",
    "text": "The StatPlots package as well as native plotting recipes from JuliaDB using OnlineStats make a rich set of visualizations possible with an intuitive syntax.Use the @df macro to be able to refer to columns simply by their name. You can work with these symobls as if they are regular vectors. Here for example, we color according to the departure delay renormalized by its maximum.using StatPlots\n@apply flights begin\n    @transform {Far = :Distance > 1000}\n    @groupby (:Month, :Far) {MeanDep = mean(skipmissing(:DepDelay)), MeanArr = mean(skipmissing(:ArrDelay))}\n    @df scatter(:MeanDep, :MeanArr, group = {:Far}, layout = 2, zcolor = :MeanDep ./maximum(:MeanDep), legend = :topleft)\nend(Image: output_42_0)For large datasets, summary statistics can be computed using efficient online algorithms implemnted in OnlineStats. Here for example we compute the extrema of the travelled distance for each section of the dataset. Using the by keyword we can run the analysis separately according to a splitting variable, here we\'ll be splitting by month. As with @df, we can run this plot at the end of our pipeline.using OnlineStats\n@apply flights begin\n    @where 500 < :Distance < 2000\n    partitionplot(_, :Distance, stat = Extrema(), by = :Month, layout = 12, legend = false, xticks = [])\nend(Image: output_44_0)"
},

]}
