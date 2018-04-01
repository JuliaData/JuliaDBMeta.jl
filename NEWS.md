# JuliaDBMeta.jl NEWS

## 0.3 current version

- removed `@applycombine` in favor of `@apply` wiht `flatten=true`
- added `@filter`

### 0.2

- added `cols` to select columns programmatically
- added out-of-core support
- **breaking** `@groupby` no longer flattens by default
