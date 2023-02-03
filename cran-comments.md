
# This is a new release to CRAN.

## R timings

* a few of the examples seemed to run long
  (> 5s) during `rhub::check_for_cran()` however
  this was not reproduced locally. I assume this
  was due to resource limitation of the build container
  during some I/O processes.

## R CMD check results

```
0 errors | 0 warnings | 1 note

* checking installed package size ... NOTE
  installed size is 11.5Mb
  sub-directories of 1Mb or more:
    data      2.8Mb
    example   8.0Mb
```

The package contains a single example data set as large-"ish" object that
is used throughout the function examples and represents proprietary
protein expression data as part of a versioned assay (similar to a chip
in gene expression assays).
