# Load ADAT files as a list

Load a series of ADATs and return a list of `soma_adat` objects, one for
each ADAT file. `collapseAdats()` concatenates a list of ADATs from
`loadAdatsAsList()`, while maintaining the relevant attribute entries
(mainly the `HEADER` element). This makes writing out the final object
possible without the loss of `HEADER` information.

## Usage

``` r
loadAdatsAsList(files, collapse = FALSE, verbose = interactive(), ...)

collapseAdats(x)
```

## Arguments

- files:

  A character string of files to load.

- collapse:

  Logical. Should the resulting list of ADATs be collapsed into a single
  ADAT object?

- verbose:

  Logical. Should the function call be run in *verbose* mode.

- ...:

  Additional arguments passed to
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- x:

  A list of `soma_adat` class objects returned from `loadAdatsAsList()`.

## Value

A list of ADATs named by `files`, each a `soma_adat` object
corresponding to an individual file in `files`. For `collapseAdats()`, a
single, collapsed `soma_adat` object.

## Details

- **Note 1**::

  The default behavior is to "vertically bind"
  ([`rbind()`](https://rdrr.io/r/base/cbind.html)) on the *intersect* of
  the column variables, with unique columns silently dropped.

- **Note 2**::

  If "vertically binding" on the column *union* is desired, use
  [`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html),
  however this results in `NAs` in non-intersecting columns. For many
  files with little variable intersection, a sparse RFU-matrix will
  result (and will likely break ADAT attributes):

      adats <- loadAdatsAsList(files)
      union_adat <- dplyr::bind_rows(adats, .id = "SourceFile")

## See also

[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)

Other IO:
[`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md),
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
[`soma_adat`](https://somalogic.github.io/SomaDataIO/dev/reference/soma_adat.md),
[`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)

## Author

Stu Field

## Examples

``` r
# only 1 file in directory
dir(system.file("extdata", package = "SomaDataIO"))
#> [1] "example_data10.adat"

files <- system.file("extdata", package = "SomaDataIO") |>
  dir(pattern = "[.]adat$", full.names = TRUE) |> rev()

adats <- loadAdatsAsList(files)
class(adats)
#> [1] "list"

# collapse into 1 ADAT
collapsed <- collapseAdats(adats)
class(collapsed)
#> [1] "soma_adat"  "data.frame"

# Alternatively use `collapse = TRUE`
# \donttest{
  loadAdatsAsList(files, collapse = TRUE)
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 10
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 10 × 5,319
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
#> # ℹ 5,313 more variables: Subarray <dbl>, SampleId <chr>,
#> #   SampleType <chr>, PercentDilution <int>, SampleMatrix <chr>,
#> #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
#> #   SampleNotes <lgl>, AliquotingNotes <lgl>, …
#> ═══════════════════════════════════════════════════════════════════════
# }
```
