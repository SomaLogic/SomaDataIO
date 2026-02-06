# Get Flagged Ids From MAD Outlier Map

Return the IDs of flagged samples for objects of the `outlier_map`
class. Samples are flagged based on the percent analytes (RFU columns)
for a given sample that were identified as outliers using the median
absolute deviation (MAD).

## Usage

``` r
getOutlierIds(x, flags = 0.05, data = NULL, include = NULL)
```

## Arguments

- x:

  An object of class:

  - `outlier_map` - from
    [`calcOutlierMap()`](https://somalogic.github.io/SomaDataIO/dev/reference/calcOutlierMap.md)

- flags:

  Numeric in `[0, 1]`. For an `"outlier_map"`, the proportion of the
  analytes (columns) for a given sample that must be outliers for a flag
  to be placed at the right-axis, right-axis, thus flagging that sample.
  If `NULL` (default), `0.05` (5%) is selected.

- data:

  Optional. The data originally used to create the map `x`. If omitted,
  a single column data frame is returned.

- include:

  Optional. Character vector of column name(s) in `data` to include in
  the resulting data frame. Ignored if `data = NULL`.

## Value

A `data.frame` of the indices (`idx`) of flagged samples, along with any
additional variables as specified by `include`.

## See also

Other Calc Map:
[`calcOutlierMap()`](https://somalogic.github.io/SomaDataIO/dev/reference/calcOutlierMap.md),
[`plot.Map()`](https://somalogic.github.io/SomaDataIO/dev/reference/plot.Map.md)

## Author

Caleb Scheidel

## Examples

``` r
# flagged outliers
# create a single sample outlier (12)
out_adat <- example_data
apts     <- getAnalytes(out_adat)
out_adat[12, apts] <- out_adat[12, apts] * 10

om <- calcOutlierMap(out_adat)
getOutlierIds(om, out_adat, flags = 0.05, include = c("Sex", "Subarray"))
#>   idx  Sex Subarray
#> 1  12    M        5
#> 2  13 <NA>        4
#> 3  43 <NA>        8
#> 4  87 <NA>        6
#> 5 143 <NA>        4
#> 6 151 <NA>        4
#> 7 173 <NA>        4
```
