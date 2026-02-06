# Safely Rename Data Frames

## Introduction

Renaming variables/features of a data frame (or `tibble`) is a common
task in data science. Doing so *safely* is often a struggle. This can be
achieved *safely* via the
[`dplyr::rename()`](https://dplyr.tidyverse.org/reference/rename.html)
function via 2 steps:

1.  Set up the mapping in either a named vector
2.  Apply the
    [`dplyr::rename()`](https://dplyr.tidyverse.org/reference/rename.html)
    function via `!!!` syntax
3.  Alternatively, roll-your-own
    [`rename()`](https://dplyr.tidyverse.org/reference/rename.html)
    function

- **Note**: all entries in the mapping (i.e. key) object *must* be
  present as `names` in the data frame object.

### Example with `mtcars`

``` r
# Create map/key of the names to map
key <- c(MPG = "mpg", CARB = "carb")   # named vector
key
#>    MPG   CARB 
#>  "mpg" "carb"

# rename `mtcars`
rename(mtcars, !!! key) |> head()
#>                    MPG cyl disp  hp drat    wt  qsec vs am gear CARB
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

### A SomaScan example (`example_data`)

Occasionally it might be required to rename `AptNames` (`seq.1234.56`)
-\> `SeqIds` (`1234-56`) when analyzing SomaScan data.

``` r
getAnalytes(example_data) |> 
  head()
#> [1] "seq.10000.28" "seq.10001.7"  "seq.10003.15" "seq.10006.25"
#> [5] "seq.10008.43" "seq.10011.65"

# create map (named vector)
key2 <- getAnalytes(example_data)  
names(key2) <- getSeqId(key2)     # re-name `seq.XXXX` -> SeqIds
key2 <- c(key2, ID = "SampleId")  # SampleId -> ID
head(key2, 10L)
#>        10000-28         10001-7        10003-15        10006-25 
#>  "seq.10000.28"   "seq.10001.7"  "seq.10003.15"  "seq.10006.25" 
#>        10008-43        10011-65         10012-5        10013-34 
#>  "seq.10008.43"  "seq.10011.65"   "seq.10012.5"  "seq.10013.34" 
#>        10014-31       10015-119 
#>  "seq.10014.31" "seq.10015.119"

# rename analytes of `example_data`
getAnalytes(example_data) |>
  head(10L)
#>  [1] "seq.10000.28"  "seq.10001.7"   "seq.10003.15"  "seq.10006.25" 
#>  [5] "seq.10008.43"  "seq.10011.65"  "seq.10012.5"   "seq.10013.34" 
#>  [9] "seq.10014.31"  "seq.10015.119"

new <- rename(example_data, !!! key2)

getAnalytes(new) |>
  head(10L)
#>  [1] "10000-28"  "10001-7"   "10003-15"  "10006-25"  "10008-43" 
#>  [6] "10011-65"  "10012-5"   "10013-34"  "10014-31"  "10015-119"
```

### Alternative to `dplyr`

If you prefer to avoid the `dplyr` import/dependency, you can achieve a
similar result with similar syntax by writing your own renaming
function:

``` r
rename2 <- function (.data, ...) {
  map <- c(...)
  loc <- setNames(match(map, names(.data), nomatch = 0L), names(map))
  loc <- loc[loc > 0L]
  newnames <- names(.data)
  newnames[loc] <- names(loc)
  setNames(.data, newnames)
}
```

Now, with *similar* syntax (but cannot use `!!!`):

``` r
# rename `mtcars` in-line
rename2(mtcars, MPG = "mpg", CARB = "carb") |>
  head()
#>                    MPG cyl disp  hp drat    wt  qsec vs am gear CARB
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

# rename `mtcars` via named `key`
rename2(mtcars, key) |>
  head()
#>                    MPG cyl disp  hp drat    wt  qsec vs am gear CARB
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```
