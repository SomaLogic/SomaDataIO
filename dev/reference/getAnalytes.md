# Get Analytes

Return the feature names (i.e. the column names for SOMAmer reagent
analytes) from a `soma_adat`. S3 methods also exist for these classes:

    #> [1] getAnalytes.character  getAnalytes.data.frame getAnalytes.default
    #> [4] getAnalytes.list       getAnalytes.matrix     getAnalytes.recipe
    #> [7] getAnalytes.soma_adat
    #> see '?methods' for accessing help and source code

`getMeta()` returns the inverse, a character vector of string names of
*non*-analyte feature columns/variables, which typically correspond to
the clinical ("meta") data variables. S3 methods exist for these
classes:

    #> [1] getMeta.character  getMeta.data.frame getMeta.default    getMeta.list
    #> [5] getMeta.matrix     getMeta.soma_adat
    #> see '?methods' for accessing help and source code

## Usage

``` r
getAnalytes(x, n = FALSE, rm.controls = FALSE)

getMeta(x, n = FALSE)

getFeatures(x, n = FALSE, rm.controls = FALSE)
```

## Arguments

- x:

  Typically a `soma_adat` class object created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- n:

  Logical. Return an integer corresponding to the *length* of the
  features?

- rm.controls:

  Logical. Should all control and non-human analytes (e.g.
  `HybControls`, `Non-Human`, `Non-Biotin`, `Spuriomer`) be removed from
  the returned value?

## Value

`getAnalytes()`: a character vector of ADAT feature ("analyte") names.

`getMeta()`: a character vector of ADAT clinical ("meta") data names.

For both, if `n = TRUE`, an integer corresponding to the **length** of
the character vector.

## Functions

- `getFeatures()`: **\[superseded\]**. Please now use `getAnalytes()`.

## See also

[`is.apt()`](https://somalogic.github.io/SomaDataIO/dev/reference/SeqId.md)

## Author

Stu Field

## Examples

``` r
# RFU feature variables
apts <- getAnalytes(example_data)
head(apts)
#> [1] "seq.10000.28" "seq.10001.7"  "seq.10003.15" "seq.10006.25"
#> [5] "seq.10008.43" "seq.10011.65"
getAnalytes(example_data, n = TRUE)
#> [1] 5284

# vector string
bb <- getAnalytes(names(example_data))
all.equal(apts, bb)
#> [1] TRUE

# create some control sequences
# ~~~~~~~~~ Spuriomer ~~~ HybControl ~~~
apts2 <- c("seq.2053.2", "seq.2171.12", head(apts))
apts2
#> [1] "seq.2053.2"   "seq.2171.12"  "seq.10000.28" "seq.10001.7" 
#> [5] "seq.10003.15" "seq.10006.25" "seq.10008.43" "seq.10011.65"
no_crtl <- getAnalytes(apts2, rm.controls = TRUE)
no_crtl
#> [1] "seq.10000.28" "seq.10001.7"  "seq.10003.15" "seq.10006.25"
#> [5] "seq.10008.43" "seq.10011.65"
setdiff(apts2, no_crtl)
#> [1] "seq.2053.2"  "seq.2171.12"

# clinical variables
mvec <- getMeta(example_data)
head(mvec, 10)
#>  [1] "PlateId"         "PlateRunDate"    "ScannerID"      
#>  [4] "PlatePosition"   "SlideId"         "Subarray"       
#>  [7] "SampleId"        "SampleType"      "PercentDilution"
#> [10] "SampleMatrix"   
getMeta(example_data, n = TRUE)
#> [1] 34

# test 'data.frame' and 'character' S3 methods are identical
identical(getMeta(example_data), getMeta(names(example_data))) # TRUE
#> [1] TRUE
```
