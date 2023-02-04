
# This is a new release to CRAN

## R timings

* a few of the examples seemed to run long
  (> 5s) during `rhub::check_for_cran()` however
  this was not reproduced locally. I assume this
  was due to resource limitation of the build container
  during some I/O processes.


## R CMD check results
#### Troublesome links
This is a re-submission that addresses these feasibility NOTES:
```
Possibly misspelled words in DESCRIPTION:
  ADAT (11:15, 13:49)
  SomaScan (3:21)

Found the following (possibly) invalid file URIs:
  URI: README.md
    From: inst/doc/SomaDataIO.html
  URI: LICENSE.md
    From: README.md
```

* Spell check note is a false positive (these 2 words are spelled correctly).
* Invalid (relative) URIs (2) have been replaced with fully elaborated GitHub links.


#### Package size
```
0 errors | 0 warnings | 1 note

* checking installed package size ... NOTE
  installed size is 11.5Mb
  sub-directories of 1Mb or more:
    data      2.8Mb
    example   8.0Mb
```

The package contains a single example data set as large-"ish" object that
is used throughout the function examples and vignettes. It represents proprietary
protein expression data as part of a versioned assay (similar to a chip
in gene expression assays), and is also made available as a flat file
in `inst/example/example_data.adat` for access via `system.file()`.
