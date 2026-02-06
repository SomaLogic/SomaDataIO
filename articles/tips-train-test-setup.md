# Common train-test data setups

## Introduction

Most machine learning (ML) analyses require a random split of original
data into training/test data sets, where the model is fit on the
training data and performance is evaluated on the test data set. The
split proportions can vary, though 80/20 training/test is common. It
often depends on the number of available samples and the class
distribution in the splits.

Among many alternatives, there are 3 common approaches, all are equally
viable and depend on the analyst’s weighing of pros/cons of each. I
recommend one of these below:

1.  base R data frame indexing with \[sample()\] and `[`
2.  use
    [`dplyr::slice_sample()`](https://dplyr.tidyverse.org/reference/slice.html)
    or
    [`dplyr::sample_frac()`](https://dplyr.tidyverse.org/reference/sample_n.html)
    in combination with
    [`dplyr::anti_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html)
3.  use the [rsample](https://rsample.tidymodels.org) package (not
    demonstrated)

------------------------------------------------------------------------

### Original Raw Data

In most analyses, you typically start with a raw original data set that
you must split randomly into training and test sets.

``` r
raw <- SomaDataIO::rn2col(head(mtcars, 10L), "CarModel") |>
  SomaDataIO::add_rowid("id") |> # set up identifier variable for the join()
  tibble::as_tibble()
raw
#> # A tibble: 10 × 13
#>       id CarModel          mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <int> <chr>           <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     1 Mazda RX4        21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2     2 Mazda RX4 Wag    21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3     3 Datsun 710       22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4     4 Hornet 4 Drive   21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5     5 Hornet Sportab…  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6     6 Valiant          18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7     7 Duster 360       14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8     8 Merc 240D        24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9     9 Merc 230         22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10    10 Merc 280         19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
```

------------------------------------------------------------------------

### Option \#1: `sample()`

``` r
n     <- nrow(raw)
idx   <- withr::with_seed(1, sample(1:n, floor(n / 2))) # sample random 50% (n = 5)
train <- raw[idx, ]
test  <- raw[-idx, ]
train
#> # A tibble: 5 × 13
#>      id CarModel         mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <int> <chr>          <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     9 Merc 230        22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 2     4 Hornet 4 Drive  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#> 3     7 Duster 360      14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#> 4     1 Mazda RX4       21       6  160    110  3.9   2.62  16.5     0     1     4     4
#> 5     2 Mazda RX4 Wag   21       6  160    110  3.9   2.88  17.0     0     1     4     4

test
#> # A tibble: 5 × 13
#>      id CarModel           mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <int> <chr>            <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     3 Datsun 710        22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#> 2     5 Hornet Sportabo…  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#> 3     6 Valiant           18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#> 4     8 Merc 240D         24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#> 5    10 Merc 280          19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
```

### Option \#2: `anti_join()`

``` r
# sample random 50% (n = 5)
train <- withr::with_seed(1, dplyr::slice_sample(raw, n = floor(n / 2)))

# or using `dplyr::sample_frac()`
# train <- withr::with_seed(1, dplyr::sample_frac(raw, size = 0.5))

# use anti_join() to get the sample setdiff
test <- dplyr::anti_join(raw, train, by = "id")
train
#> # A tibble: 5 × 13
#>      id CarModel         mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <int> <chr>          <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     9 Merc 230        22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 2     4 Hornet 4 Drive  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#> 3     7 Duster 360      14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#> 4     1 Mazda RX4       21       6  160    110  3.9   2.62  16.5     0     1     4     4
#> 5     2 Mazda RX4 Wag   21       6  160    110  3.9   2.88  17.0     0     1     4     4

test
#> # A tibble: 5 × 13
#>      id CarModel           mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <int> <chr>            <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     3 Datsun 710        22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#> 2     5 Hornet Sportabo…  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#> 3     6 Valiant           18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#> 4     8 Merc 240D         24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#> 5    10 Merc 280          19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
```
