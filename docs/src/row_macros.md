# Row-wise macros

Row-wise macros allow using symbols to refer to fields of a row. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a `begin ... end` block). If the table is omitted, the macro is automatically curried (useful for piping).

## Modify data in place

```@docs
@byrow!
```

## Apply a function

```@docs
@map
```

## Add or modify a column

```@docs
@transform
```

## Select data

```@docs
@where
```
