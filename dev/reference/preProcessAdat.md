# Pre-Process an ADAT Object for Analysis

Pre-process an ADAT file containing raw analyte RFU values in
preparation for analysis. For more details please refer to the
[pre-processing how-to
article](https://somalogic.github.io/SomaDataIO/dev/articles/pre-processing.html)

## Usage

``` r
preProcessAdat(
  adat,
  filter.features = TRUE,
  filter.controls = TRUE,
  filter.rowcheck = TRUE,
  filter.qc = deprecated(),
  filter.outliers = FALSE,
  data.qc = NULL,
  log.10 = FALSE,
  center.scale = FALSE
)
```

## Arguments

- adat:

  A `soma_adat` object created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
  including SeqId columns (`seq.xxxxx.xx`) containing raw RFU values.

- filter.features:

  Logical. Should non-human protein features (SeqIds) be dropped?
  Default is `TRUE`.

- filter.controls:

  Logical. Should SomaScan technical control samples be dropped? If
  `TRUE`, this retains all samples where `SampleType = "Sample"` (study
  samples) and discards all others including buffer, calibrator, and QC
  control samples. Default is `TRUE`.

- filter.rowcheck:

  Logical. If `TRUE` only samples that pass default normalization
  acceptance criteria will be retained. Default is `TRUE`.

- filter.qc:

  **\[deprecated\]** Logical. Please use `filter.rowcheck` instead. This
  parameter is deprecated and will be removed in a future version.

- filter.outliers:

  Logical. Should the `adat` object drop outlier samples? An outlier
  sample is defined by \>= 5% of filtered SeqIds exceeding +/- 6 MAD and
  5x fold-change from the median signal. This filter is typically
  appropriate for studies on plasma, serum, and other biological
  matrices generally exhibiting homeostatic characteristics. For studies
  on matrices such as tissue homogenate, cell culture, or study designs
  containing client-provided background lysis buffer controls (or
  similar), this filter will likely not be appropriate. Default is
  `FALSE`. If set to `TRUE` it is highly recommended that
  `filter.controls` is also set to `TRUE`

- data.qc:

  Character. Character vector of variable names for which data QC plots
  are desired. Default is `NULL`, which does not generate any QC plots.
  Note: These plots are for visual inspection only, no samples or
  features are dropped from the output `soma_adat` object.

- log.10:

  Logical. Should the RFU values be log10 transformed? Default is
  `FALSE`.

- center.scale:

  Logical. Should the RFU values be Z-transformed (centered and scaled)?
  Default is `FALSE`. If set to set to `TRUE` it is highly recommended
  that `log.10` is also set to `TRUE`

## Value

A `soma_adat` object.

## Details

The `soma_adat` object is pre-processed with the following steps:

1.  Filter features -\> down to human protein analytes

2.  Filter samples -\> by the following order and criteria: a) Retain
    study samples only (dropping buffer, calibrator, and QC samples) b)
    Only those that pass default normalization acceptance criteria c)
    Those not identified as outliers.

3.  Data QC -\> plots of normalization scale factors by clinical
    covariates

4.  Transformations -\> log10, center, and scale analyte RFU values

## Author

Caleb Scheidel

## Examples

``` r
preProcessAdat(example_data, data.qc = c("Age", "Sex"))
#> ✔ 305 non-human protein features were removed.
#> → 214 human proteins did not pass standard QC
#> acceptance criteria and were flagged in `ColCheck`.
#> ✔ 6 buffer samples were removed.
#> ✔ 10 calibrator samples were removed.
#> ✔ 6 QC samples were removed.
#> ✔ 2 samples flagged in `RowCheck` did not
#> pass standard normalization acceptance criteria (0.4 <= x <= 2.5)
#> and were removed.
#> → Data QC plots were generated:
#> $Age

#> 
#> $Sex

#> 
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 168
#>      Columns              5013
#>      Clinical Data        34
#>      Features             4979
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 168 × 5,014
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
#> 10 258495800009_8 Example… 2020-06-18   SG152144… H10           2.58e11
#> # ℹ 158 more rows
#> # ℹ 5,008 more variables: Subarray <dbl>, SampleId <chr>,
#> #   SampleType <chr>, PercentDilution <int>, SampleMatrix <chr>,
#> #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
#> #   SampleNotes <lgl>, AliquotingNotes <lgl>, …
#> ═══════════════════════════════════════════════════════════════════════
```
