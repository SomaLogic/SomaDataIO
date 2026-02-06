# Helpers to Extract Information from an ADAT

Retrieve elements of the `HEADER` attribute of a `soma_adat` object:

`getAdatVersion()` determines the the ADAT version number from a parsed
ADAT header.

`getSomaScanVersion()` determines the original SomaScan assay version
that generated RFU measurements within a `soma_adat` object.

`checkSomaScanVersion()` determines if the version of is a recognized
version of SomaScan.

Table of SomaScan assay versions:

|             |                     |          |
|-------------|---------------------|----------|
| **Version** | **Commercial Name** | **Size** |
| `V4`        | 5k                  | 5284     |
| `v4.1`      | 7k                  | 7596     |
| `v5.0`      | 11k                 | 11083    |

`getSignalSpace()` determines the current signal space of the RFU
values, which may differ from the original SomaScan signal space if the
data have been lifted. See
[`lift_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md)
and `vignette("lifting-and-bridging", package = "SomaDataIO")`.

`getSomaScanLiftCCC()` accesses the lifting Concordance Correlation
Coefficients between various SomaScan versions. For more about CCC
metrics see
[`lift_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md).

## Usage

``` r
getAdatVersion(x)

getSomaScanVersion(adat)

getSignalSpace(adat)

checkSomaScanVersion(ver)

getSomaScanLiftCCC(matrix = c("plasma", "serum"))
```

## Arguments

- x:

  Either a `soma_adat` object with intact attributes or the attributes
  themselves of a `soma_adat` object.

- adat:

  A `soma_adat` object (with intact attributes), typically created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- ver:

  `character(1)`. The SomaScan version as a string. **Note:** the
  `"v"`-prefix is case *in*sensitive.

- matrix:

  Character. A string of (usually) either `"serum"` or `"plasma"`.

## Value

- `getAdatVersion()`:

  The key-value of the `Version` as a string.

- `getSomaScanVersion()`:

  The key-value of the `AssayVersion` as a string.

- `getSignalSpace()`:

  The key-value of the `SignalSpace` as a string.

- `checkSomaScanVersion()`:

  Returns `NULL` (invisibly) if checks pass.

- `getSomaScanLiftCCC()`:

  Returns a tibble of either the `serum` or `plasma` CCC between various
  versions of the SomaScan assay.

## References

Lin, Lawrence I-Kuei. 1989. A Concordance Correlation Coefficient to
Evaluate Reproducibility. **Biometrics**. 45:255-268.

## Author

Stu Field

## Examples

``` r
getAdatVersion(example_data)
#> [1] "1.2"

attr(example_data, "Header.Meta")$HEADER$Version <- "99.9"
getAdatVersion(example_data)
#> [1] "99.9"

ver <- getSomaScanVersion(example_data)
ver
#> [1] "V4"

rfu_space <- getSignalSpace(example_data)
rfu_space
#> [1] "V4"

is.null(checkSomaScanVersion(ver))
#> [1] TRUE

# plasma (default)
getSomaScanLiftCCC()
#> # A tibble: 11,083 × 4
#>    SeqId  plasma_11k_to_5k_ccc plasma_11k_to_7k_ccc plasma_7k_to_5k_ccc
#>    <chr>                 <dbl>                <dbl>               <dbl>
#>  1 10000…                0.966                0.982               0.963
#>  2 10001…                0.86                 0.961               0.875
#>  3 10003…                0.674                0.787               0.668
#>  4 10006…                0.864                0.927               0.877
#>  5 10008…                0.879                0.939               0.908
#>  6 10010…               NA                    0.915              NA    
#>  7 10011…                0.642                0.784               0.743
#>  8 10012…                0.528                0.661               0.591
#>  9 10013…                0.76                 0.824               0.744
#> 10 10014…                0.934                0.971               0.941
#> # ℹ 11,073 more rows

# serum
getSomaScanLiftCCC("serum")
#> # A tibble: 11,083 × 4
#>    SeqId    serum_11k_to_5k_ccc serum_11k_to_7k_ccc serum_7k_to_5k_ccc
#>    <chr>                  <dbl>               <dbl>              <dbl>
#>  1 10000-28               0.97                0.977              0.967
#>  2 10001-7                0.819               0.857              0.875
#>  3 10003-15               0.761               0.759              0.774
#>  4 10006-25               0.903               0.937              0.937
#>  5 10008-43               0.915               0.951              0.925
#>  6 10010-10              NA                   0.895             NA    
#>  7 10011-65               0.515               0.748              0.741
#>  8 10012-5                0.57                0.717              0.716
#>  9 10013-34               0.716               0.86               0.778
#> 10 10014-31               0.906               0.951              0.913
#> # ℹ 11,073 more rows
```
