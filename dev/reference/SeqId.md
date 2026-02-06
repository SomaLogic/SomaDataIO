# Working with SomaLogic SeqIds

The `SeqId` is the cornerstone used to uniquely identify SomaLogic
analytes. `SeqIds` follow the format **`<Pool>-<Clone>_<Version>`**, for
example `"1234-56_7"` can be represented as:

|          |           |             |
|----------|-----------|-------------|
| **Pool** | **Clone** | **Version** |
| `1234`   | `56`      | `7`         |

See **Details** below for the definition of each sub-unit. The
**`<Pool>-<Clone>`** combination is sufficient to uniquely identify a
specific analyte and therefore versions are no longer provided (though
they may be present in legacy ADATs). The tools below enable users to
extract, test, identify, compare, and manipulate `SeqIds` across assay
runs and/or versions.

## Usage

``` r
getSeqId(x, trim.version = FALSE)

regexSeqId()

locateSeqId(x, trailing = TRUE)

seqid2apt(x)

apt2seqid(x)

is.apt(x)

is.SeqId(x)

is.AptName(x)

matchSeqIds(x, y, order.by.x = TRUE)

getSeqIdMatches(x, y, show = FALSE)
```

## Arguments

- x:

  Character. A vector of strings, usually analyte/feature column names,
  `AptNames`, or `SeqIds`. For `seqid2apt()`, a vector *of* `SeqIds`.
  For `apt2seqid()`, a character vector *containing* `SeqIds`. For
  `matchSeqIds()`, a vector of pattern matches containing `SeqIds`. Can
  be `AptNames` with `GeneIDs`, the `seq.XXXX` format, or even "naked"
  `SeqIds`.

- trim.version:

  Logical. Whether to remove the version number, i.e. "1234-56_7" -\>
  "1234-56". Primarily for legacy ADATs.

- trailing:

  Logical. Should the regular expression explicitly specify *trailing*
  `SeqId` pattern match, i.e. `"regex$"`? This is the most common case
  and the default.

- y:

  Character. A second vector of `AptNames` containing `SeqIds` to match
  against those in contained in `x`. For `matchSeqIds()` these values
  are returned if there are matching elements.

- order.by.x:

  Logical. Order the returned character string by the `x` (first)
  argument?

- show:

  Logical. Return the data frame visibly?

## Value

`getSeqId()`: a character vector of `SeqIds` captured from a string.

`regexSeqId()`: a regular expression (`regex`) string pre-defined to
match SomaLogic the `SeqId` pattern.

`locateSeqId()`: a data frame containing the `start` and `stop` integer
positions for `SeqId` matches at each value of `x`.

`seqid2apt()`: a character vector with the `seq.*` prefix, i.e. the
inverse of `getSeqId()`.

`apt2seqid()`: a character vector of `SeqIds`. `is.SeqId()` will return
`TRUE` for all elements.

`is.apt()`, `is.SeqId()`: Logical. `TRUE` or `FALSE`.

`matchSeqIds()`: a character string corresponding to values in `y` of
the intersect of `x` and `y`. If no matches are found, `character(0)`.

`getSeqIdMatches()`: a \\n x 2\\ data frame, where `n` is the length of
the intersect of the matching `SeqIds`. The data frame is named by the
passed arguments, `x` and `y`.

## Details

|              |                                                   |
|--------------|---------------------------------------------------|
| **Pool:**    | ties back to the original well during **SELEX**   |
| **Clone:**   | ties to the specific sequence within a pool       |
| **Version:** | refers to custom modifications (optional/defunct) |

- `AptName`:

  a `SeqId` combined with a string, usually a `GeneId`- or
  `seq.`-prefix, for convenient, human-readable manipulation from within
  `R`.

## Functions

- `getSeqId()`: extracts/captures the the `SeqId` match from an analyte
  column identifier, i.e. column name of an ADAT loaded with
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).
  Assumes the `SeqId` pattern occurs at the end of the string, which for
  the vast majority of cases will be true. For edge cases, see the
  `trailing` argument to `locateSeqId()`.

- `regexSeqId()`: generates a pre-formatted regular expression for
  matching of `SeqIds`. Note the *trailing* match, which is most
  commonly required, but `locateSeqId()` offers an alternative to mach
  *anywhere* in a string. Used internally in *many* utility functions

- `locateSeqId()`: generates a data frame of the positional `SeqId`
  matches. Specifically designed to facilitate `SeqId` extraction via
  [`substr()`](https://rdrr.io/r/base/substr.html). Similar to
  [`stringr::str_locate()`](https://stringr.tidyverse.org/reference/str_locate.html).

- `seqid2apt()`: converts a `SeqId` into anonymous-AptName format, i.e.
  `1234-56` -\> `seq.1234.56`. Version numbers (`1234-56_ver`) are
  always trimmed when present.

- `apt2seqid()`: converts an anonymous-AptName into `SeqId` format, i.e.
  `seq.1234.56` -\> `1234-56`. Version numbers (`seq.1234.56.ver`) are
  always trimmed when present.

- `is.apt()`: regular expression match to determine if a string
  *contains* a `SeqId`, and thus is probably an `AptName` format string.
  Both legacy `EntrezGeneSymbol-SeqId` combinations or newer so-called
  `"anonymous-AptNames"` formats (`seq.1234.45`) are matched.

- `is.SeqId()`: tests for `SeqId` format, i.e. values returned from
  `getSeqId()` will always return `TRUE`.

- `is.AptName()`: tests for `AptName` format, i.e. values returned from
  `seqid2apt()` will always return `TRUE`. This function will only match
  `AptNames`, not `SeqIds`, and is therefore more strict than
  `is.apt()`.

- `matchSeqIds()`: matches two character vectors on the basis of their
  intersecting `SeqIds`. Note that elements in `y` not containing a
  `SeqId` regular expression are silently dropped.

- `getSeqIdMatches()`: matches two character vectors on the basis of
  their intersecting *SeqIds* only (irrespective of the
  `GeneID`-prefix). This produces a two-column data frame which then can
  be used as to map between the two sets.

  The final order of the matches/rows is by the input corresponding to
  the *first* argument (`x`).

  By default the data frame is invisibly returned to avoid dumping
  excess output to the console (see the `show =` argument.)

## See also

[`generics::intersect()`](https://generics.r-lib.org/reference/setops.html)

## Author

Stu Field

## Examples

``` r
x <- c("ABDC.3948.48.2", "3948.88",
       "3948.48.2", "3948-48_2", "3948.48.2",
       "3948-48_2", "3948-88",
       "My.Favorite.Apt.3948.88.9")

tibble::tibble(orig       = x,
               SeqId      = getSeqId(x),
               SeqId_trim = getSeqId(x, TRUE),
               AptName    = seqid2apt(SeqId))
#> # A tibble: 8 × 4
#>   orig                      SeqId     SeqId_trim AptName    
#>   <chr>                     <chr>     <chr>      <chr>      
#> 1 ABDC.3948.48.2            3948-48_2 3948-48    seq.3948.48
#> 2 3948.88                   3948-88   3948-88    seq.3948.88
#> 3 3948.48.2                 3948-48_2 3948-48    seq.3948.48
#> 4 3948-48_2                 3948-48_2 3948-48    seq.3948.48
#> 5 3948.48.2                 3948-48_2 3948-48    seq.3948.48
#> 6 3948-48_2                 3948-48_2 3948-48    seq.3948.48
#> 7 3948-88                   3948-88   3948-88    seq.3948.88
#> 8 My.Favorite.Apt.3948.88.9 3948-88_9 3948-88    seq.3948.88

# Logical Matching
is.apt("AGR2.4959.2") # TRUE
#> [1] TRUE
is.apt("seq.4959.2")  # TRUE
#> [1] TRUE
is.apt("4959-2")      # TRUE
#> [1] TRUE
is.apt("AGR2")        # FALSE
#> [1] FALSE


# SeqId Matching
x <- c("seq.4554.56", "seq.3714.49", "PlateId")
y <- c("Group", "3714-49", "Assay", "4554-56")
matchSeqIds(x, y)
#> [1] "4554-56" "3714-49"
matchSeqIds(x, y, order.by.x = FALSE)
#> [1] "3714-49" "4554-56"

# vector of features
feats <- getAnalytes(example_data)

match_df <- getSeqIdMatches(feats[1:100], feats[90:500])  # 11 overlapping
match_df
#>     feats[1:100] feats[90:500]
#> 1   seq.10461.57  seq.10461.57
#> 2   seq.10462.14  seq.10462.14
#> 3    seq.10464.6   seq.10464.6
#> 4   seq.10467.58  seq.10467.58
#> 5   seq.10471.25  seq.10471.25
#> 6   seq.10476.23  seq.10476.23
#> 7  seq.10477.162 seq.10477.162
#> 8   seq.10485.56  seq.10485.56
#> 9   seq.10489.19  seq.10489.19
#> 10   seq.10490.3   seq.10490.3
#> 11  seq.10491.21  seq.10491.21

a <- utils::head(feats, 15)
b <- withr::with_seed(99, sample(getSeqId(a)))   # => SeqId & shuffle
(getSeqIdMatches(a, b))                          # sorted by first vector "a"
#>                a         b
#> 1   seq.10000.28  10000-28
#> 2    seq.10001.7   10001-7
#> 3   seq.10003.15  10003-15
#> 4   seq.10006.25  10006-25
#> 5   seq.10008.43  10008-43
#> 6   seq.10011.65  10011-65
#> 7    seq.10012.5   10012-5
#> 8   seq.10013.34  10013-34
#> 9   seq.10014.31  10014-31
#> 10 seq.10015.119 10015-119
#> 11   seq.10021.1   10021-1
#> 12 seq.10022.207 10022-207
#> 13  seq.10023.32  10023-32
#> 14  seq.10024.44  10024-44
#> 15   seq.10030.8   10030-8
```
