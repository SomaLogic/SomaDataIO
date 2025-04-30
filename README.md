
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SomaDataIO <a href="https://somalogic.github.io/SomaDataIO/"><img src="man/figures/logo.png" align="right" height="138" alt="SomaDataIO website" /></a>

<!-- badges: start -->

![GitHub
version](https://img.shields.io/badge/Version-6.2.0.9000-success.svg?style=flat&logo=github)
[![CRAN
status](http://www.r-pkg.org/badges/version/SomaDataIO)](https://cran.r-project.org/package=SomaDataIO)
[![Downloads](https://cranlogs.r-pkg.org/badges/SomaDataIO)](https://cran.r-project.org/package=SomaDataIO)
[![R-CMD-check](https://github.com/SomaLogic/SomaDataIO/workflows/R-CMD-check/badge.svg)](https://github.com/SomaLogic/SomaDataIO/actions)
[![Codecov test
coverage](https://codecov.io/gh/SomaLogic/SomaDataIO/branch/main/graph/badge.svg)](https://app.codecov.io/gh/SomaLogic/SomaDataIO?branch=main)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
<!-- badges: end -->

The `SomaDataIO` R package loads and exports ‘SomaScan’ data via the
Standard BioTools, Inc. structured text file called an ADAT (`*.adat`).
The package also exports auxiliary functions for manipulating,
wrangling, and extracting relevant information from an ADAT object once
in memory. Basic familiarity with the R environment is assumed, as is
the ability to install contributed packages from the Comprehensive R
Archive Network (CRAN).

If you run into any issues/problems with `SomaDataIO` full documentation
of the most recent
[release](https://github.com/SomaLogic/SomaDataIO/releases) can be found
at our [website of articles and
workflows](https://somalogic.github.io/SomaDataIO/). If the issue
persists we encourage you to consult the
[issues](https://github.com/SomaLogic/SomaDataIO/issues/) page and, if
appropriate, submit an issue and/or feature request.

------------------------------------------------------------------------

## Usage

The `SomaDataIO` package is licensed under the
[MIT](https://github.com/SomaLogic/SomaDataIO/blob/main/LICENSE.md)
license and is intended solely for research use only (“RUO”) purposes.
The code contained herein may *not* be used for diagnostic, clinical,
therapeutic, or other commercial purposes.

## Installation

The easiest way to install `SomaDataIO` is to install directly from
CRAN:

``` r
install.packages("SomaDataIO")
```

Alternatively from GitHub:

``` r
remotes::install_github("SomaLogic/SomaDataIO")
```

which installs the most current “development” version from the
repository `HEAD`. To install the *most recent* release, use:

``` r
remotes::install_github("SomaLogic/SomaDataIO@*release")
```

To install a *specific* tagged release, use:

``` r
remotes::install_github("SomaLogic/SomaDataIO@v5.3.0")
```

#### Package Dependencies

The `SomaDataIO` package was intentionally developed to contain a
limited number of dependencies from CRAN. This makes the package more
stable to external software design changes but also limits its contained
feature set. With this in mind, `SomaDataIO` aims to strike a balance
providing long(er)-term stability and a limited set of features. Below
are the package dependencies (see also the
[DESCRIPTION](https://github.com/SomaLogic/SomaDataIO/blob/main/DESCRIPTION)
file):

- [R (\>= 4.1.0)](https://cran.r-project.org/)
- [cli](https://cran.r-project.org/package=cli)
- [dplyr](https://cran.r-project.org/package=dplyr)
- [ggplot2](https://cran.r-project.org/package=ggplot2)
- [lifecycle](https://cran.r-project.org/package=lifecycle)
- [magrittr](https://cran.r-project.org/package=magrittr)
- [readxl](https://cran.r-project.org/package=readxl)
- [tibble](https://cran.r-project.org/package=tibble)
- [tidyr](https://cran.r-project.org/package=tidyr)

#### Biobase

The `Biobase` package is *suggested*, being required by only two
functions, `pivotExpressionSet()` and `adat2eSet()`.
[Biobase](https://www.bioconductor.org/packages/release/bioc/html/Biobase.html)
must be installed separately from
[Bioconductor](https://www.bioconductor.org) by entering the following
from the `R` Console:

``` r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("Biobase", version = remotes::bioc_version())
```

Information about Bioconductor can be found here:
<https://bioconductor.org/install/>

#### Loading

Upon *successful* installation, load `SomaDataIO` as normal:

``` r
library(SomaDataIO)
```

For an index of available commands:

``` r
library(help = SomaDataIO)
```

------------------------------------------------------------------------

## Objects and Data

The `SomaDataIO` package comes with five (5) objects available to users
to run canned examples (or analyses). They can be accessed once
`SomaDataIO` has been attached via `library()`. They are:

- `example_data`: the original ‘SomaScan’ file (`example_data.adat`) can
  be found [here](https://github.com/SomaLogic/SomaLogic-Data) or
  downloaded directly via:

  ``` bash
  wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/main/example_data.adat
  ```

  - within `SomaDataIO` it has been replaced by an abbreviated,
    light-weight version containing only the first 10 samples:

    ``` r
    dir(system.file("extdata", package = "SomaDataIO"), full.names = TRUE)
    ```

- `ex_analytes`: the analyte (feature) variables in `example_data`

- `ex_anno_tbl`: the annotations table associated with `example_data`

- `ex_target_names`: a mapping object for analyte -\> target

- `ex_clin_data`: a table containing variables `SampleId`,
  `smoking_status` and `alcohol_use` to demonstrate merging clinical
  sample annotation information to a `soma_adat` object

- See also `?SomaScanObjects`

------------------------------------------------------------------------

## Main (I/O) Features

- Loading data (Import)
  - parse and import a `*.adat` text file into an `R` session as a
    `soma_adat` object.
- Wrangling data (manipulation)
  - subset, reorder, and list various fields of a `soma_adat` object.
  - `?SeqId` analyte (feature) matching.
  - [dplyr](https://dplyr.tidyverse.org) and
    [tidyr](https://tidyr.tidyverse.org) verb S3 methods for the
    `soma_adat` class.
  - `?rownames` helpers that do not break `soma_adat` attributes.
  - please see the article [Loading and Wrangling
    ‘SomaScan’](https://somalogic.github.io/SomaDataIO/articles/tips-loading-and-wrangling.html)
- Exporting data (Output)
  - write out a `soma_adat` object as a `*.adat` text file.

## Loading an ADAT

Loading an ADAT text file is simple using `read_adat()`:

``` r
# Note: This `system.file()` command returns a filepath to the `example_data10` 
# object in the `SomaDataIO` package
adat_path <- system.file("extdata", "example_data10.adat",
                         package = "SomaDataIO", mustWork = TRUE)
adat_path
#> [1] "/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/SomaDataIO/extdata/example_data10.adat"

# `adat_path` should be the elaborated path and file name of the *.adat file to
# be loaded into the R workspace from your local file system
# (e.g. adat_path = "PATH_TO_ADAT/my_adat.adat")
my_adat <- read_adat(file = adat_path)

# test object class
is.soma_adat(my_adat)
#> [1] TRUE

# S3 print method (forwards -> tibble)
my_adat
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 10
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
#> ℹ EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
#> ℹ CalReference, Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ──────────────────────────────────────────────────────────────────────
#> # A tibble: 10 × 5,319
#>    row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId Subarray
#>    <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>    <dbl>
#>  1 258495800012_3 Example… 2020-06-18   SG152144… H9            2.58e11        3
#>  2 258495800004_7 Example… 2020-06-18   SG152144… H8            2.58e11        7
#>  3 258495800010_8 Example… 2020-06-18   SG152144… H7            2.58e11        8
#>  4 258495800003_4 Example… 2020-06-18   SG152144… H6            2.58e11        4
#>  5 258495800009_4 Example… 2020-06-18   SG152144… H5            2.58e11        4
#>  6 258495800012_8 Example… 2020-06-18   SG152144… H4            2.58e11        8
#>  7 258495800001_3 Example… 2020-06-18   SG152144… H3            2.58e11        3
#>  8 258495800004_8 Example… 2020-06-18   SG152144… H2            2.58e11        8
#>  9 258495800001_8 Example… 2020-06-18   SG152144… H12           2.58e11        8
#> 10 258495800004_3 Example… 2020-06-18   SG152144… H11           2.58e11        3
#> # ℹ 5,312 more variables: SampleId <chr>, SampleType <chr>,
#> #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
#> #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
#> #   SampleDescription <chr>, …
#> ════════════════════════════════════════════════════════════════════════════════
```

Please see the article [Loading and Wrangling
SomaScan](https://somalogic.github.io/SomaDataIO/articles/tips-loading-and-wrangling.html)
for more details and options.

## Wrangling

The `soma_adat` class comes with numerous class-specific S3 methods to
the most popular [dplyr](https://dplyr.tidyverse.org) and
[tidyr](https://tidyr.tidyverse.org) generics.

``` r
# see full complement of `soma_adat` methods
methods(class = "soma_adat")
#>  [1] [              [[             [[<-           [<-            ==            
#>  [6] $              $<-            anti_join      arrange        count         
#> [11] filter         full_join      getAdatVersion getAnalytes    getMeta       
#> [16] group_by       inner_join     is_seqFormat   left_join      Math          
#> [21] median         merge          mutate         Ops            print         
#> [26] rename         right_join     row.names<-    sample_frac    sample_n      
#> [31] semi_join      separate       slice_sample   slice          summary       
#> [36] Summary        transform      ungroup        unite         
#> see '?methods' for accessing help and source code
```

#### Merging Sample Annotation Data

The `example_data` object includes some sample annotation data built-in,
with the variables `Age` and `Sex` included for clinical samples, but in
practice ADAT files generally do not have any clinical or sample
annotation data fields included.

To merge sample annotation data into an existing `soma_adat` class
object, use the `left_join()` method. Here, joining the `ex_clin_data`
object adds in two additional clinical variables, `smoking_status` and
`alcohol_use`:

``` r
# `clin_path` should be the elaborated path and file name of the *.csv or
# similar file to be loaded into the R workspace from your local file system
# (e.g. clin_path = "PATH_TO_CLIN/clin_data.csv")
# clin_data <- readr::read_csv(clin_path)

merged_adat <- my_adat |> 
  dplyr::left_join(ex_clin_data, by = "SampleId") 

merged_adat |> 
  dplyr::select(SampleId, Age, Sex, smoking_status, alcohol_use) |> 
  head(n = 3)
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 3
#>      Columns              5
#>      Clinical Data        5
#>      Features             0
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
#> ℹ EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
#> ℹ CalReference, Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ──────────────────────────────────────────────────────────────────────
#> # A tibble: 3 × 6
#>   row_names      SampleId   Age Sex   smoking_status alcohol_use
#>   <chr>          <chr>    <int> <chr> <chr>          <chr>      
#> 1 258495800012_3 1           76 F     Never          Yes        
#> 2 258495800004_7 2           55 F     Never          Yes        
#> 3 258495800010_8 3           47 M     Never          No         
#> ════════════════════════════════════════════════════════════════════════════════
```

Please see the article [Loading and Wrangling
SomaScan](https://somalogic.github.io/SomaDataIO/articles/tips-loading-and-wrangling.html)
for more details about available `soma_adat` methods.

## ADAT structure

The `soma_adat` object also contains specific structure that are useful
to users. Please also see `?colmeta` or `?annotations` for further
details about these fields.

------------------------------------------------------------------------

## Typical ‘SomaScan’ Analysis

This section now lives in individual package articles. For further
detail please see:

- Two-group comparison (e.g. differential expression) via *t*-test
  - see `stats::t.test()`
  - see workflow: [Two-Group
    Comparison](https://somalogic.github.io/SomaDataIO/articles/stat-two-group-comparison.html)
- Multi-group comparison (e.g. differential expression) via ANOVA
  - see `stats::aov()`
  - see workflow: [ANOVA Three-Group
    Analysis](https://somalogic.github.io/SomaDataIO/articles/stat-three-group-analysis-anova.html)
- Binary classification
  - see `stats::glm()`
  - see workflow: [Binary
    Classification](https://somalogic.github.io/SomaDataIO/articles/stat-binary-classification.html)
- Linear regression
  - see `stats::lm()`
  - see workflow: [Linear
    Regression](https://somalogic.github.io/SomaDataIO/articles/stat-linear-regression.html)

Note that, in an effort to reduce package size and dependencies, these
articles and workflows are only accessible via the `SomaDataIO`
`pkgdown` website, and are not included with the installed package.

------------------------------------------------------------------------

## MIT LICENSE

- See:
  - [LICENSE](https://github.com/SomaLogic/SomaDataIO/blob/main/LICENSE.md)
- The MIT license:
  - <https://choosealicense.com/licenses/mit/>
  - [https://www.tldrlegal.com/license/mit-license/](https://www.tldrlegal.com/license/mit-license)
- Further:
  - “SomaDataIO” and “SomaLogic” are trademarks owned by Standard
    BioTools, Inc. No license is hereby granted to these trademarks
    other than for purposes of identifying the origin or source of this
    Software.
