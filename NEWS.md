# SomaDataIO 6.3.0

### New Functions

* Added `preProcessAdat()` function
  - added new function `preProcessAdat()` to filter features,
    filter samples, generate data QC plots of normalization
    scale factors by covariates, and perform standard analyte
    RFU transformations including log10, centering, and scaling

* Added `calcOutlierMap()` function
  - added `calcOutlierMap()` and its print and plot
    S3 methods, along with `getOutlierIds()` for
    identifying sample level outliers from outlier map object
  - added `ggplot2` as a package dependency

### Function and Object Improvements

* Added `ex_clin_data` object
  - a `tibble` object with additional sample annotation fields
    `smoking_status` and `alcohol_use` to demonstrate merging to a
    `soma_adat` object

### Documentation Updates

* Added pre-processing vignette article
  - includes guidance on pre-processing SomaScan data for
    a typical analysis
  - provides an example of recommended workflow of 
    filtering features, filtering samples, performing data
    QC checks, and transformations of RFU features
  - introduces usage of the `preProcessAdat()` function

* Improved adat ingest documentation in `README`
  - added comments to clarify file path input to `read_adat()`
    example in `README`
    
* Updated stat workflow articles to begin with reading in adat
  - updated data preparation chunks with comments about
    how to download and read in the the `example_data.adat` object
  - data preparation chunks now use the `preProcessAdat()`
    function for pre-processing

* Added sample annotation merging guidance
  - updated `README` and loading and wrangling vignette
    article with section including code to join the 
    `ex_clin_data` object to the `example_data` adat

### Internal :construction:

* Added helper utility functions for snapshot plot unit tests
  - added helper utility functions `figure()`, `close_figure()`,
    `save_png()`, and `expect_snapshot_plot()` for saving plot
    snapshot output to `testthat/helper.R`
  - added snapshot unit tests for `preProcessAdat()`
    messaging, print and QC plot output


# SomaDataIO 6.2.0

### New Functions

* Added `calc_eLOD()` function (#131)
  - calculates the estimated limit of detection (eLOD)
    for SeqId columns of an input `soma_adat` or `data.frame`

### Bug Fixes

* Fixed `crayon` bug and `ui_bullet()` issue (#129, #130)
  - removed `crayon` and `usethis` as dependencies in favor of `cli`
  - fixed bug in R version 4.4.1 with `ui_bullet()` internal
    calls within `loadAdatsAsList()` and `write_adat()`

* Fixed bug in `Summary.soma_adat()` operations (#121)
  - these operations: `min()`, `max()`, `any()`, `range()`, etc.
    would return the incorrect value due to an `as.matrix()`
    conversion under the hood
  - now skips that conversion, trips a warning, and carries on
  - triggers an error if non-numerics are passed
    as part of the '...' outside of a `soma_adat`,
    just like `Summary.data.frame()`

### Function and Object Improvements

* `collapseAdats()` now maintains Cal.Set entries of Col.Meta (#113)
  - collapsing ADATs can be problematic for the attributes,
    especially for large numbers of ADATs
  - `collapseAdats()` now attempts to smartly
    merge the (potentially numerous elements) Col.Meta
    attribute in the final object, preserving
    the "Cal.Set" and "ColCheck" columns in particular
  - the resulting `Col.Meta` attribute is a combined product
    of the individual ADAT elements, and the _intersect_ of the
    analyte features (as is the case for the `rbind()` that is called)
    
* Updated checksums and versions for Annotations Excel files (#116)
  - updated the 7k and 11k file versions and md5sum checksums
  - now allows `read_annotations()` to load
    the individual Excel files
    
* Updated `lift_master` object to alpha sort columns

### Documentation Updates

* Updated company name, license year, and maintainer (#137)
  - SomaLogic Operating Co., Inc is now Standard BioTools, Inc.
  - updated license and copyright year to 2025
  - updated package maintainer to Caleb Scheidel

* Updated article links in README, intro vignette (#123)
  - updated links to articles in README and introduction
    vignette to URLs to pkgdown website rather than
    `vignette()` code references
  - added clarification to above documents that articles are
    available on website only rather than traditional vignettes
    included with package

* Updates to example documentation
  - `read_annotations()` example documentation now points to the
    most recent 11k Excel annotations file
  - `parseHeader()` example  now prints list elements separately,
    rather than full object, which slowed website rendering

### Internal :construction:

* Updates to GitHub Action workflows
  - added `rhub.yaml` configuration file to comply with `rhub` v2
  - updated macOS version in `pkgdown.yaml` to macOS-14
  - added write permission to `pkgdown.yaml` file to enable deployment
  - changed GitHub Action R checks to MacOS and Windows only
    - `ubuntu` machine was taking too long to build

* Increased package test coverage
  - added unit tests for `getSomaScanLiftCCC()`,
    `parseCheck()` and release utilities which
    were previously untested
  - increased test coverage for `pivotExpressionSet()`

* Added missing package anchors to .Rd files (#139)
  - fixed note from remote windows check
    related to Rd \link{} targets missing
    package anchors
    
* Updated README badge (#109)
  - now shows 'downloads' per month over total downloads

* Fixed link in DESCRIPTION; master -> main (#107)


# SomaDataIO 6.1.0   :partying_face: :champagne:

### Lifting Code :rocket:

* Major restructure of `lift_adat()` functionality (@stufield, #81, #78)
  - `lift_adat()` now takes a `bridge =` argument,
    replacing the `anno.tbl =` argument. Lifting
    is now performed internally for a better (and safer)
    user experience, without the necessity of an
    external annotations (Excel) file.
  - the majority of this refactoring was internal
    and the user should not experience a major
    disruption to the API.
  - much improved lifting/bridging documentation (#82)

* Added a new lifting and bridging vignette (@stufield, #77)
  - in addition to the improved lifting documentation
    this new vignette provides additional context,
    explanation, clear examples, and lifting guidance.

### New Functions :sparkles:

* `is_lifted()` is new and returns a boolean according to
  whether the signal space (RFU) has been previously lifted

* Lifting accessor function for Lin's CCC values (#88)
  - `getSomaScanLiftCCC()` accesses the lifting correlations between
    SomaScan versions for each analyte
  - returns a `tibble` split by sample matrix (serum or plasma)

* `merge_clin()` is newly exported (#80)
  - a thin wrapper that allows users to merge
    clinical variables to `soma_adat` objects easily
  - previously users had to either use the CLI merge tool
    or merge in clinical variables themselves with `dplyr`

* Newly exported ADAT "get**" helpers (#83)
  - functions to access properties of ADATs
    - `getAdatVersion()`
    - `getSomaScanVersion()`
    - `getSignalSpace()`
    - `checkSomaScanVersion()`
  - `getAdatVersion()` gets a new S3 method (#92)
    - this enables passing of different objects
    - namely `soma_adat` or `list` depending on the situation

* Newly exported functions that were previously internal only:
  - `addAttributes()`
  - `addClass()`
  - `cleanNames()`

### New Vignettes :nerd_face:

* The package `README` is now simplified (#35)
  - example analysis workflows are now split out
    into their own vignettes/articles
    and cross-linked in the `README`

* Reorganization and expansion of statistical vignettes (#35, #47)
  - moved 3 existing statistical examples from
    `README` into their own vignettes
  - resulting in four new "Statistical Workflow" vignettes/articles:
    - Binary classification via logistic regression
    - Linear regression for continuous variables
    - Two-group comparison via *t*-test
    - Three-group analysis ANOVA

* Added new general analysis workflow vignettes 
  - articles for the pkgdown website have been built out
  - new articles on:
    - safely mapping values among variables
    - safely renaming a data frame
    - loading-and-wrangling
    - typical train and test data splits
    - beginning the FAQs and/or Coming Soon pages

* Added a new vignette describing how to use the
  command-line interface merge tool (#45)
  - the new CLI merge tool used to add
    new clinical data to existing ADAT file

### Updates and Improvements :hammer:

* `collapseAdats()` better combines `HEADER` information (#86)
  - certain information, e.g. `PlateScale` and `Cal*`,
    are better maintained in the final collapsed ADAT
  - other entries are combined by pasting into a single string
  - should result in less duplication of superfluous entries and 
    retention of more "useful" `HEADER` information
    in the resulting (collapsed) `soma_adat`

* Update `read_annotations()` with `11k` content (#85)

* Update `transform()` and `scaleAnalytes()`
  - `scaleAnalytes()` (internal) now skips missing references
    and is much more like a "step" in the `recipes` package
  - `transform()` gets edge case protection with `drop = FALSE`
    in case a single-analyte `soma_adat` is scaled.

* New `row.names()` S3 method support for `soma_adat` class
  - dispatched on calls to `rownmaes()`
  - rather than calling `NextMethod()` which normally
    would invoke `data.frame`, we now force the `data.frame`
    method in case there are `tbl_df` or `grouped_df`
    classes present that would be dispatched.
    Those are bypassed in favor of the `data.frame`
    because `tbl_df` 1) can nuke the attributes, 2)
    triggers a warning about adding rownames to a `tibble`.

* New `grouped_df` S3 print support for the grouped `soma_adat`
  - now displays Grouping information from a call to
    the S3 print method for `soma_adat` class

* New `grouped_df` S3 method support for `soma_adat` class (#66)
  - `grouped_df` data objects previously unsupported and were
    interfering with downstream S3 methods for `dplyr` verbs
    once `NextMethod()` was called
  - this support now ensures that the group
    methods are maintained, as well as the `soma_adat`
    class itself (and most importantly, with its attributes intact)

* `tidyr::separate.soma_adat()` S3 method was simplified (#72)
  - now uses `%||%` helper internally
  - expanded error messages inside `stopifnot()` to be more informative

* `is_intact_attr()` is now *much* quieter, signaling only when called indirectly (#71)
  - new conditional logic to silences signaling messages when
    called from within another function (indirectly)
  - these previously lead to confusing messages
    when they appear in wrappers, where `is_intact_attr()`
    can be, sometimes deeply, nested in the call stack

* Development and improvements to the `pkgdown` website
  - added new links and improved clarity in YAML 
  - added new logo at footer
  - restyled side bar for easier hyperlinking and getting help
  - clicking on the SomaLogic logo in the GitHub `README`
    now links to the `pkgdown` website
  - new "Coming Soon" drop-down section in the website header
    to let users know about active progress (but not yet ready
    for external publication)

* `SomaDataIO` no longer depends on `desc` package
  - to generate the `README.md`

### Internal :construction:

* Internal rowname helpers were upgraded
  - they now use internal cross-functions
    as originally intended to avoid redundancy, efficiency,
    and improved debugging

* `sysdata.rda` no longer contains non-exported functions (#59)
  - new internal helper functions:
    - `convertColMeta()`
    - `genRowNames()`
    - `parseCheck()`
    - `syncColMeta()`
    - `scaleAnalytes()`

* Bug-fix for corner-case writing a single-analyte ADAT (#51)
  - RFU values are rounded to 1 decimal place when written by
    `write_adat()`, via a call to `apply()`, which expects a 2-dim object
     when replacing those values.
  - `write_adat()` no longer uses `apply()` and instead converts
    the entire RFU data frame to a matrix (maintains original dimensions),
    and use vectorized format conversion via `sprintf()`
  - in theory this should be faster because `sprintf()`
    is only called once on a long vector, rather than
    1000s of times on shorter vectors (inside `apply()`).

* Fixed missing closing parenthesis in `SomaScanObjects.R` (thanks @Hijinx725!, #40)


# SomaDataIO 6.0.0 :tada:

* We are now on CRAN! :partying_face: 

### New changes

* New clinical data merge CLI tool (@stufield, #25)
  - `Rscript --vanilla merge_clin.R` for merging clinical variables
    into existing `*.adat` SomaScan data files
  - added 2 new example `meta.csv` and `meta2.csv` files
    to run examples with random data but with valid index keys
  - see `dir(system.file("cli", "merge", package = "SomaDataIO"))`

* Package data objects (@stufield, #32)
  - `example_data.adat` was reduced in size to `n = 10` samples (from 192)
    to conform to CRAN size requirements (< 5MB)
  - the current file was renamed `example_data10.adat` to reflect this change
  - this likely has far-reaching consequences for users who access
    this flat file via `system.file()`
  - the `example_data` object itself however remains true to its original
    file (`https://github.com/SomaLogic/SomaLogic-Data/blob/master/example_data.adat`)
  - the directory location `inst/example/` was renamed `inst/extdata/`
    to conform to CRAN package standard naming conventions
  - the file `single_sample.adat` was removed from package data
    as it is now redundant (however still used in unit testing)
  - `SomaDataObjects` was renamed and is now `SomaScanObjects`

* Gradual deprecation (@stufield)
  - `read.adat()` is now soft-deprecated; please use `read_adat() instead`
  - lifecycle for soft-deprecated `warn()` -> `stop()` for functions
    that have been been soft deprecated since `v5.0.0`
    - `getSomamers()`
    - `getSomamerData()`
    - `meltExpressionSet()`

* New S3 print method default (@stufield)
  - `tibble` has new `max_extra_cols =` argument, which
    is set to `6` for the `print.soma_adat` method

* New S3 merge method (@stufield, #31)
  - calling `base::merge()` on a `soma_adat` is strongly discouraged
  - we now redirect users to use `dplyr::*_join()` alternatives
    which are designed to preserve `soma_adat` attributes

* Code hardening for `prepHeaderMeta()` (@stufield)
  - some ADATs do not have `CreatedDate` and `CreatedBy`
    in the HEADER entry. This currently breaks the writer
  - simplified to make more robust but also refactor
    to be more convenient (for abnormal ADATs not generated
    by standard SomaScan processing)
  - `CreatedDateHistory` was removed as an entry from written ADATs
  - `CreatedByHistory` was combined and dated for written ADATs
  - `NULL` behavior remains if keys are missing
  - `CreatedBy` and `CreatedDate` will be generated either
    as new entries or over-written as appropriate

* Numerous non-user-facing (API) changes internal package
  maintenance, efficiency, and structural upgrades were included


# SomaDataIO 5.3.1

* Bug-fix release related to `write_adat()`:
  - fixed bug in `write_adat()` that resulted from
    adding/removing clinical (non-SomaScan) variables to an
    ADAT. Export via `write_adat()` resulted in a broken ADAT file (@stufield, #18) 
  - `write_adat()` now has much higher fidelity to original
    text file (`*.adat`) in full-cycle read-write-read operations;
    particularly in presence of bangs (`!`) in the Header
    section and in floating point decimals in the `?Col.Meta` section
  - `write_adat()` no longer converts commas (`,`) to
    semi-colons (`;`) in the `?Col.Meta` block (originally
    introduced to avoid cell alignment issues in `*.csv` formats)
  - `write_adat()` no longer concatenates written ADATs,
    when writing to the same file. Data is over-written
    to file to avoid mangled ADATs resulting from re-writing
    to the same connection and to match the default behavior
    of `write.table()`, `write.csv()`, etc.

* `read_adat()` now has more consistent character type
  the `Barcode2` variable in standard ADATs, now forces
  `character` class, does not allow R's `read.delim()`
  to "guess" the type

* Decreased dependency of `magrittr` pipes (`%>%`)
  in favor of the native R pipe (`|>`). As a result the
  package now depends on `R >= 4.1.0`
  - `SomaDataIO` will continue to re-export `magrittr` pipes
    for backward compatibility, but this should not be considered
    permanent. Please code accordingly

* Migration to the default branch in GitHub from `master` -> `main` (@stufield, #19)

* Numerous non-user-facing (API) changes internal package
  maintenance, efficiency, and structural upgrades were included


# SomaDataIO 5.3.0

* Upgrades primarily from improvements to SomaLogic internal code base,
  including: (@stufield)
  - general reduction on external package dependency to improve code
    stability
  - internal usage of base R alternatives to the `readr` package for 
    parsing and importing ADATs (e.g. `read.delim()` over `readr::read_delim()`).
    This is mostly for code simplification, but can often result in marked
    speed improvements. As the SomaScan `plex` size increases,
    this speed improvement will become more important.
  - `parseHeader()` was dramatically simplified, now reading in lines 20L at
    a time until the RFU block is reached. In addition, once the block is
    reached, all header lines are read-in once and indexed
    (as opposed to line-by-line).
  - `read_adat()` now specifies column types via `colClasses =` which for
    the majority of the ADAT is type `double` for the RFU columns.
    This should dramatically improve speed of ingest.
  - `write_adat()` was simplified internally, with fewer nested `apply` and
    for-loops.
  - encoding for all input/output (I/O) is assumed to be `UTF-8`.

* New `getAnalytes()` S3 method for class `recipe` from the `recipes` package.

* New `loadAdatsAsList()` to load multiple ADAT files in a single call
  and optionally collapse them into a single data frame (@stufield, #8).

* New `getTargetNames()` function to map ADAT `seq.XXXX.XX` names
  to corresponding protein targets from the annotations table


# SomaDataIO 5.2.0

* SomaLogic Inc. is now SomaLogic Operating Co. Inc.

* Added new documentation regarding `Col.Meta` (@stufield, #12).
  - documentation around column meta data,
    row meta data, where they are found in an ADAT,
    and how to access them.

* Research Use Only ("RUO") language was added to the README (@stufield, #10).

* Numerous internal code improvements from SomaLogic code-base (@stufield)
  - the consisted of reducing usage of external dependencies,
    e.g. using `stop()` over `ui_stop()` and `warning()` over `ui_warn()`,
    using `usethis`, `cli`, and `crayon` shims aliases.
  - package uses `purrr` very selectively and no longer uses `stringr`.
  - using base R alternatives in favor of increased
    stability for underlying, non-user-facing code.

* New `lift_adat()` was added to provided 'lifting' functionality (@stufield, #11)
  - provides mechanism to convert RFU space between
    SomaScan versions (e.g. v4.1 -> v4.0).
  - added new S3 `transform.soma_adat()` method
    which simplifies linear scaling of `soma_adat` columns (analytes).
  - uses an "Annotations file" (Excel) as source of scalars for transformation.

* Minor improvements and updates to the `README.Rmd` (@stufield, #7)
  - fixed a broken `adat2eSet()` link in README (#5).
  - clearer text to the `README` regarding `Biobase` installation.
  - added new links to external Bioconductor
    website in installation section of README.
  - new `pkgdown` and links to Issues (#4).
  - SomaLogic logo was added to README.
  - a lifecycle ("maturing") badge was added.

* Startup message was improved with dynamic width (@stufield).

* New `locateSeqId()` function to pull out `SeqId` regex. (@stufield).

* New `read_annotations()` function (@stufield, #2)
  - new function to parse/import SomaLogic annotations files (`*.xlsx`).
  

# SomaDataIO 5.1.0

* New `set_rn()` drop-in replacement for `magrittr::set_rownames()`

* `getFeatures()` was renamed to be less ambiguous and better align with
  internal SomaLogic code usage. Now use `getAnalytes()` (@stufield)

* `getFeatureData()` was also renamed to `getAnalyteInfo()` (@stufield)

* various upgrades as required by code changes in external 
  package dependencies, e.g. `tidyverse`.

* new alias for `read_adat()`, `read.adat()`, for backward compatibility
  to previous versions of `SomaDataIO` (@stufield)


# SomaDataIO 5.0.0

* Initial public release to GitHub!
