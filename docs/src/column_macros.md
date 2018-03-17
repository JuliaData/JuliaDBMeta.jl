# Column-wise macros

Column-wise macros allow using symbols instead of columns. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a `begin ... end` block). If the table is omitted, the macro is automatically curried (useful for piping).

Shared features across all row-wise macros:

 - Symbols refer to fields of the row.
 - `_` refers to the whole table.
 - To use actual symbols, escape them with `^`, as in `^(:a)`.
 - Use `cols(c)` to refer to field c where `c` is a variable that evaluates to a symbol. `c` must be available in the scope where the macro is called.
 - An optional grouping argument is allowed: see [Column-wise macros with grouping argument](@ref)
 - Out-of-core tables are not supported out of the box, except when grouping

## Replace symbols with columns

```@docs
@with
```

## Add or modify a column

```@docs
@transform_vec
```

## Select data

```@docs
@where_vec
```
