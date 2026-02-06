# Group Generics for `soma_adat` Class Objects

S3 group generic methods to apply group specific prototype functions to
the RFU data **only** of `soma_adat` objects. The clinical meta data are
*not* transformed and remain unmodified in the returned object
([`Math()`](https://rdrr.io/r/base/groupGeneric.html) and
[`Ops()`](https://rdrr.io/r/base/groupGeneric.html)) or are ignored for
the [`Summary()`](https://rdrr.io/r/base/groupGeneric.html) group. See
[`groupGeneric()`](https://rdrr.io/r/base/groupGeneric.html).

## Usage

``` r
# S3 method for class 'soma_adat'
Math(x, ...)

antilog(x, base = 10)

# S3 method for class 'soma_adat'
Ops(e1, e2 = NULL)

# S3 method for class 'soma_adat'
Summary(..., na.rm = FALSE)

# S3 method for class 'soma_adat'
e1 == e2
```

## Arguments

- x:

  The `soma_adat` class object to perform the transformation.

- ...:

  Additional arguments passed to the various group generics as
  appropriate.

- base:

  A positive or complex number: the base with respect to which
  logarithms are computed.

- e1, e2:

  Objects.

- na.rm:

  Logical. Should missing values be removed?

## Value

A `soma_adat` object with the same dimensions of the input object with
the feature columns transformed by the specified generic.

## Functions

- `antilog()`: performs the inverse or anti-log transform for a numeric
  vector of `soma_adat` object. **note:** default is `base = 10`, which
  differs from the [`log()`](https://rdrr.io/r/base/Log.html) default
  base *e*.

- `Ops(soma_adat)`: performs binary mathematical operations on class
  `soma_adat`. See [`Ops()`](https://rdrr.io/r/base/groupGeneric.html).

- `Summary(soma_adat)`: performs summary calculations on class
  `soma_adat`. See
  [`Summary()`](https://rdrr.io/r/base/groupGeneric.html).

- ` == `: compares left- and right-hand sides of the operator *unless*
  the RHS is also a `soma_adat`, in which case
  [`diffAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/diffAdats.md)
  is invoked.

## Math

Group members:

    #>  [1] "abs"      "acos"     "acosh"    "asin"     "asinh"    "atan"
    #>  [7] "atanh"    "ceiling"  "cos"      "cosh"     "cospi"    "cummax"
    #> [13] "cummin"   "cumprod"  "cumsum"   "digamma"  "exp"      "expm1"
    #> [19] "floor"    "gamma"    "lgamma"   "log"      "log10"    "log1p"
    #> [25] "log2"     "sign"     "sin"      "sinh"     "sinpi"    "sqrt"
    #> [31] "tan"      "tanh"     "tanpi"    "trigamma" "trunc"

Commonly used generics of this group include:

- [`log()`](https://rdrr.io/r/base/Log.html),
  [`log10()`](https://rdrr.io/r/base/Log.html),
  [`log2()`](https://rdrr.io/r/base/Log.html), `antilog()`,
  [`abs()`](https://rdrr.io/r/base/MathFun.html),
  [`sign()`](https://rdrr.io/r/base/sign.html),
  [`floor()`](https://rdrr.io/r/base/Round.html),
  [`sqrt()`](https://rdrr.io/r/base/MathFun.html),
  [`exp()`](https://rdrr.io/r/base/Log.html)

## Ops

Group members:

    #>  [1] "+"   "-"   "*"   "^"   "%%"  "%/%" "/"   "=="  ">"   "<"   "!="  "<="
    #> [13] ">="

Note that for the `` `==` `` method if the RHS is also a `soma_adat`,
[`diffAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/diffAdats.md)
is invoked which compares LHS vs. RHS. Commonly used generics of this
group include:

- `+`, `-`, `*`, `/`, `^`, `==`, `>`, `<`

## Summary

Group members:

    #> [1] "all"   "any"   "max"   "min"   "prod"  "range" "sum"

Commonly used generics of this group include:

- [`max()`](https://rdrr.io/r/base/Extremes.html),
  [`min()`](https://rdrr.io/r/base/Extremes.html),
  [`range()`](https://rdrr.io/r/base/range.html),
  [`sum()`](https://rdrr.io/r/base/sum.html),
  [`any()`](https://rdrr.io/r/base/any.html)

## See also

[`groupGeneric()`](https://rdrr.io/r/base/groupGeneric.html),
`getGroupMembers()`, `getGroup()`

## Author

Stu Field

## Examples

``` r
# subset `example_data` for speed
# all SeqIds from 2000 -> 2999
seqs <- grep("^seq\\.2[0-9]{3}", names(example_data), value = TRUE)
ex_data_small <- head(example_data[, c(getMeta(example_data), seqs)], 10L)
dim(ex_data_small)
#> [1]  10 264

ex_data_small$seq.2991.9
#>  [1] 4921.8 4392.2 4791.5 6017.2 5711.3 5092.4 4417.9 5394.3 6111.4
#> [10] 6045.2

# Math Generics:
# -------------
# log-transformation
a <- log(ex_data_small)
a$seq.2991.9
#>  [1] 8.501430 8.387586 8.474599 8.702377 8.650202 8.535505 8.393420
#>  [8] 8.593098 8.717911 8.707020

b <- log10(ex_data_small)
b$seq.2991.9
#>  [1] 3.692124 3.642682 3.680471 3.779394 3.756735 3.706923 3.645216
#>  [8] 3.731935 3.786141 3.781411
isTRUE(all.equal(b, log(ex_data_small, base = 10)))
#> [1] TRUE

# floor
c <- floor(ex_data_small)
c$seq.2991.9
#>  [1] 4921 4392 4791 6017 5711 5092 4417 5394 6111 6045

# square-root
d <- sqrt(ex_data_small)
d$seq.2991.9
#>  [1] 70.15554 66.27368 69.22066 77.57061 75.57314 71.36105 66.46729
#>  [8] 73.44590 78.17544 77.75088

# rounding
e <- round(ex_data_small)
e$seq.2991.9
#>  [1] 4922 4392 4792 6017 5711 5092 4418 5394 6111 6045

# inverse log
antilog(1:4)
#> [1]    10   100  1000 10000

alog <- antilog(b)
all.equal(ex_data_small, alog)    # return `b` -> linear space
#> [1] TRUE

# Ops Generics:
# -------------
plus1 <- ex_data_small + 1
times2 <- ex_data_small * 2

sq <- ex_data_small^2
all.equal(sqrt(sq), ex_data_small)
#> [1] TRUE

gt100k <- ex_data_small > 100000
gt100k
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 10
#>      Columns              264
#>      Clinical Data        34
#>      Features             230
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 10 × 265
#>    row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId
#>    <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>
#>  1 258495800012_3 Example… 2020-06-18   SG152144… H9            2.58e11
#>  2 258495800004_7 Example… 2020-06-18   SG152144… H8            2.58e11
#>  3 258495800010_8 Example… 2020-06-18   SG152144… H7            2.58e11
#>  4 258495800003_4 Example… 2020-06-18   SG152144… H6            2.58e11
#>  5 258495800009_4 Example… 2020-06-18   SG152144… H5            2.58e11
#>  6 258495800012_8 Example… 2020-06-18   SG152144… H4            2.58e11
#>  7 258495800001_3 Example… 2020-06-18   SG152144… H3            2.58e11
#>  8 258495800004_8 Example… 2020-06-18   SG152144… H2            2.58e11
#>  9 258495800001_8 Example… 2020-06-18   SG152144… H12           2.58e11
#> 10 258495800004_3 Example… 2020-06-18   SG152144… H11           2.58e11
#> # ℹ 259 more variables: Subarray <dbl>, SampleId <chr>,
#> #   SampleType <chr>, PercentDilution <int>, SampleMatrix <chr>,
#> #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
#> #   SampleNotes <lgl>, AliquotingNotes <lgl>, …
#> ═══════════════════════════════════════════════════════════════════════

ex_data_small == ex_data_small   # invokes diffAdats()
#> ══ Checking ADAT attributes & characteristics ═════════════════════════
#> → Attribute names are identical       ✓
#> → Attributes are identical            ✓
#> → ADAT dimensions are identical       ✓
#> → ADAT row names are identical        ✓
#> → ADATs contain identical Features    ✓
#> → ADATs contain same Meta Fields      ✓
#> ── Checking the data matrix ───────────────────────────────────────────
#> → All Clinical data is identical      ✓
#> → All Feature data is identical       ✓
#> ═══════════════════════════════════════════════════════════════════════
#> NULL

# Summary Generics:
# -------------
sum(ex_data_small)
#> [1] 24319326

any(ex_data_small < 100)  # low RFU analytes
#> [1] TRUE

sum(ex_data_small < 100)  # how many
#> [1] 67

min(ex_data_small)
#> [1] 9.9

min(ex_data_small, 0)
#> [1] 0

max(ex_data_small)
#> [1] 213074.3

max(ex_data_small, 1e+7)
#> [1] 1e+07

range(ex_data_small)
#> [1]      9.9 213074.3
```
