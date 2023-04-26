
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `SomaDataIO` from SomaLogic Operating Co., Inc. <img src="man/figures/logo.png" align="right" height="100" width="100"/>

<!-- badges: start -->

![GitHub
version](https://img.shields.io/badge/Version-6.0.0.9000-success.svg?style=flat&logo=github)
[![CRAN
status](http://www.r-pkg.org/badges/version/SomaDataIO)](https://cran.r-project.org/package=SomaDataIO)
[![](https://cranlogs.r-pkg.org/badges/grand-total/SomaDataIO)](https://cran.r-project.org/package=SomaDataIO)
[![R-CMD-check](https://github.com/SomaLogic/SomaDataIO/workflows/R-CMD-check/badge.svg)](https://github.com/SomaLogic/SomaDataIO/actions)
[![Codecov test
coverage](https://codecov.io/gh/SomaLogic/SomaDataIO/branch/main/graph/badge.svg)](https://app.codecov.io/gh/SomaLogic/SomaDataIO?branch=main)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
<!-- badges: end -->

## Overview

This document accompanies the `SomaDataIO` R package, which loads and
exports ‘SomaScan’ data via the SomaLogic Operating Co., Inc.
proprietary text file called an ADAT (`*.adat`). The package also
exports auxiliary functions for manipulating, wrangling, and extracting
relevant information from an ADAT object once in memory. Basic
familiarity with the R environment is assumed, as is the ability to
install contributed packages from the Comprehensive R Archive Network
(CRAN).

If you run into any issues/problems with `SomaDataIO` full documentation
of the most recent
[release](https://github.com/SomaLogic/SomaDataIO/releases) can be found
at our [pkgdown](https://somalogic.github.io/SomaDataIO/) website hosted
by [GitHub](https://github.com/SomaLogic/SomaDataIO/). If the issue
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

------------------------------------------------------------------------

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
- [crayon](https://cran.r-project.org/package=crayon)
- [dplyr](https://cran.r-project.org/package=dplyr)
- [lifecycle](https://cran.r-project.org/package=lifecycle)
- [magrittr](https://cran.r-project.org/package=magrittr)
- [readxl](https://cran.r-project.org/package=readxl)
- [tibble](https://cran.r-project.org/package=tibble)
- [tidyr](https://cran.r-project.org/package=tidyr)
- [usethis](https://cran.r-project.org/package=usethis)

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

Upon *successful* installation, load the `SomaDataIO` as normal:

``` r
library(SomaDataIO)
```

For an index of available commands:

``` r
library(help = SomaDataIO)
```

------------------------------------------------------------------------

## Objects and Data

The `SomaDataIO` package comes with four (4) objects available to users
to run canned examples (or analyses). They can be accessed once
`SomaDataIO` has been attached via `library()`. They are:

- `example_data`: the original ‘SomaScan’ file (`example_data.adat`) can
  be found [here](https://github.com/SomaLogic/SomaLogic-Data) or
  downloaded directly via:

  ``` bash
  wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/master/example_data.adat
  ```

  - it has been replaced by an abbreviated, light-weight version
    containing only the first 10 samples and can be found at:

    ``` r
    system.file("extdata", "example_data10.adat", package = "SomaDataIO")
    ```

- `ex_analytes`: the analyte (feature) variables in `example_data`

- `ex_anno_tbl`: the annotations table associated with `example_data`

- `ex_target_names`: a mapping object for analyte -\> target

- See also `?SomaScanObjects`

------------------------------------------------------------------------

## Main (I/O) Features

- Loading data (Import)
  - parse and import a `*.adat` text file into an `R` session as a
    `soma_adat` object.
- Wrangling data (manipulation)
  - subset, reorder, and list various fields of a `soma_adat` object.
  - `?SeqId` analyte (feature) matching.
  - `dplyr` and `tidyr` verb S3 methods for the `soma_adat` class.
  - `?rownames` helpers that do not break `soma_adat` attributes.
  - please see vignette
    `vignette("loading-and-wrangling", package = "SomaDataIO")`
- Exporting data (Output)
  - write out a `soma_adat` object as a `*.adat` text file.

## Loading an ADAT

Loading an ADAT text file is simple using `read_adat()`:

``` r
# Sample file name
f <- system.file("extdata", "example_data10.adat",
                 package = "SomaDataIO", mustWork = TRUE)
my_adat <- read_adat(f)
is.soma_adat(my_adat)
#> [1] TRUE

# S3 print method (forwards -> tibble)
my_adat
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
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
#>    row_names     PlateId Plate…¹ Scann…² Plate…³ SlideId Subar…⁴ Sampl…⁵ Sampl…⁶
#>    <chr>         <chr>   <chr>   <chr>   <chr>     <dbl>   <dbl> <chr>   <chr>  
#>  1 258495800012… Exampl… 2020-0… SG1521… H9      2.58e11       3 1       Sample 
#>  2 258495800004… Exampl… 2020-0… SG1521… H8      2.58e11       7 2       Sample 
#>  3 258495800010… Exampl… 2020-0… SG1521… H7      2.58e11       8 3       Sample 
#>  4 258495800003… Exampl… 2020-0… SG1521… H6      2.58e11       4 4       Sample 
#>  5 258495800009… Exampl… 2020-0… SG1521… H5      2.58e11       4 5       Sample 
#>  6 258495800012… Exampl… 2020-0… SG1521… H4      2.58e11       8 6       Sample 
#>  7 258495800001… Exampl… 2020-0… SG1521… H3      2.58e11       3 7       Sample 
#>  8 258495800004… Exampl… 2020-0… SG1521… H2      2.58e11       8 8       Sample 
#>  9 258495800001… Exampl… 2020-0… SG1521… H12     2.58e11       8 9       Sample 
#> 10 258495800004… Exampl… 2020-0… SG1521… H11     2.58e11       3 170261  Calibr…
#> # … with 5,310 more variables: PercentDilution <int>, SampleMatrix <chr>,
#> #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>, SampleNotes <lgl>,
#> #   AliquotingNotes <lgl>, SampleDescription <chr>, AssayNotes <lgl>,
#> #   TimePoint <lgl>, …, and abbreviated variable names ¹​PlateRunDate,
#> #   ²​ScannerID, ³​PlatePosition, ⁴​Subarray, ⁵​SampleId, ⁶​SampleType
#> ════════════════════════════════════════════════════════════════════════════════
```

Please see vignette
`vignette("loading-and-wrangling", package = "SomaDataIO")` for more
details and options.

## Wrangling

The `soma_adat` class comes with numerous class-specific S3 methods to
the most popular [dplyr](https://dplyr.tidyverse.org) and
[tidyr](https://tidyr.tidyverse.org) generics.

``` r
# see full complement of `soma_adat` methods
methods(class = "soma_adat")
#>  [1] [            [[           [[<-         [<-          ==          
#>  [6] $            $<-          anti_join    arrange      count       
#> [11] filter       full_join    getAnalytes  getMeta      group_by    
#> [16] inner_join   is_seqFormat left_join    Math         median      
#> [21] merge        mutate       Ops          print        rename      
#> [26] right_join   sample_frac  sample_n     semi_join    separate    
#> [31] slice_sample slice        summary      Summary      transform   
#> [36] ungroup      unite       
#> see '?methods' for accessing help and source code
```

Please see vignette
`vignette("loading-and-wrangling", package = "SomaDataIO")` for more
details about available `soma_adat` methods.

## ADAT structure

The `soma_adat` object also contains specific structure that are useful
to users. Please also see `?colmeta` or `?annotations` for further
details about these fields.

------------------------------------------------------------------------

## Typical ‘SomaScan’ Analysis

This section now lives in individual package vignettes. For further
detail please see:

- Two-group comparison (e.g. differential expression) via *t*-test
  - see vignette
    `vignette("two-group-comparison", package = "SomaDataIO")`
- Binary classification
  - see vignette
    `vignette("binary-classification", package = "SomaDataIO")`
- Linear regression
  - see vignette `vignette("linear-regression", package = "SomaDataIO")`

------------------------------------------------------------------------

## MIT LICENSE

- See
  [LICENSE](https://github.com/SomaLogic/SomaDataIO/blob/main/LICENSE.md)
- The MIT License:
  - <https://choosealicense.com/licenses/mit/>
  - [https://www.tldrlegal.com/license/mit-license/](https://www.tldrlegal.com/license/mit-license)

------------------------------------------------------------------------

Created by [Rmarkdown](https://github.com/rstudio/rmarkdown) (v2.20) and
R version 4.2.2 (2022-10-31).
