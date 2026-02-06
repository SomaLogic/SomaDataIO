# Convert to Long Format

Utility to convert an `ExpressionSet` class object from the "wide" data
format to the "long" format via
[`tidyr::pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html).
The Biobase package is required for this function.

## Usage

``` r
pivotExpressionSet(eSet)

meltExpressionSet(eSet)
```

## Arguments

- eSet:

  An `ExpressionSet` class object, created using
  [`adat2eSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat2eSet.md).

## Value

A `tibble` consisting of the long format conversion of an
`ExpressionSet` object.

## Functions

- `meltExpressionSet()`: **\[superseded\]**. Please now use
  `pivotExpressionSet()`.

## See also

Other eSet:
[`adat2eSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat2eSet.md)

## Author

Stu Field

## Examples

``` r
# subset into a reduced mini-ADAT object
# 10 samples (rows)
# 5 clinical variables and 3 features (cols)
sub_adat <- example_data[1:10, c(1:5, 35:37)]
ex_set   <- adat2eSet(sub_adat)

# convert ExpressionSet object to long format
adat_long <- pivotExpressionSet(ex_set)
```
