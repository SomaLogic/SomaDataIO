# Scale Transform `soma_adat` Columns/Rows

Scale the *i-th* row or column of a `soma_adat` object by the *i-th*
element of a vector. Designed to facilitate linear transformations of
*only* the analyte/RFU entries by scaling the data matrix. If scaling
the analytes/RFU (columns), `v` *must* have
`getAnalytes(adat, n = TRUE)` elements. If scaling the samples (rows),
`v` *must* have `nrow(_data)` elements.

## Usage

``` r
# S3 method for class 'soma_adat'
transform(`_data`, v, dim = 2L, ...)
```

## Arguments

- \_data:

  A `soma_adat` object.

- v:

  A numeric vector of the appropriate length corresponding to `dim`.

- dim:

  Integer. The dimension to apply elements of `v` to. `1` = rows; `2` =
  columns (default).

- ...:

  Currently not used but required by the S3 generic.

## Value

A modified value of `_data` with either the rows or columns linearly
transformed by `v`.

## Details

Performs the following operations (quickly):

Columns: \$\$ M\_{nxp} = A\_{nxp} \* diag(v)\_{pxp} \$\$

Rows: \$\$ M\_{nxp} = diag(v)\_{nxn} \* A\_{nxp} \$\$

## Note

This method in intentionally naive, and assumes the user has ordered `v`
to match the columns/rows of `_data` appropriately. This must be done
upstream.

## See also

[`apply()`](https://rdrr.io/r/base/apply.html),
[`sweep()`](https://rdrr.io/r/base/sweep.html)

## Examples

``` r
# simplified example of underlying operations
M <- matrix(1:12, ncol = 4)
M
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    4    7   10
#> [2,]    2    5    8   11
#> [3,]    3    6    9   12

v <- 1:4
M %*% diag(v)    # transform columns
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    8   21   40
#> [2,]    2   10   24   44
#> [3,]    3   12   27   48

v <- 1:3
diag(v) %*% M    # transform rows
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    4    7   10
#> [2,]    4   10   16   22
#> [3,]    9   18   27   36

# dummy ADAT example:
v    <- c(2, 0.5)     # double seq1; half seq2
adat <- data.frame(sample      = paste0("sample_", 1:3),
                   seq.1234.56 = c(1, 2, 3),
                   seq.9999.88 = c(4, 5, 6) * 10)
adat
#>     sample seq.1234.56 seq.9999.88
#> 1 sample_1           1          40
#> 2 sample_2           2          50
#> 3 sample_3           3          60

# `soma_adat` to invoke S3 method dispatch
class(adat) <- c("soma_adat", "data.frame")
trans <- transform(adat, v)
data.frame(trans)
#>     sample seq.1234.56 seq.9999.88
#> 1 sample_1           2          20
#> 2 sample_2           4          25
#> 3 sample_3           6          30
```
