# Helpers for Working With Row Names

Easily move row names to a column and vice-versa without the unwanted
side-effects to object class and attributes. Drop-in replacement for
[`tibble::rownames_to_column()`](https://tibble.tidyverse.org/reference/rownames.html)
and
[`tibble::column_to_rownames()`](https://tibble.tidyverse.org/reference/rownames.html)
which can have undesired side-effects to complex object attributes. Does
not import any external packages, modify the environment, or change the
object (other than the desired column). When using `col2rn()`, if
explicit row names exist, they are overwritten with a warning.
`add_rowid()` does *not* affect row names, which differs from
[`tibble::rowid_to_column()`](https://tibble.tidyverse.org/reference/rownames.html).

## Usage

``` r
rn2col(data, name = ".rn")

col2rn(data, name = ".rn")

has_rn(data)

rm_rn(data)

set_rn(data, value)

add_rowid(data, name = ".rowid")
```

## Arguments

- data:

  An object that inherits from class `data.frame`. Typically a
  `soma_adat` class object.

- name:

  Character. The name of the column to move.

- value:

  Character. The new set of names for the data frame. If duplicates
  exist they are modified on-the-fly via
  [`make.unique()`](https://rdrr.io/r/base/make.unique.html).

## Value

All functions attempt to return an object of the same class as the input
with fully intact and unmodified attributes (aside from those required
by the desired action). `has_rn()` returns a scalar logical.

## Functions

- `rn2col()`: moves the row names of `data` to an explicit column
  whether they are explicit or implicit.

- `col2rn()`: is the inverse of `rn2col()`. If row names exist, they
  will be overwritten (with warning).

- `has_rn()`: returns a boolean indicating whether the data frame has
  explicit row names assigned.

- `rm_rn()`: removes existing row names, leaving only "implicit" row
  names.

- `set_rn()`: sets (and overwrites) existing row names for data frames
  only.

- `add_rowid()`: adds a sequential integer row identifier; starting at
  `1:nrow(data)`. It does *not* remove existing row names currently, but
  may in the future (please code accordingly).

## Examples

``` r
df <- data.frame(a = 1:5, b = rnorm(5), row.names = LETTERS[1:5])
df
#>   a           b
#> A 1  0.07003485
#> B 2 -0.63912332
#> C 3 -0.04996490
#> D 4 -0.25148344
#> E 5  0.44479712
rn2col(df)              # default name is `.rn`
#>   .rn a           b
#> 1   A 1  0.07003485
#> 2   B 2 -0.63912332
#> 3   C 3 -0.04996490
#> 4   D 4 -0.25148344
#> 5   E 5  0.44479712
rn2col(df, "AptName")   # pass `name =`
#>   AptName a           b
#> 1       A 1  0.07003485
#> 2       B 2 -0.63912332
#> 3       C 3 -0.04996490
#> 4       D 4 -0.25148344
#> 5       E 5  0.44479712

# moving columns
df$mtcars <- sample(names(mtcars), 5)
col2rn(df, "mtcars")   # with a warning
#> Warning: `df` already has row names. They will be over-written.
#>      a           b
#> vs   1  0.07003485
#> mpg  2 -0.63912332
#> gear 3 -0.04996490
#> qsec 4 -0.25148344
#> hp   5  0.44479712

# Move back and forth easily
# Leaves original object un-modified
identical(df, col2rn(rn2col(df)))
#> [1] TRUE

# add "id" column
add_rowid(mtcars)
#>                     .rowid  mpg cyl  disp  hp drat    wt  qsec vs am
#> Mazda RX4                1 21.0   6 160.0 110 3.90 2.620 16.46  0  1
#> Mazda RX4 Wag            2 21.0   6 160.0 110 3.90 2.875 17.02  0  1
#> Datsun 710               3 22.8   4 108.0  93 3.85 2.320 18.61  1  1
#> Hornet 4 Drive           4 21.4   6 258.0 110 3.08 3.215 19.44  1  0
#> Hornet Sportabout        5 18.7   8 360.0 175 3.15 3.440 17.02  0  0
#> Valiant                  6 18.1   6 225.0 105 2.76 3.460 20.22  1  0
#> Duster 360               7 14.3   8 360.0 245 3.21 3.570 15.84  0  0
#> Merc 240D                8 24.4   4 146.7  62 3.69 3.190 20.00  1  0
#> Merc 230                 9 22.8   4 140.8  95 3.92 3.150 22.90  1  0
#> Merc 280                10 19.2   6 167.6 123 3.92 3.440 18.30  1  0
#> Merc 280C               11 17.8   6 167.6 123 3.92 3.440 18.90  1  0
#> Merc 450SE              12 16.4   8 275.8 180 3.07 4.070 17.40  0  0
#> Merc 450SL              13 17.3   8 275.8 180 3.07 3.730 17.60  0  0
#> Merc 450SLC             14 15.2   8 275.8 180 3.07 3.780 18.00  0  0
#> Cadillac Fleetwood      15 10.4   8 472.0 205 2.93 5.250 17.98  0  0
#> Lincoln Continental     16 10.4   8 460.0 215 3.00 5.424 17.82  0  0
#> Chrysler Imperial       17 14.7   8 440.0 230 3.23 5.345 17.42  0  0
#> Fiat 128                18 32.4   4  78.7  66 4.08 2.200 19.47  1  1
#> Honda Civic             19 30.4   4  75.7  52 4.93 1.615 18.52  1  1
#> Toyota Corolla          20 33.9   4  71.1  65 4.22 1.835 19.90  1  1
#> Toyota Corona           21 21.5   4 120.1  97 3.70 2.465 20.01  1  0
#> Dodge Challenger        22 15.5   8 318.0 150 2.76 3.520 16.87  0  0
#> AMC Javelin             23 15.2   8 304.0 150 3.15 3.435 17.30  0  0
#> Camaro Z28              24 13.3   8 350.0 245 3.73 3.840 15.41  0  0
#> Pontiac Firebird        25 19.2   8 400.0 175 3.08 3.845 17.05  0  0
#> Fiat X1-9               26 27.3   4  79.0  66 4.08 1.935 18.90  1  1
#> Porsche 914-2           27 26.0   4 120.3  91 4.43 2.140 16.70  0  1
#> Lotus Europa            28 30.4   4  95.1 113 3.77 1.513 16.90  1  1
#> Ford Pantera L          29 15.8   8 351.0 264 4.22 3.170 14.50  0  1
#> Ferrari Dino            30 19.7   6 145.0 175 3.62 2.770 15.50  0  1
#> Maserati Bora           31 15.0   8 301.0 335 3.54 3.570 14.60  0  1
#> Volvo 142E              32 21.4   4 121.0 109 4.11 2.780 18.60  1  1
#>                     gear carb
#> Mazda RX4              4    4
#> Mazda RX4 Wag          4    4
#> Datsun 710             4    1
#> Hornet 4 Drive         3    1
#> Hornet Sportabout      3    2
#> Valiant                3    1
#> Duster 360             3    4
#> Merc 240D              4    2
#> Merc 230               4    2
#> Merc 280               4    4
#> Merc 280C              4    4
#> Merc 450SE             3    3
#> Merc 450SL             3    3
#> Merc 450SLC            3    3
#> Cadillac Fleetwood     3    4
#> Lincoln Continental    3    4
#> Chrysler Imperial      3    4
#> Fiat 128               4    1
#> Honda Civic            4    2
#> Toyota Corolla         4    1
#> Toyota Corona          3    1
#> Dodge Challenger       3    2
#> AMC Javelin            3    2
#> Camaro Z28             3    4
#> Pontiac Firebird       3    2
#> Fiat X1-9              4    1
#> Porsche 914-2          5    2
#> Lotus Europa           5    2
#> Ford Pantera L         5    4
#> Ferrari Dino           5    6
#> Maserati Bora          5    8
#> Volvo 142E             4    2

# remove row names
has_rn(mtcars)
#> [1] TRUE
mtcars2 <- rm_rn(mtcars)
has_rn(mtcars2)
#> [1] FALSE
```
