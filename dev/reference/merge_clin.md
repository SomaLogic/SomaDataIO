# Merge Clinical Data into SomaScan

Occasionally, additional clinical data is obtained *after* samples have
been submitted to SomaLogic, or even after 'SomaScan' results have been
delivered. This requires the new clinical variables, i.e. non-proteomic,
data to be merged with 'SomaScan' data into a "new" ADAT prior to
analysis. `merge_clin()` easily merges such clinical variables into an
existing `soma_adat` object and is a simple wrapper around
[`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).

## Usage

``` r
merge_clin(x, clin_data, by = NULL, by_class = NULL, ...)
```

## Arguments

- x:

  A `soma_adat` object (with intact attributes), typically created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- clin_data:

  One of 2 options:

  - a data frame containing clinical variables to merge into `x`, or

  - a path to a file, typically a `*.csv`, containing clinical variables
    to merge into `x`.

- by:

  A character vector of variables to join by. See
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
  for more details.

- by_class:

  If `clin_data` is a file path, a named character vector of the
  variable and its class. This ensures the "by-key" is compatible for
  the join. For example, `c(SampleId = "character")`. See
  [`read.table()`](https://rdrr.io/r/utils/read.table.html) for details
  about its `colClasses` argument, and also the examples below.

- ...:

  Additional parameters passed to
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).

## Value

A `soma_adat` with new clinical variables merged.

## Details

This functionality also exists as a command-line tool (R script)
contained in `merge_clin.R` that lives in the `cli/merge` system file
directory. Please see:

- `dir(system.file("cli/merge", package = "SomaDataIO"), full.names = TRUE)`

- `vignette("cli-merge-tool", package = "SomaDataIO")`

## See also

[`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)

## Author

Stu Field

## Examples

``` r
# retrieve clinical data
clin_file <- system.file("cli/merge", "meta.csv",
                         package = "SomaDataIO",
                         mustWork = TRUE)
clin_file
#> [1] "/Users/runner/work/_temp/Library/SomaDataIO/cli/merge/meta.csv"

# view clinical data to be merged:
# 1) `group`
# 2) `newvar`
clin_df <- read.csv(clin_file, colClasses = c(SampleId = "character"))
clin_df
#>   SampleId group    newvar
#> 1        1     a -0.757960
#> 2        3     b -0.363479
#> 3        5     a  1.010235
#> 4        7     b  1.342776
#> 5        9     a -3.010827

# create mini-adat
apts <- withr::with_seed(123, sample(getAnalytes(example_data), 2L))
adat <- head(example_data, 9L) |>   # 9 x 2
  dplyr::select(SampleId, all_of(apts))

# merge clinical variables
merged <- merge_clin(adat, clin_df, by = "SampleId")
merged
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 9
#>      Columns              5
#>      Clinical Data        3
#>      Features             2
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 9 × 6
#>   row_names      SampleId seq.19251.56 seq.19328.51 group newvar
#>   <chr>          <chr>           <dbl>        <dbl> <chr>  <dbl>
#> 1 258495800012_3 1               2933.         504  a     -0.758
#> 2 258495800004_7 2               1995.         439. NA    NA    
#> 3 258495800010_8 3               3424.         421. b     -0.363
#> 4 258495800003_4 4               2989.         468. NA    NA    
#> 5 258495800009_4 5               5078.         474. a      1.01 
#> 6 258495800012_8 6               6131.         546. NA    NA    
#> 7 258495800001_3 7               3865          468. b      1.34 
#> 8 258495800004_8 8               6865.         469. NA    NA    
#> 9 258495800001_8 9               9204.         494. a     -3.01 
#> ═══════════════════════════════════════════════════════════════════════

# Alternative syntax:
#   1) pass file path
#   2) merge on different variable names
#   3) convert join type on-the-fly
clin_file2 <- system.file("cli/merge", "meta2.csv",
                          package = "SomaDataIO",
                          mustWork = TRUE)

id_type <- typeof(adat$SampleId)
merged2 <- merge_clin(adat, clin_file2,                # file path
                      by = c(SampleId = "ClinKey"),    # join on 2 variables
                      by_class = c(ClinKey = id_type)) # match types
merged2
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 9
#>      Columns              5
#>      Clinical Data        3
#>      Features             2
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 9 × 6
#>   row_names      SampleId seq.19251.56 seq.19328.51 group newvar
#>   <chr>          <chr>           <dbl>        <dbl> <chr>  <dbl>
#> 1 258495800012_3 1               2933.         504  a     -0.758
#> 2 258495800004_7 2               1995.         439. NA    NA    
#> 3 258495800010_8 3               3424.         421. b     -0.363
#> 4 258495800003_4 4               2989.         468. NA    NA    
#> 5 258495800009_4 5               5078.         474. a      1.01 
#> 6 258495800012_8 6               6131.         546. NA    NA    
#> 7 258495800001_3 7               3865          468. b      1.34 
#> 8 258495800004_8 8               6865.         469. NA    NA    
#> 9 258495800001_8 9               9204.         494. a     -3.01 
#> ═══════════════════════════════════════════════════════════════════════
```
