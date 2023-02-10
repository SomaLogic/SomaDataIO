
# This is a new release to CRAN

* This is a re-submission that addresses issues found
  in the original submission.

  - single quotes in DESCRIPTION file around 'SomaScan'
  - added a link to ADAT file format in `DESCRIPTION` file Description:
    [format](https://github.com/SomaLogic/SomaLogic-Data/blob/master/README.md)
  - all functions now have `value{}` return
  - `dontrun{}` is used _only_ when examples cannot be completed due
    to missing file (in this case an Excel file)
  - `dontrun{}` was replaced with `donttest{}` for `loadAdatsAsList()`
    example; nice to show users an alternative path to an example
    already shown, but causes the examples to run long
  - examples in `getAnalyteInfo()` now reverts `par()` back
    to the original value when complete
  - all functions/examples/tests/vignettes do _not_ write to
    the user's home filespace; Package uses `tempdir()` and `tempfile()`


## R CMD check results
```
0 errors | 0 warnings | 0 notes
```

## Package Size

* Package tarball is now 4.0MB (down from ~6.7MB)

## Example Timings

I have streamlined the examples into smaller objects in an 
attempt to get all examples to < 5s. Please see below:

[results from win-builder](https://win-builder.r-project.org/zr2cd9ve4PDL/examples_and_tests/SomaDataIO-Ex.timings)


```
name                user    system    elapsed
Col.Meta            0.28    0.05      0.36
SeqId               0.03    0.01      0.04
SomaDataIO-package  0.12    0.02      0.16
SomaScanObjects     0.28    0.00      0.29
adat2eSet           0.39    0.03      0.42
diffAdats           0.28    0.13      0.40
getAnalyteInfo      0.16    0.00      0.15
getAnalytes         0.01    0.00      0.02
groupGenerics       0.29    0.03      0.33
is_intact_attr      0.00    0.01      0.02
is_seqFormat        0       0         0
lift_adat           0.77    0.24      1.00
loadAdatsAsList     1.28    0.04      1.33
parseHeader         0.53    0.30      0.83
pivotExpressionSet  0.10    0.00      0.09
read_adat           1.17    0.00      1.17
read_annotations    0       0         0
rownames            0.02    0.00      0.04
soma_adat           0.23    0.00      0.23
transform           0.00    0.01      0.02
write_adat          0.83    0.21      1.03
```


## Spelling
```
Possibly misspelled words in DESCRIPTION:
  ADAT (11:15, 13:49)
  SomaScan (3:21)
```

* The spell check note looks like a false positive.
  These 2 words are domain specific and are spelled correctly.
