# Column-wise macros

Column-wise macros allow using symbols instead of columns. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a `begin ... end` block). If the table is omitted, the macro is automatically curried (useful for piping).

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
