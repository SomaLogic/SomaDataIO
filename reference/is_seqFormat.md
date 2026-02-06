# Test `AptName` Format

Test whether an object is in the new `seq.XXXX.XX` format.

## Usage

``` r
is_seqFormat(x)
```

## Arguments

- x:

  The object to be tested.

## Value

A logical indicating whether `x` contains `AptNames` consistent with the
new format, beginning with a `seq.` prefix.

## Author

Stu Field, Eduardo Tabacman

## Examples

``` r
# character S3 method
is_seqFormat(names(example_data))   # no; meta data not ^seq.
#> [1] FALSE
is_seqFormat(tail(names(example_data), -20L))   # yes
#> [1] FALSE

# soma_adat S3 method
is_seqFormat(example_data)
#> [1] TRUE
```
