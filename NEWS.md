# SomaDataIO (development version)

# SomaDataIO 5.1.0

* New `set_rn()` drop-in replacement for `magrittr::set_rownames()`
* `getFeatures()` was renamed to be less ambiguous and better align with
  internal SomaLogic code usage. Now use `getAnalytes()`
* `getFeatureData()` was also renamed to `getAnalyteInfo()`
* various upgrades as required by code changes in external 
  package dependencies, e.g. `tidyverse`.
* new alias for `read_adat()`, `read.adat()`, for backward compatibility
  to previous versions of `SomaDataIO`

# SomaDataIO 5.0.0

* Initial public release to GitHub!
