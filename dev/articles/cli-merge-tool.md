# Command Line Merge Tool

## Overview

Occasionally, additional clinical data is obtained *after* samples have
been submitted to SomaLogic, Inc. or even after ‘SomaScan’ results have
been delivered.

This requires the new clinical, i.e. non-proteomic, data to be merged
with the ‘SomaScan’ data into a “new” ADAT prior to analysis. For this
purpose, a command-line-interface (“CLI”) tool has been included with
[SomaDataIO](https://CRAN.R-project.org/package=SomaDataIO) in the
`cli/merge/` directory, which allows one to generate an updated `*.adat`
file via the command-line without having to launch an integrated
development environment (“IDE”), e.g. `RStudio`.

To use `SomaDataIO`s exported functionality from *within* an R session,
please see
[`merge_clin()`](https://somalogic.github.io/SomaDataIO/dev/reference/merge_clin.md).

------------------------------------------------------------------------

### Setup

The clinical merge tool is an `R script` that comes with an installation
of [SomaDataIO](https://CRAN.R-project.org/package=SomaDataIO):

``` r
dir(system.file("cli", "merge", package = "SomaDataIO", mustWork = TRUE))
#> [1] "merge_clin.R" "meta.csv"     "meta2.csv"

merge_script <- system.file("cli/merge", "merge_clin.R", package = "SomaDataIO")
merge_script
#> [1] "/Users/runner/work/_temp/Library/SomaDataIO/cli/merge/merge_clin.R"
```

First create a temporary “analysis” directory:

``` r
analysis_dir <- tempfile(pattern = "somascan-")
# create directory
dir.create(analysis_dir)

# sanity check
dir.exists(analysis_dir)
#> [1] TRUE

# copy merge tool into analysis directory
file.copy(merge_script, to = analysis_dir)
#> [1] TRUE
```

### Create Example Data

Let’s create some dummy ‘SomaScan’ data derived from the `example_data`
object from [SomaDataIO](https://CRAN.R-project.org/package=SomaDataIO).
First we reduce its size to 9 samples and 5 proteomic features, and then
write to text file in our new analysis directory with
[`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md).
This will be the “new” starting point for the clinical data merge and
represents where customers would typically begin an analysis.

``` r
feats <- withr::with_seed(3, sample(getAnalytes(example_data), 5L))
sub_adat <- dplyr::select(example_data, PlateId, SlideId, Subarray,
                          SampleId, Age, all_of(feats)) |> head(9L)
withr::with_dir(analysis_dir,
  write_adat(sub_adat, file = "ex-data-9.adat")
)
#> ✔ ADAT passed all checks and traps.
#> ✔ ADAT written to: "ex-data-9.adat"
```

Next we create random clinical data with a common key (this is typically
the `SampleId` identifier but it could be any common key).

``` r
df <- data.frame(SampleId = as.character(seq(1, 9, by = 2)),  # common key
                 group    = c("a", "b", "a", "b", "a"),
                 newvar   = withr::with_seed(1, rnorm(5)))
df
#>   SampleId group     newvar
#> 1        1     a -0.6264538
#> 2        3     b  0.1836433
#> 3        5     a -0.8356286
#> 4        7     b  1.5952808
#> 5        9     a  0.3295078

# write clinical data to file
withr::with_dir(analysis_dir,
  write.csv(df, file = "clin-data.csv", row.names = FALSE)
)
```

At this point there are now 3 files in our analysis directory:

``` r
dir(analysis_dir)
#> [1] "clin-data.csv"  "ex-data-9.adat" "merge_clin.R"
```

1.  `merge_clin.R` the merge script engine itself
2.  `clin-data.csv`:
    - new data containing 3 columns:
    - a common key: `SampleId`
    - a new variable with grouping information: `group`
    - a new variable with a continuous variable: `newvar`
3.  `ex-data-9.adat`:
    - ADAT with 9 samples containing 5 ‘SomaScan’ proteomic features and
      5 pre-existing variables we would like to merge into
    - `PlateId`, `SlideId`, `Subarray`, `SampleId`, and `Age`
    - **note:** `PlateId`, `SlideId`, and `Subarray` are key fields
      common to *almost all* ADATs; removing them could yield unintended
      results
    - the common key `SampleId` is required

### Merging Clinical Data

The clinical data merge tool is simple to use at most common command
line terminals (`BASH`, `ZSH`, etc.). You must have `R` installed (and
available) with
[SomaDataIO](https://CRAN.R-project.org/package=SomaDataIO) and its
dependencies installed.

#### Arguments

The merge script takes 4 (four), *ordered* arguments:

1.  path to the original ADAT (`*.adat`) file
2.  path to clinical data (`*.csv`) file
3.  common key variable name (e.g. `SampleId`)
4.  output file name (`*.adat`) for new ADAT

------------------------------------------------------------------------

#### Standard Syntax

The primary syntax is for when the common key in **both** files, (ADAT
and CSV), has the *same* variable name:

``` bash
# change directory to the analysis path
cd /var/folders/05/lw6x4b813x3_l5mvmn51kvlc0000gn/T//Rtmp8mYthg/somascan-19237bfd1d46

# run the Rscript:
# - we recommend using the --vanilla flag
Rscript --vanilla merge_clin.R ex-data-9.adat clin-data.csv SampleId ex-data-9-merged.adat
```

``` r
dir(analysis_dir)
#> [1] "clin-data.csv"         "ex-data-9-merged.adat"
#> [3] "ex-data-9.adat"        "merge_clin.R"
```

#### Alternative Syntax

In certain instances you may have the common key under a *different*
variable name in their respective files. This is handled by a
modification to argument 3, which now takes the form `key1=key2` where
`key1` contains the common keys in the `*.adat` file, and `key2`
contains keys for the `*.csv` file.

To highlight this syntax, first let’s create a new clinical data file
with a *different* variable name, `ClinID`:

``` r
# rename original `df`
names(df) <- c("ClinID", "letter", "size")
df
#>   ClinID letter       size
#> 1      1      a -0.6264538
#> 2      3      b  0.1836433
#> 3      5      a -0.8356286
#> 4      7      b  1.5952808
#> 5      9      a  0.3295078

# write clinical data to file
withr::with_dir(analysis_dir,
  write.csv(df, file = "clin-data2.csv", row.names = FALSE)
)
```

We can now execute the *same* merge script at the command line with a
slightly modified syntax:

``` bash
Rscript --vanilla merge_clin.R ex-data-9.adat clin-data2.csv SampleId=ClinID ex-data-9-merged2.adat
```

``` r
dir(analysis_dir)
#> [1] "clin-data.csv"          "clin-data2.csv"        
#> [3] "ex-data-9-merged.adat"  "ex-data-9-merged2.adat"
#> [5] "ex-data-9.adat"         "merge_clin.R"
```

### Check Results

Now let’s check that the clinical data was merged successfully and
yields the expected `*.adat`:

``` r
new <- withr::with_dir(analysis_dir,
  read_adat("ex-data-9-merged2.adat")
)
new
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 9
#>      Columns              12
#>      Clinical Data        7
#>      Features             5
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 9 × 13
#>   row_names      PlateId  SlideId Subarray SampleId   Age letter   size
#>   <chr>          <chr>      <dbl>    <dbl> <chr>    <int> <chr>   <dbl>
#> 1 258495800012_3 Example… 2.58e11        3 1           76 a      -0.626
#> 2 258495800004_7 Example… 2.58e11        7 2           55 NA     NA    
#> 3 258495800010_8 Example… 2.58e11        8 3           47 b       0.184
#> 4 258495800003_4 Example… 2.58e11        4 4           37 NA     NA    
#> 5 258495800009_4 Example… 2.58e11        4 5           71 a      -0.836
#> 6 258495800012_8 Example… 2.58e11        8 6           41 NA     NA    
#> 7 258495800001_3 Example… 2.58e11        3 7           36 b       1.60 
#> 8 258495800004_8 Example… 2.58e11        8 8           77 NA     NA    
#> 9 258495800001_8 Example… 2.58e11        8 9           62 a       0.330
#> # ℹ 5 more variables: seq.2977.7 <dbl>, seq.5864.10 <dbl>,
#> #   seq.12358.6 <dbl>, seq.9536.16 <dbl>, seq.3216.2 <dbl>
#> ═══════════════════════════════════════════════════════════════════════

getMeta(new)
#> [1] "PlateId"  "SlideId"  "Subarray" "SampleId" "Age"      "letter"  
#> [7] "size"

getAnalytes(new)
#> [1] "seq.2977.7"  "seq.5864.10" "seq.12358.6" "seq.9536.16"
#> [5] "seq.3216.2"
```

### Summary

- Merging newly obtained clinical variables into existing ‘SomaScan’
  ADATs is easy via the `merge_clin.R` script provided with
  [SomaDataIO](https://CRAN.R-project.org/package=SomaDataIO).
- Alternatively, one could use the exported function
  [`merge_clin()`](https://somalogic.github.io/SomaDataIO/dev/reference/merge_clin.md).
- If you run into any trouble please do not hesitate to reach out to
  <techsupport@somalogic.com> or [file an
  issue](https://github.com/SomaLogic/SomaDataIO/issues/new) on our
  [GitHub](https://github.com/SomaLogic/SomaDataIO) repository.
