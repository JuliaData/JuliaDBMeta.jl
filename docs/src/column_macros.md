# Column-wise macros

Column-wise macros allow using symbols instead of columns. The order of the arguments is always the same: the first argument is the table and the last argument is the expression (can be a `begin ... end` block). If the table is omitted, the macro is automatically curried (useful for piping).

The first important macro is `@with`, to simply replace symbols with columns:

```@docs
@with
```

Use `@transform_vec` to transform columns (or add new ones):

```@docs
@transform_vec
```

You can take a view (like filtering, but without copying) with `@where_vec`:

```@docs
@where_vec
```
