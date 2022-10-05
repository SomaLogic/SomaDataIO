# SomaDataIO 5.3.1

* Bug-fix release related to `write_adat()`: (@stufield)
  - fixed bug in `write_adat()` that resulted from
    adding/removing clinical (non-SomaScan) variables to an
    ADAT. Export via `write_adat()` resulted in a broken ADAT file (#18) 
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

* Migration to the default branch in GitHub from `master` -> `main`

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
