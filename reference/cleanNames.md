# Clean Up Character String

Often the names, particularly within `soma_adat` objects, are messy due
to varying inputs, this function attempts to remedy this by removing the
following:

- trailing/leading/internal whitespace

- non-alphanumeric strings (except underscores)

- duplicated internal dots (`..`), (`...`), etc.

- SomaScan normalization scale factor format

## Usage

``` r
cleanNames(x)
```

## Arguments

- x:

  Character. String to clean up.

## Value

A cleaned up character string.

## See also

[`trimws()`](https://rdrr.io/r/base/trimws.html),
[`gsub()`](https://rdrr.io/r/base/grep.html),
[`sub()`](https://rdrr.io/r/base/grep.html)

## Author

Stu Field

## Examples

``` r
cleanNames("    sdkfj...sdlkfj.sdfii4994### ")
#> [1] "sdkfj.sdlkfj.sdfii4994"

cleanNames("Hyb..Scale")
#> [1] "HybControlNormScale"
```
