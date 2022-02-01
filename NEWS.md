# SomaDataIO 5.3.0

* Upgrades primarily from improvements to SomaLogic internal code base,
  including: (@stufield)
  - general reduction on external package dependency to improve code
    stability
  - internal usage of base R alternatives to the `readr` package for 
    parsing and importing ADATs (e.g. `read.delim()` over `read_delim()`).
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
