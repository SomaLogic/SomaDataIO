# Changelog

## SomaDataIO 6.3.0

CRAN release: 2025-05-06

#### New Functions

- Added
  [`preProcessAdat()`](https://somalogic.github.io/SomaDataIO/dev/reference/preProcessAdat.md)
  function
  - added new function
    [`preProcessAdat()`](https://somalogic.github.io/SomaDataIO/dev/reference/preProcessAdat.md)
    to filter features, filter samples, generate data QC plots of
    normalization scale factors by covariates, and perform standard
    analyte RFU transformations including log10, centering, and scaling
- Added
  [`calcOutlierMap()`](https://somalogic.github.io/SomaDataIO/dev/reference/calcOutlierMap.md)
  function
  - added
    [`calcOutlierMap()`](https://somalogic.github.io/SomaDataIO/dev/reference/calcOutlierMap.md)
    and its print and plot S3 methods, along with
    [`getOutlierIds()`](https://somalogic.github.io/SomaDataIO/dev/reference/getOutlierIds.md)
    for identifying sample level outliers from outlier map object
  - added `ggplot2` as a package dependency

#### Function and Object Improvements

- Added `ex_clin_data` object
  - a `tibble` object with additional sample annotation fields
    `smoking_status` and `alcohol_use` to demonstrate merging to a
    `soma_adat` object

#### Documentation Updates

- Added pre-processing vignette article
  - includes guidance on pre-processing SomaScan data for a typical
    analysis
  - provides an example of recommended workflow of filtering features,
    filtering samples, performing data QC checks, and transformations of
    RFU features
  - introduces usage of the
    [`preProcessAdat()`](https://somalogic.github.io/SomaDataIO/dev/reference/preProcessAdat.md)
    function
- Improved adat ingest documentation in `README`
  - added comments to clarify file path input to
    [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
    example in `README`
- Updated stat workflow articles to begin with reading in adat
  - updated data preparation chunks with comments about how to download
    and read in the the `example_data.adat` object
  - data preparation chunks now use the
    [`preProcessAdat()`](https://somalogic.github.io/SomaDataIO/dev/reference/preProcessAdat.md)
    function for pre-processing
- Added sample annotation merging guidance
  - updated `README` and loading and wrangling vignette article with
    section including code to join the `ex_clin_data` object to the
    `example_data` adat

#### Internal 🚧

- Added helper utility functions for snapshot plot unit tests
  - added helper utility functions `figure()`, `close_figure()`,
    `save_png()`, and `expect_snapshot_plot()` for saving plot snapshot
    output to `testthat/helper.R`
  - added snapshot unit tests for
    [`preProcessAdat()`](https://somalogic.github.io/SomaDataIO/dev/reference/preProcessAdat.md)
    messaging, print and QC plot output

## SomaDataIO 6.2.0

CRAN release: 2025-02-06

#### New Functions

- Added
  [`calc_eLOD()`](https://somalogic.github.io/SomaDataIO/dev/reference/calc_eLOD.md)
  function ([\#131](https://github.com/SomaLogic/SomaDataIO/issues/131))
  - calculates the estimated limit of detection (eLOD) for SeqId columns
    of an input `soma_adat` or `data.frame`

#### Bug Fixes

- Fixed `crayon` bug and `ui_bullet()` issue
  ([\#129](https://github.com/SomaLogic/SomaDataIO/issues/129),
  [\#130](https://github.com/SomaLogic/SomaDataIO/issues/130))
  - removed `crayon` and `usethis` as dependencies in favor of `cli`
  - fixed bug in R version 4.4.1 with `ui_bullet()` internal calls
    within
    [`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md)
    and
    [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
- Fixed bug in
  [`Summary.soma_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/groupGenerics.md)
  operations
  ([\#121](https://github.com/SomaLogic/SomaDataIO/issues/121))
  - these operations: [`min()`](https://rdrr.io/r/base/Extremes.html),
    [`max()`](https://rdrr.io/r/base/Extremes.html),
    [`any()`](https://rdrr.io/r/base/any.html),
    [`range()`](https://rdrr.io/r/base/range.html), etc. would return
    the incorrect value due to an
    [`as.matrix()`](https://rdrr.io/r/base/matrix.html) conversion under
    the hood
  - now skips that conversion, trips a warning, and carries on
  - triggers an error if non-numerics are passed as part of the ‘…’
    outside of a `soma_adat`, just like
    [`Summary.data.frame()`](https://rdrr.io/r/base/groupGeneric.html)

#### Function and Object Improvements

- [`collapseAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md)
  now maintains Cal.Set entries of Col.Meta
  ([\#113](https://github.com/SomaLogic/SomaDataIO/issues/113))
  - collapsing ADATs can be problematic for the attributes, especially
    for large numbers of ADATs
  - [`collapseAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md)
    now attempts to smartly merge the (potentially numerous elements)
    Col.Meta attribute in the final object, preserving the “Cal.Set” and
    “ColCheck” columns in particular
  - the resulting `Col.Meta` attribute is a combined product of the
    individual ADAT elements, and the *intersect* of the analyte
    features (as is the case for the
    [`rbind()`](https://rdrr.io/r/base/cbind.html) that is called)
- Updated checksums and versions for Annotations Excel files
  ([\#116](https://github.com/SomaLogic/SomaDataIO/issues/116))
  - updated the 7k and 11k file versions and md5sum checksums
  - now allows
    [`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md)
    to load the individual Excel files
- Updated `lift_master` object to alpha sort columns

#### Documentation Updates

- Updated company name, license year, and maintainer
  ([\#137](https://github.com/SomaLogic/SomaDataIO/issues/137))
  - SomaLogic Operating Co., Inc is now Standard BioTools, Inc.
  - updated license and copyright year to 2025
  - updated package maintainer to Caleb Scheidel
- Updated article links in README, intro vignette
  ([\#123](https://github.com/SomaLogic/SomaDataIO/issues/123))
  - updated links to articles in README and introduction vignette to
    URLs to pkgdown website rather than
    [`vignette()`](https://rdrr.io/r/utils/vignette.html) code
    references
  - added clarification to above documents that articles are available
    on website only rather than traditional vignettes included with
    package
- Updates to example documentation
  - [`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md)
    example documentation now points to the most recent 11k Excel
    annotations file
  - [`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md)
    example now prints list elements separately, rather than full
    object, which slowed website rendering

#### Internal 🚧

- Updates to GitHub Action workflows
  - added `rhub.yaml` configuration file to comply with `rhub` v2
  - updated macOS version in `pkgdown.yaml` to macOS-14
  - added write permission to `pkgdown.yaml` file to enable deployment
  - changed GitHub Action R checks to MacOS and Windows only
    - `ubuntu` machine was taking too long to build
- Increased package test coverage
  - added unit tests for
    [`getSomaScanLiftCCC()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md),
    `parseCheck()` and release utilities which were previously untested
  - increased test coverage for
    [`pivotExpressionSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/pivotExpressionSet.md)
- Added missing package anchors to .Rd files
  ([\#139](https://github.com/SomaLogic/SomaDataIO/issues/139))
  - fixed note from remote windows check related to Rd targets missing
    package anchors
- Updated README badge
  ([\#109](https://github.com/SomaLogic/SomaDataIO/issues/109))
  - now shows ‘downloads’ per month over total downloads
- Fixed link in DESCRIPTION; master -\> main
  ([\#107](https://github.com/SomaLogic/SomaDataIO/issues/107))

## SomaDataIO 6.1.0 🥳 🍾

CRAN release: 2024-03-26

#### Lifting Code 🚀

- Major restructure of
  [`lift_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md)
  functionality ([@stufield](https://github.com/stufield),
  [\#81](https://github.com/SomaLogic/SomaDataIO/issues/81),
  [\#78](https://github.com/SomaLogic/SomaDataIO/issues/78))
  - [`lift_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md)
    now takes a `bridge =` argument, replacing the `anno.tbl =`
    argument. Lifting is now performed internally for a better (and
    safer) user experience, without the necessity of an external
    annotations (Excel) file.
  - the majority of this refactoring was internal and the user should
    not experience a major disruption to the API.
  - much improved lifting/bridging documentation
    ([\#82](https://github.com/SomaLogic/SomaDataIO/issues/82))
- Added a new lifting and bridging vignette
  ([@stufield](https://github.com/stufield),
  [\#77](https://github.com/SomaLogic/SomaDataIO/issues/77))
  - in addition to the improved lifting documentation this new vignette
    provides additional context, explanation, clear examples, and
    lifting guidance.

#### New Functions ✨

- [`is_lifted()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md)
  is new and returns a boolean according to whether the signal space
  (RFU) has been previously lifted

- Lifting accessor function for Lin’s CCC values
  ([\#88](https://github.com/SomaLogic/SomaDataIO/issues/88))

  - [`getSomaScanLiftCCC()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
    accesses the lifting correlations between SomaScan versions for each
    analyte
  - returns a `tibble` split by sample matrix (serum or plasma)

- [`merge_clin()`](https://somalogic.github.io/SomaDataIO/dev/reference/merge_clin.md)
  is newly exported
  ([\#80](https://github.com/SomaLogic/SomaDataIO/issues/80))

  - a thin wrapper that allows users to merge clinical variables to
    `soma_adat` objects easily
  - previously users had to either use the CLI merge tool or merge in
    clinical variables themselves with `dplyr`

- Newly exported ADAT “get\*\*” helpers
  ([\#83](https://github.com/SomaLogic/SomaDataIO/issues/83))

  - functions to access properties of ADATs
    - [`getAdatVersion()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
    - [`getSomaScanVersion()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
    - [`getSignalSpace()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
    - [`checkSomaScanVersion()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
  - [`getAdatVersion()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
    gets a new S3 method
    ([\#92](https://github.com/SomaLogic/SomaDataIO/issues/92))
    - this enables passing of different objects
    - namely `soma_adat` or `list` depending on the situation

- Newly exported functions that were previously internal only:

  - [`addAttributes()`](https://somalogic.github.io/SomaDataIO/dev/reference/addAttributes.md)
  - [`addClass()`](https://somalogic.github.io/SomaDataIO/dev/reference/addClass.md)
  - [`cleanNames()`](https://somalogic.github.io/SomaDataIO/dev/reference/cleanNames.md)

#### New Vignettes 🤓

- The package `README` is now simplified
  ([\#35](https://github.com/SomaLogic/SomaDataIO/issues/35))
  - example analysis workflows are now split out into their own
    vignettes/articles and cross-linked in the `README`
- Reorganization and expansion of statistical vignettes
  ([\#35](https://github.com/SomaLogic/SomaDataIO/issues/35),
  [\#47](https://github.com/SomaLogic/SomaDataIO/issues/47))
  - moved 3 existing statistical examples from `README` into their own
    vignettes
  - resulting in four new “Statistical Workflow” vignettes/articles:
    - Binary classification via logistic regression
    - Linear regression for continuous variables
    - Two-group comparison via *t*-test
    - Three-group analysis ANOVA
- Added new general analysis workflow vignettes
  - articles for the pkgdown website have been built out
  - new articles on:
    - safely mapping values among variables
    - safely renaming a data frame
    - loading-and-wrangling
    - typical train and test data splits
    - beginning the FAQs and/or Coming Soon pages
- Added a new vignette describing how to use the command-line interface
  merge tool ([\#45](https://github.com/SomaLogic/SomaDataIO/issues/45))
  - the new CLI merge tool used to add new clinical data to existing
    ADAT file

#### Updates and Improvements 🔨

- [`collapseAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md)
  better combines `HEADER` information
  ([\#86](https://github.com/SomaLogic/SomaDataIO/issues/86))

  - certain information, e.g. `PlateScale` and `Cal*`, are better
    maintained in the final collapsed ADAT
  - other entries are combined by pasting into a single string
  - should result in less duplication of superfluous entries and
    retention of more “useful” `HEADER` information in the resulting
    (collapsed) `soma_adat`

- Update
  [`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md)
  with `11k` content
  ([\#85](https://github.com/SomaLogic/SomaDataIO/issues/85))

- Update
  [`transform()`](https://somalogic.github.io/SomaDataIO/dev/reference/transform.md)
  and `scaleAnalytes()`

  - `scaleAnalytes()` (internal) now skips missing references and is
    much more like a “step” in the `recipes` package
  - [`transform()`](https://somalogic.github.io/SomaDataIO/dev/reference/transform.md)
    gets edge case protection with `drop = FALSE` in case a
    single-analyte `soma_adat` is scaled.

- New [`row.names()`](https://rdrr.io/r/base/row.names.html) S3 method
  support for `soma_adat` class

  - dispatched on calls to `rownmaes()`
  - rather than calling
    [`NextMethod()`](https://rdrr.io/r/base/UseMethod.html) which
    normally would invoke `data.frame`, we now force the `data.frame`
    method in case there are `tbl_df` or `grouped_df` classes present
    that would be dispatched. Those are bypassed in favor of the
    `data.frame` because `tbl_df` 1) can nuke the attributes, 2)
    triggers a warning about adding rownames to a `tibble`.

- New `grouped_df` S3 print support for the grouped `soma_adat`

  - now displays Grouping information from a call to the S3 print method
    for `soma_adat` class

- New `grouped_df` S3 method support for `soma_adat` class
  ([\#66](https://github.com/SomaLogic/SomaDataIO/issues/66))

  - `grouped_df` data objects previously unsupported and were
    interfering with downstream S3 methods for `dplyr` verbs once
    [`NextMethod()`](https://rdrr.io/r/base/UseMethod.html) was called
  - this support now ensures that the group methods are maintained, as
    well as the `soma_adat` class itself (and most importantly, with its
    attributes intact)

- `tidyr::separate.soma_adat()` S3 method was simplified
  ([\#72](https://github.com/SomaLogic/SomaDataIO/issues/72))

  - now uses `%||%` helper internally
  - expanded error messages inside
    [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) to be more
    informative

- [`is_intact_attr()`](https://somalogic.github.io/SomaDataIO/dev/reference/is_intact_attr.md)
  is now *much* quieter, signaling only when called indirectly
  ([\#71](https://github.com/SomaLogic/SomaDataIO/issues/71))

  - new conditional logic to silences signaling messages when called
    from within another function (indirectly)
  - these previously lead to confusing messages when they appear in
    wrappers, where
    [`is_intact_attr()`](https://somalogic.github.io/SomaDataIO/dev/reference/is_intact_attr.md)
    can be, sometimes deeply, nested in the call stack

- Development and improvements to the `pkgdown` website

  - added new links and improved clarity in YAML
  - added new logo at footer
  - restyled side bar for easier hyperlinking and getting help
  - clicking on the SomaLogic logo in the GitHub `README` now links to
    the `pkgdown` website
  - new “Coming Soon” drop-down section in the website header to let
    users know about active progress (but not yet ready for external
    publication)

- `SomaDataIO` no longer depends on `desc` package

  - to generate the `README.md`

#### Internal 🚧

- Internal rowname helpers were upgraded
  - they now use internal cross-functions as originally intended to
    avoid redundancy, efficiency, and improved debugging
- `sysdata.rda` no longer contains non-exported functions
  ([\#59](https://github.com/SomaLogic/SomaDataIO/issues/59))
  - new internal helper functions:
    - `convertColMeta()`
    - `genRowNames()`
    - `parseCheck()`
    - `syncColMeta()`
    - `scaleAnalytes()`
- Bug-fix for corner-case writing a single-analyte ADAT
  ([\#51](https://github.com/SomaLogic/SomaDataIO/issues/51))
  - RFU values are rounded to 1 decimal place when written by
    [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md),
    via a call to [`apply()`](https://rdrr.io/r/base/apply.html), which
    expects a 2-dim object when replacing those values.
  - [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    no longer uses [`apply()`](https://rdrr.io/r/base/apply.html) and
    instead converts the entire RFU data frame to a matrix (maintains
    original dimensions), and use vectorized format conversion via
    [`sprintf()`](https://rdrr.io/r/base/sprintf.html)
  - in theory this should be faster because
    [`sprintf()`](https://rdrr.io/r/base/sprintf.html) is only called
    once on a long vector, rather than 1000s of times on shorter vectors
    (inside [`apply()`](https://rdrr.io/r/base/apply.html)).
- Fixed missing closing parenthesis in `SomaScanObjects.R` (thanks
  [@Hijinx725](https://github.com/Hijinx725)!,
  [\#40](https://github.com/SomaLogic/SomaDataIO/issues/40))

## SomaDataIO 6.0.0 🎉

CRAN release: 2023-03-15

- We are now on CRAN! 🥳

#### New changes

- New clinical data merge CLI tool
  ([@stufield](https://github.com/stufield),
  [\#25](https://github.com/SomaLogic/SomaDataIO/issues/25))
  - `Rscript --vanilla merge_clin.R` for merging clinical variables into
    existing `*.adat` SomaScan data files
  - added 2 new example `meta.csv` and `meta2.csv` files to run examples
    with random data but with valid index keys
  - see `dir(system.file("cli", "merge", package = "SomaDataIO"))`
- Package data objects ([@stufield](https://github.com/stufield),
  [\#32](https://github.com/SomaLogic/SomaDataIO/issues/32))
  - `example_data.adat` was reduced in size to `n = 10` samples
    (from 192) to conform to CRAN size requirements (\< 5MB)
  - the current file was renamed `example_data10.adat` to reflect this
    change
  - this likely has far-reaching consequences for users who access this
    flat file via
    [`system.file()`](https://rdrr.io/r/base/system.file.html)
  - the `example_data` object itself however remains true to its
    original file
    (`https://github.com/SomaLogic/SomaLogic-Data/blob/master/example_data.adat`)
  - the directory location `inst/example/` was renamed `inst/extdata/`
    to conform to CRAN package standard naming conventions
  - the file `single_sample.adat` was removed from package data as it is
    now redundant (however still used in unit testing)
  - `SomaDataObjects` was renamed and is now `SomaScanObjects`
- Gradual deprecation ([@stufield](https://github.com/stufield))
  - [`read.adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
    is now soft-deprecated; please use `read_adat() instead`
  - lifecycle for soft-deprecated `warn()` -\>
    [`stop()`](https://rdrr.io/r/base/stop.html) for functions that have
    been been soft deprecated since `v5.0.0`
    - [`getSomamers()`](https://somalogic.github.io/SomaDataIO/dev/reference/SomaDataIO-deprecated.md)
    - [`getSomamerData()`](https://somalogic.github.io/SomaDataIO/dev/reference/SomaDataIO-deprecated.md)
    - [`meltExpressionSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/pivotExpressionSet.md)
- New S3 print method default ([@stufield](https://github.com/stufield))
  - `tibble` has new `max_extra_cols =` argument, which is set to `6`
    for the `print.soma_adat` method
- New S3 merge method ([@stufield](https://github.com/stufield),
  [\#31](https://github.com/SomaLogic/SomaDataIO/issues/31))
  - calling [`base::merge()`](https://rdrr.io/r/base/merge.html) on a
    `soma_adat` is strongly discouraged
  - we now redirect users to use `dplyr::*_join()` alternatives which
    are designed to preserve `soma_adat` attributes
- Code hardening for `prepHeaderMeta()`
  ([@stufield](https://github.com/stufield))
  - some ADATs do not have `CreatedDate` and `CreatedBy` in the HEADER
    entry. This currently breaks the writer
  - simplified to make more robust but also refactor to be more
    convenient (for abnormal ADATs not generated by standard SomaScan
    processing)
  - `CreatedDateHistory` was removed as an entry from written ADATs
  - `CreatedByHistory` was combined and dated for written ADATs
  - `NULL` behavior remains if keys are missing
  - `CreatedBy` and `CreatedDate` will be generated either as new
    entries or over-written as appropriate
- Numerous non-user-facing (API) changes internal package maintenance,
  efficiency, and structural upgrades were included

## SomaDataIO 5.3.1

- Bug-fix release related to
  [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md):

  - fixed bug in
    [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    that resulted from adding/removing clinical (non-SomaScan) variables
    to an ADAT. Export via
    [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    resulted in a broken ADAT file
    ([@stufield](https://github.com/stufield),
    [\#18](https://github.com/SomaLogic/SomaDataIO/issues/18))
  - [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    now has much higher fidelity to original text file (`*.adat`) in
    full-cycle read-write-read operations; particularly in presence of
    bangs (`!`) in the Header section and in floating point decimals in
    the
    [`?Col.Meta`](https://somalogic.github.io/SomaDataIO/dev/reference/Col.Meta.md)
    section
  - [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    no longer converts commas (`,`) to semi-colons (`;`) in the
    [`?Col.Meta`](https://somalogic.github.io/SomaDataIO/dev/reference/Col.Meta.md)
    block (originally introduced to avoid cell alignment issues in
    `*.csv` formats)
  - [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    no longer concatenates written ADATs, when writing to the same file.
    Data is over-written to file to avoid mangled ADATs resulting from
    re-writing to the same connection and to match the default behavior
    of [`write.table()`](https://rdrr.io/r/utils/write.table.html),
    [`write.csv()`](https://rdrr.io/r/utils/write.table.html), etc.

- [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
  now has more consistent character type the `Barcode2` variable in
  standard ADATs, now forces `character` class, does not allow R’s
  [`read.delim()`](https://rdrr.io/r/utils/read.table.html) to “guess”
  the type

- Decreased dependency of `magrittr` pipes (`%>%`) in favor of the
  native R pipe (`|>`). As a result the package now depends on
  `R >= 4.1.0`

  - `SomaDataIO` will continue to re-export `magrittr` pipes for
    backward compatibility, but this should not be considered permanent.
    Please code accordingly

- Migration to the default branch in GitHub from `master` -\> `main`
  ([@stufield](https://github.com/stufield),
  [\#19](https://github.com/SomaLogic/SomaDataIO/issues/19))

- Numerous non-user-facing (API) changes internal package maintenance,
  efficiency, and structural upgrades were included

## SomaDataIO 5.3.0

- Upgrades primarily from improvements to SomaLogic internal code base,
  including: ([@stufield](https://github.com/stufield))

  - general reduction on external package dependency to improve code
    stability
  - internal usage of base R alternatives to the `readr` package for
    parsing and importing ADATs
    (e.g. [`read.delim()`](https://rdrr.io/r/utils/read.table.html) over
    `readr::read_delim()`). This is mostly for code simplification, but
    can often result in marked speed improvements. As the SomaScan
    `plex` size increases, this speed improvement will become more
    important.
  - [`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md)
    was dramatically simplified, now reading in lines 20L at a time
    until the RFU block is reached. In addition, once the block is
    reached, all header lines are read-in once and indexed (as opposed
    to line-by-line).
  - [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
    now specifies column types via `colClasses =` which for the majority
    of the ADAT is type `double` for the RFU columns. This should
    dramatically improve speed of ingest.
  - [`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)
    was simplified internally, with fewer nested `apply` and for-loops.
  - encoding for all input/output (I/O) is assumed to be `UTF-8`.

- New
  [`getAnalytes()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md)
  S3 method for class `recipe` from the `recipes` package.

- New
  [`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md)
  to load multiple ADAT files in a single call and optionally collapse
  them into a single data frame
  ([@stufield](https://github.com/stufield),
  [\#8](https://github.com/SomaLogic/SomaDataIO/issues/8)).

- New
  [`getTargetNames()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md)
  function to map ADAT `seq.XXXX.XX` names to corresponding protein
  targets from the annotations table

## SomaDataIO 5.2.0

- SomaLogic Inc. is now SomaLogic Operating Co. Inc.

- Added new documentation regarding `Col.Meta`
  ([@stufield](https://github.com/stufield),
  [\#12](https://github.com/SomaLogic/SomaDataIO/issues/12)).

  - documentation around column meta data, row meta data, where they are
    found in an ADAT, and how to access them.

- Research Use Only (“RUO”) language was added to the README
  ([@stufield](https://github.com/stufield),
  [\#10](https://github.com/SomaLogic/SomaDataIO/issues/10)).

- Numerous internal code improvements from SomaLogic code-base
  ([@stufield](https://github.com/stufield))

  - the consisted of reducing usage of external dependencies, e.g. using
    [`stop()`](https://rdrr.io/r/base/stop.html) over `ui_stop()` and
    [`warning()`](https://rdrr.io/r/base/warning.html) over `ui_warn()`,
    using `usethis`, `cli`, and `crayon` shims aliases.
  - package uses `purrr` very selectively and no longer uses `stringr`.
  - using base R alternatives in favor of increased stability for
    underlying, non-user-facing code.

- New
  [`lift_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/lift_adat.md)
  was added to provided ‘lifting’ functionality
  ([@stufield](https://github.com/stufield),
  [\#11](https://github.com/SomaLogic/SomaDataIO/issues/11))

  - provides mechanism to convert RFU space between SomaScan versions
    (e.g. v4.1 -\> v4.0).
  - added new S3
    [`transform.soma_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/transform.md)
    method which simplifies linear scaling of `soma_adat` columns
    (analytes).
  - uses an “Annotations file” (Excel) as source of scalars for
    transformation.

- Minor improvements and updates to the `README.Rmd`
  ([@stufield](https://github.com/stufield),
  [\#7](https://github.com/SomaLogic/SomaDataIO/issues/7))

  - fixed a broken
    [`adat2eSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat2eSet.md)
    link in README
    ([\#5](https://github.com/SomaLogic/SomaDataIO/issues/5)).
  - clearer text to the `README` regarding `Biobase` installation.
  - added new links to external Bioconductor website in installation
    section of README.
  - new `pkgdown` and links to Issues
    ([\#4](https://github.com/SomaLogic/SomaDataIO/issues/4)).
  - SomaLogic logo was added to README.
  - a lifecycle (“maturing”) badge was added.

- Startup message was improved with dynamic width
  ([@stufield](https://github.com/stufield)).

- New
  [`locateSeqId()`](https://somalogic.github.io/SomaDataIO/dev/reference/SeqId.md)
  function to pull out `SeqId` regex.
  ([@stufield](https://github.com/stufield)).

- New
  [`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md)
  function ([@stufield](https://github.com/stufield),
  [\#2](https://github.com/SomaLogic/SomaDataIO/issues/2))

  - new function to parse/import SomaLogic annotations files (`*.xlsx`).

## SomaDataIO 5.1.0

- New
  [`set_rn()`](https://somalogic.github.io/SomaDataIO/dev/reference/rownames.md)
  drop-in replacement for
  [`magrittr::set_rownames()`](https://magrittr.tidyverse.org/reference/aliases.html)

- [`getFeatures()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md)
  was renamed to be less ambiguous and better align with internal
  SomaLogic code usage. Now use
  [`getAnalytes()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md)
  ([@stufield](https://github.com/stufield))

- [`getFeatureData()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md)
  was also renamed to
  [`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md)
  ([@stufield](https://github.com/stufield))

- various upgrades as required by code changes in external package
  dependencies, e.g. `tidyverse`.

- new alias for
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
  [`read.adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
  for backward compatibility to previous versions of `SomaDataIO`
  ([@stufield](https://github.com/stufield))

## SomaDataIO 5.0.0

- Initial public release to GitHub!
