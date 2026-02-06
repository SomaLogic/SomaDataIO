# Safely Map Values via dplyr::left_join()

## Introduction

Mapping values in one column to specific values in another (new) column
of a data frame is a common task in data science. Doing so *safely* is
often a struggle. There are some existing methods in the `tidyverse`
that are useful, but in my opinion come with some drawbacks:

- [`dplyr::recode()`](https://dplyr.tidyverse.org/reference/recode.html)
  - can be clunky to implement -\> LHS/RHS syntax difficult (for me) to
    remember
- [`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
  - complex syntax -\> difficult to remember; overkill for mapping
    purposes

Below is what I see is a *safe* way to map (re-code) values in an
existing column to a new column.

------------------------------------------------------------------------

### Mapping Example

``` r
# wish to map values of 'x'
df <- withr::with_seed(101, {
  data.frame(id    = 1:10L,
             value = rnorm(10),
             x     = sample(letters[1:3L], 10, replace = TRUE)
  )
})
df
#>    id      value x
#> 1   1 -0.3260365 b
#> 2   2  0.5524619 c
#> 3   3 -0.6749438 c
#> 4   4  0.2143595 a
#> 5   5  0.3107692 c
#> 6   6  1.1739663 a
#> 7   7  0.6187899 b
#> 8   8 -0.1127343 a
#> 9   9  0.9170283 a
#> 10 10 -0.2232594 c

# create a [n x 2] lookup-table (aka hash map)
# n = no. values to map
# x = existing values to map
# new_x = new mapped values for each `x`
map <- data.frame(x = letters[1:4L], new_x = c("cat", "dog", "bird", "turtle"))
map
#>   x  new_x
#> 1 a    cat
#> 2 b    dog
#> 3 c   bird
#> 4 d turtle

# use `dplyr::left_join()`
# note: 'turtle' is absent because `d` is not in `df$x` (thus ignored)
dplyr::left_join(df, map)
#> Joining with `by = join_by(x)`
#>    id      value x new_x
#> 1   1 -0.3260365 b   dog
#> 2   2  0.5524619 c  bird
#> 3   3 -0.6749438 c  bird
#> 4   4  0.2143595 a   cat
#> 5   5  0.3107692 c  bird
#> 6   6  1.1739663 a   cat
#> 7   7  0.6187899 b   dog
#> 8   8 -0.1127343 a   cat
#> 9   9  0.9170283 a   cat
#> 10 10 -0.2232594 c  bird
```

### Un-mapped Values -\> `NAs`

Notice that `b` maps to `NA`. This is because the mapping object now
lacks a mapping for `b` (compare to row 2 above). Using a slightly
different syntax via
[`tibble::enframe()`](https://tibble.tidyverse.org/reference/enframe.html).

``` r
# note: `b` is missing in the map
map_vec <- c(a = "cat", c = "bird", d = "turtle")
map2 <- tibble::enframe(map_vec, name = "x", value = "new_x")
map2
#> # A tibble: 3 × 2
#>   x     new_x 
#>   <chr> <chr> 
#> 1 a     cat   
#> 2 c     bird  
#> 3 d     turtle

# note: un-mapped values generate NAs: `b -> NA`
dplyr::left_join(df, map2, by = "x")
#>    id      value x new_x
#> 1   1 -0.3260365 b  <NA>
#> 2   2  0.5524619 c  bird
#> 3   3 -0.6749438 c  bird
#> 4   4  0.2143595 a   cat
#> 5   5  0.3107692 c  bird
#> 6   6  1.1739663 a   cat
#> 7   7  0.6187899 b  <NA>
#> 8   8 -0.1127343 a   cat
#> 9   9  0.9170283 a   cat
#> 10 10 -0.2232594 c  bird
```
