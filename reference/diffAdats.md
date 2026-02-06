# Diff Two ADAT Objects

Diff tool for the differences between two `soma_adat` objects. When
diffs of the table *values* are interrogated, **only** the intersect of
the column meta data or feature data is considered

## Usage

``` r
diffAdats(adat1, adat2, tolerance = 1e-06)
```

## Arguments

- adat1, adat2:

  Two `soma_adat` objects to compare.

- tolerance:

  Numeric `> 0`. Differences smaller than tolerance are not triggered.
  See [`all.equal()`](https://rdrr.io/r/base/all.equal.html).

## Value

`NULL`, invisibly. Called for side effects.

## Note

Only diffs of the column name *intersect* are reported.

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

# no diff to itself
diffAdats(ex_data_small, ex_data_small)
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

# remove random column
rm <- withr::with_seed(123, sample(1:ncol(ex_data_small), 1))
diffAdats(ex_data_small, ex_data_small[, -rm])
#> ══ Checking ADAT attributes & characteristics ═════════════════════════
#> → Attribute names are identical       ✓
#> → Attributes are identical            ✖
#> → ADAT dimensions are identical       ✖
#> →   ADATs have same # of rows         ✓
#> →   ADATs have same # of columns      ✖
#> →   ADATs have same # of features     ✖
#> →   ADATs have same # of meta data    ✓
#> → ADAT row names are identical        ✓
#> → ADATs contain identical Features    ✖
#> → ADATs contain same Meta Fields      ✓
#> "ex_data_small"
#> "ex_data_small[, -rm]"
#>          seq.2790.54
#> 
#> ✔ Continuing on the "*INTERSECT*" of ADAT columns
#> ── Checking the data matrix ───────────────────────────────────────────
#> → All Clinical data is identical      ✓
#> → All Feature data is identical       ✓
#> ═══════════════════════════════════════════════════════════════════════

# randomly shuffle Subarray
diffAdats(ex_data_small, dplyr::mutate(ex_data_small, Subarray = sample(Subarray)))
#> ══ Checking ADAT attributes & characteristics ═════════════════════════
#> → Attribute names are identical       ✓
#> → Attributes are identical            ✓
#> → ADAT dimensions are identical       ✓
#> → ADAT row names are identical        ✓
#> → ADATs contain identical Features    ✓
#> → ADATs contain same Meta Fields      ✓
#> ── Checking the data matrix ───────────────────────────────────────────
#> → All Clinical data is identical      ✖
#>     No. fields that differ            1
#> ── Clinical data diffs ────────────────────────────────────────────────
#> "Subarray"
#> NULL
#> → All Feature data is identical       ✓
#> ═══════════════════════════════════════════════════════════════════════

# modify 2 RFUs randomly
new <- ex_data_small
new[5L, c(rm, rm + 1L)] <- 999
diffAdats(ex_data_small, new)
#> ══ Checking ADAT attributes & characteristics ═════════════════════════
#> → Attribute names are identical       ✓
#> → Attributes are identical            ✓
#> → ADAT dimensions are identical       ✓
#> → ADAT row names are identical        ✓
#> → ADATs contain identical Features    ✓
#> → ADATs contain same Meta Fields      ✓
#> ── Checking the data matrix ───────────────────────────────────────────
#> → All Clinical data is identical      ✓
#> → All Feature data is identical       ✖
#>     No. fields that differ            2
#> ── Feature data diffs ─────────────────────────────────────────────────
#> "seq.2790.54" and "seq.2794.60"
#> NULL
#> ═══════════════════════════════════════════════════════════════════════
```
