var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#JuliaDBMeta.jl-1",
    "page": "Introduction",
    "title": "JuliaDBMeta.jl",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "A set of macros to simplify data manipulation with JuliaDB, heavily inspired on DataFramesMeta. It basically is a port of that package from DataFrames to IndexedTables, exploiting some of the advantages of JuliaDB:Table have full type information, so extracting a column is type stable\nIterating rows is fast\nParallel data storage and parallel computations.Some ideas also come from Query.jl, in particular the curly bracket syntax is from there.The macro packages Lazy and MacroTools were also very useful in designing this package: the @apply macro is inspired by the concatenation macros in Lazy."
},

{
    "location": "index.html#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "To install, simply type the following command in the Julia REPL:Pkg.add(\"JuliaDBMeta\")"
},

{
    "location": "getting_started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started.html#Getting-started-1",
    "page": "Getting Started",
    "title": "Getting started",
    "category": "section",
    "text": "To install the package simply type:Pkg.add(\"JuliaDBMeta\")in a Julia REPL.Let\'s subselect rows with some features. First argument is data and last argument is an expression whose symbols will correspond to the various fields of the data.iris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"))\n@where iris :Species == \"versicolor\" && :SepalLength > 6To combine many operations use @apply:@apply iris begin\n    @where :Species == \"versicolor\" && :SepalLength > 6\n    # add new column Ratio = SepalLength / SepalWidth\n    @transform {Ratio = :SepalLength/:SepalWidth}\n    @where :Ratio > 2\nendPass an optional grouping argument to @apply to also group your data before running the pipeline:@apply iris :Species flatten = true begin\n    # select existing column SepalWidth and new column Ratio = SepalLength / SepalWidth\n   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}\n   # sort by SepalWidth\n   sort(_, :SepalWidth, rev = true)\n   # select first three rows of each group\n   _[1:3]\nend"
},

{
    "location": "row_macros.html#",
    "page": "Row-wise macros",
    "title": "Row-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "row_macros.html#Row-wise-macros-1",
    "page": "Row-wise macros",
    "title": "Row-wise macros",
    "category": "section",
    "text": "Row-wise macros allow using symbols to refer to fields of a row. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a begin ... end block). If the table is omitted, the macro is automatically curried (useful for piping)."
},

{
    "location": "row_macros.html#JuliaDBMeta.@byrow!",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@byrow!",
    "category": "macro",
    "text": "@byrow!(d, x)\n\nApply the expression x row by row in d (to modify d in place). Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @byrow! t :b = :b*string(:a)\nTable with 3 rows, 2 columns:\na  b\n───────\n1  \"x1\"\n2  \"y2\"\n3  \"z3\"\n\njulia> @byrow! t begin\n       :a = :a*2\n       :b = \"x\"^:a\n       end\nTable with 3 rows, 2 columns:\na  b\n───────────\n2  \"xx\"\n4  \"xxxx\"\n6  \"xxxxxx\"\n\n\n\n"
},

{
    "location": "row_macros.html#Modify-data-in-place-1",
    "page": "Row-wise macros",
    "title": "Modify data in place",
    "category": "section",
    "text": "@byrow!"
},

{
    "location": "row_macros.html#JuliaDBMeta.@map",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@map",
    "category": "macro",
    "text": "@map(d, x)\n\nApply the expression x row by row in d: return the result as an array or as a table (if the elements are Tuples or NamedTuples). Use {} syntax for automatically named NamedTuples. Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @map t :b*string(:a)\n3-element Array{String,1}:\n \"x1\"\n \"y2\"\n \"z3\"\n\njulia> @map t {:a, copy = :a, :b}\nTable with 3 rows, 3 columns:\na  copy  b\n────────────\n1  1     \"x\"\n2  2     \"y\"\n3  3     \"z\"\n\n\n\n"
},

{
    "location": "row_macros.html#Apply-a-function-1",
    "page": "Row-wise macros",
    "title": "Apply a function",
    "category": "section",
    "text": "@map"
},

{
    "location": "row_macros.html#JuliaDBMeta.@transform",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@transform",
    "category": "macro",
    "text": "@transform(d, x)\n\nApply the expression x row by row in d: collect the result as a table (elements returned by x must be NamedTuples) and merge it horizontally with d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform t {:a + 1}\nTable with 3 rows, 3 columns:\na  b    a + 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n"
},

{
    "location": "row_macros.html#Add-or-modify-a-column-1",
    "page": "Row-wise macros",
    "title": "Add or modify a column",
    "category": "section",
    "text": "@transform"
},

{
    "location": "row_macros.html#JuliaDBMeta.@where",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@where",
    "category": "macro",
    "text": "@where(d, x)\n\nApply the expression x row by row in d: collect the result as an Array (elements returned by x must be booleans) and use it to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where t :a <= 2\nTable with 2 rows, 2 columns:\na  b\n──────\n1  \"x\"\n2  \"y\"\n\n\n\n"
},

{
    "location": "row_macros.html#Select-data-1",
    "page": "Row-wise macros",
    "title": "Select data",
    "category": "section",
    "text": "@where"
},

{
    "location": "column_macros.html#",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "column_macros.html#Column-wise-macros-1",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "section",
    "text": "Column-wise macros allow using symbols instead of columns. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a begin ... end block). If the table is omitted, the macro is automatically curried (useful for piping)."
},

{
    "location": "column_macros.html#JuliaDBMeta.@with",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@with",
    "category": "macro",
    "text": "@with(d, x)\n\nReplace all symbols in expression x with the respective column in d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @with t mean(:a)\n2.0\n\njulia> @with t mean(:a)*length(_)\n6.0\n\njulia> @with t join(:b)\n\"xyz\"\n\njulia> @with t @show ^(:a) != :a\n:a != getfield(JuliaDBMeta.columns(t), :a) = true\ntrue\n\njulia> c = :a\n:a\n\njulia> @with t cols(c)\n3-element Array{Int64,1}:\n 1\n 2\n 3\n\nNote that you can use this syntax to modify columns in place as well:\n\njulia> @with t :b .= :b .* string.(:a)\n3-element Array{String,1}:\n \"x1\"\n \"y2\"\n \"z3\"\n\njulia> t\nTable with 3 rows, 2 columns:\na  b\n───────\n1  \"x1\"\n2  \"y2\"\n3  \"z3\"\n\n\n\n"
},

{
    "location": "column_macros.html#Replace-symbols-with-columns-1",
    "page": "Column-wise macros",
    "title": "Replace symbols with columns",
    "category": "section",
    "text": "@with"
},

{
    "location": "column_macros.html#JuliaDBMeta.@transform_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@transform_vec",
    "category": "macro",
    "text": "@transform_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  a NamedTuple of vectors or a table and is horizontally merged with d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform_vec t {:a .+ 1}\nTable with 3 rows, 3 columns:\na  b    a .+ 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n"
},

{
    "location": "column_macros.html#Add-or-modify-a-column-1",
    "page": "Column-wise macros",
    "title": "Add or modify a column",
    "category": "section",
    "text": "@transform_vec"
},

{
    "location": "column_macros.html#JuliaDBMeta.@where_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@where_vec",
    "category": "macro",
    "text": "@where_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  an Array of booleans which is used to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). The result has to be a NamedTuple of vectors or a table and is horizontally merged with d. Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where_vec t (:a .>= 2) .& (:b .!= \"y\")\nTable with 1 rows, 2 columns:\na  b\n──────\n3  \"z\"\n\n\n\n"
},

{
    "location": "column_macros.html#Select-data-1",
    "page": "Column-wise macros",
    "title": "Select data",
    "category": "section",
    "text": "@where_vec"
},

{
    "location": "pipeline_macros.html#",
    "page": "Pipeline macros",
    "title": "Pipeline macros",
    "category": "page",
    "text": ""
},

{
    "location": "pipeline_macros.html#JuliaDBMeta.@apply",
    "page": "Pipeline macros",
    "title": "JuliaDBMeta.@apply",
    "category": "macro",
    "text": "@apply(args...)\n\nConcatenate a series of operations. Non-macro operations from JuliaDB, are supported via  the _ curryfication syntax. A second optional argument is used for grouping:\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);\n\njulia> @apply t begin\n          @where :x >= 2\n          @transform {:x+:y}\n          sort(_, :z)\n       end\nTable with 2 rows, 4 columns:\nx  y  z    x + y\n────────────────\n2  5  0.2  7\n2  7  0.4  9\n\njulia> @apply t :x flatten=true begin\n          @transform {w = :y + 1}\n          sort(_, :w)\n       end\nTable with 4 rows, 4 columns:\nx  y  z    w\n────────────\n1  4  0.1  5\n1  6  0.3  7\n2  5  0.2  6\n2  7  0.4  8\n\n\n\n"
},

{
    "location": "pipeline_macros.html#JuliaDBMeta.@applychunked",
    "page": "Pipeline macros",
    "title": "JuliaDBMeta.@applychunked",
    "category": "macro",
    "text": "@applychunked(args...)\n\nSplit the table into chunks, apply the processing pipeline separately to each chunk and return the result as a distributed table.\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z], chunks = 2);\n\njulia> @applychunked t begin\n          @where :x >= 2\n          @transform {:x+:y}\n          sort(_, :z)\n       end\nDistributed Table with 2 rows in 2 chunks:\nx  y  z    x + y\n────────────────\n2  5  0.2  7\n2  7  0.4  9\n\n\n\n"
},

{
    "location": "pipeline_macros.html#Pipeline-macros-1",
    "page": "Pipeline macros",
    "title": "Pipeline macros",
    "category": "section",
    "text": "@apply@applychunked"
},

{
    "location": "grouping.html#",
    "page": "Grouping",
    "title": "Grouping",
    "category": "page",
    "text": ""
},

{
    "location": "grouping.html#Grouping-1",
    "page": "Grouping",
    "title": "Grouping",
    "category": "section",
    "text": "Three approaches are possible for grouping."
},

{
    "location": "grouping.html#JuliaDBMeta.@groupby",
    "page": "Grouping",
    "title": "JuliaDBMeta.@groupby",
    "category": "macro",
    "text": "@groupby(d, by, x)\n\nGroup data and apply some summary function to it. Symbols in expression x are replaced by the respective column in d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a).\n\nThe second argument is optional (defaults to Keys()) and specifies on which column(s) to group. The key column(s) can be accessed with _.key. Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table([1,2,1,2], [4,5,6,7], [0.1, 0.2, 0.3,0.4], names = [:x, :y, :z]);\n\njulia> @groupby t :x {maximum(:y - :z)}\nTable with 2 rows, 2 columns:\nx  maximum(y - z)\n─────────────────\n1  5.7\n2  6.6\n\njulia> @groupby t :x {m = maximum(:y - :z)/_.key.x}\nTable with 2 rows, 2 columns:\nx  m\n──────\n1  5.7\n2  3.3\n\n\n\n"
},

{
    "location": "grouping.html#Groupby-1",
    "page": "Grouping",
    "title": "Groupby",
    "category": "section",
    "text": "@groupby"
},

{
    "location": "grouping.html#Column-wise-macros-with-grouping-argument-1",
    "page": "Grouping",
    "title": "Column-wise macros with grouping argument",
    "category": "section",
    "text": "All column-wise macros accept an optional grouping argumentiris = loadtable(Pkg.dir(\"JuliaDBMeta\", \"test\", \"tables\", \"iris.csv\"))\n@where_vec iris :Species :SepalLength .> mean(:SepalLength)Use flatten=true to flatten the result@where_vec iris :Species flatten=true :SepalLength .> mean(:SepalLength)"
},

{
    "location": "grouping.html#Pipeline-with-grouping-argument-1",
    "page": "Grouping",
    "title": "Pipeline with grouping argument",
    "category": "section",
    "text": "@apply also accepts an optional grouping argument:@apply iris :Species flatten = true begin\n   @map {:SepalWidth, Ratio = :SepalLength / :SepalWidth}\n   sort(_, :SepalWidth, rev = true)\n   _[1:3]\nend"
},

]}
