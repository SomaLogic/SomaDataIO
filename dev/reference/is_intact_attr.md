# Are Attributes Intact?

This function runs a series of checks to determine if a `soma_adat`
object has a complete set of attributes. If not, this indicates that the
object has been modified since the initial
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
call. Checks for the presence of both "Header.Meta" and "Col.Meta" in
the attribute names. These entries are added during the
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
call. Specifically, within these sections it also checks for the
presence of the following entries:

- "Header.Meta" section::

  "HEADER", "COL_DATA", and "ROW_DATA"

- "Col.Meta" section::

  "SeqId", "Target", "Units", and "Dilution"

If any of the above they are altered or missing, `FALSE` is returned.

`is.intact.attributes()` is **\[superseded\]**. It remains for backward
compatibility and may be removed in the future. You are encouraged to
shift your code to `is_intact_attr()`.

## Usage

``` r
is_intact_attr(adat, verbose = interactive())

is.intact.attributes(adat, verbose = interactive())
```

## Arguments

- adat:

  A `soma_adat` object to query.

- verbose:

  Logical. Should diagnostic information about failures be printed to
  the console? If the default, see
  [`interactive()`](https://rdrr.io/r/base/interactive.html), is
  invoked, only messages via direct calls are triggered. This prohibits
  messages generated deep in the call stack from bubbling up to the
  user.

## Value

Logical. `TRUE` if all checks pass, otherwise `FALSE`.

## See also

[`attributes()`](https://rdrr.io/r/base/attributes.html)

## Examples

``` r
# checking attributes
my_adat <- example_data
is_intact_attr(my_adat)           # TRUE
#> [1] TRUE
is_intact_attr(my_adat[, -303L])   # doesn't break atts; TRUE
#> [1] TRUE
attributes(my_adat)$Col.Meta$Target <- NULL    # break attributes
is_intact_attr(my_adat)  # FALSE (Target missing)
#> [1] FALSE
```
