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
    "text": ""
},

{
    "location": "column_macros.html#",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "column_macros.html#JuliaDBMeta.@with",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@with",
    "category": "macro",
    "text": "@with(d, x)\n\nReplace all symbols in expression x with the respective column in d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @with t mean(:a)\n2.0\n\njulia> @with t mean(:a)*length(_)\n6.0\n\njulia> @with t join(:b)\n\"xyz\"\n\njulia> @with t @show ^(:a) != :a\n:a != getfield(JuliaDBMeta.columns(t), :a) = true\ntrue\n\n\n\n"
},

{
    "location": "column_macros.html#JuliaDBMeta.@transform_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@transform_vec",
    "category": "macro",
    "text": "@transform_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  a NamedTuple of vectors or a table and is horizontally merged with d. In this context, _ refers to the whole table d. To use actual symbols, escape them with ^, as in ^(:a). Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform_vec t {:a .+ 1}\nTable with 3 rows, 3 columns:\na  b    a .+ 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n"
},

{
    "location": "column_macros.html#JuliaDBMeta.@where_vec",
    "page": "Column-wise macros",
    "title": "JuliaDBMeta.@where_vec",
    "category": "macro",
    "text": "@where_vec(d, x)\n\nReplace all symbols in expression x with the respective column in d: the result has to be  an Array of booleans which is used to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). The result has to be a NamedTuple of vectors or a table and is horizontally merged with d. Use {} syntax for automatically named NamedTuples. Use cols(c) to refer to column c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where_vec t (:a .>= mean(:a)) .& (:b .!= \"y\")\nTable with 1 rows, 2 columns:\na  b\n──────\n3  \"z\"\n\n\n\n"
},

{
    "location": "column_macros.html#Column-wise-macros-1",
    "page": "Column-wise macros",
    "title": "Column-wise macros",
    "category": "section",
    "text": "@with@transform_vec@where_vec"
},

{
    "location": "row_macros.html#",
    "page": "Row-wise macros",
    "title": "Row-wise macros",
    "category": "page",
    "text": ""
},

{
    "location": "row_macros.html#JuliaDBMeta.@map",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@map",
    "category": "macro",
    "text": "@map(d, x)\n\nApply the expression x row by row in d: return the result as an array or as a table (if the elements are Tuples or NamedTuples). Use {} syntax for automatically named NamedTuples. Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @map t :b*string(:a)\n3-element Array{String,1}:\n \"x1\"\n \"y2\"\n \"z3\"\n\njulia> @map t {:a, copy = :a, :b}\nTable with 3 rows, 3 columns:\na  copy  b\n────────────\n1  1     \"x\"\n2  2     \"y\"\n3  3     \"z\"\n\n\n\n"
},

{
    "location": "row_macros.html#JuliaDBMeta.@byrow!",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@byrow!",
    "category": "macro",
    "text": "@byrow!(d, x)\n\nApply the expression x row by row in d (to modify d in place). Symbols refer to fields of the row. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a). Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @byrow! t :b = :b*string(:a)\nTable with 3 rows, 2 columns:\na  b\n───────\n1  \"x1\"\n2  \"y2\"\n3  \"z3\"\n\n\n\n"
},

{
    "location": "row_macros.html#JuliaDBMeta.@transform",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@transform",
    "category": "macro",
    "text": "@transform(d, x)\n\nApply the expression x row by row in d: collect the result as a table (elements returned by x must be NamedTuples) and merge it horizontally with d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @transform t {:a + 1}\nTable with 3 rows, 3 columns:\na  b    a + 1\n──────────────\n1  \"x\"  2\n2  \"y\"  3\n3  \"z\"  4\n\n\n\n"
},

{
    "location": "row_macros.html#JuliaDBMeta.@where",
    "page": "Row-wise macros",
    "title": "JuliaDBMeta.@where",
    "category": "macro",
    "text": "@where(d, x)\n\nApply the expression x row by row in d: collect the result as an Array (elements returned by x must be booleans) and use it to get a view of d. In this context, _ refers to the whole row. To use actual symbols, escape them with ^, as in ^(:a).\n\nUse {} syntax for automatically named NamedTuples. Use cols(c) to refer to field c where c is a variable that evaluates to a symbol. c must be available in the scope where the macro is called.\n\nExamples\n\njulia> t = table(@NT(a = [1,2,3], b = [\"x\",\"y\",\"z\"]));\n\njulia> @where t :a <= 2\nTable with 2 rows, 2 columns:\na  b\n──────\n1  \"x\"\n2  \"y\"\n\n\n\n"
},

{
    "location": "row_macros.html#Column-wise-macros-1",
    "page": "Row-wise macros",
    "title": "Column-wise macros",
    "category": "section",
    "text": "@map@byrow!@transform@where"
},

]}
