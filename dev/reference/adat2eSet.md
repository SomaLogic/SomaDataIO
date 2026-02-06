# Convert ADAT to ExpressionSet Object

Utility to convert a SomaLogic `soma_adat` object to an `ExpressionSet`
object via the Biobase package from **Bioconductor**:
<https://www.bioconductor.org/packages/release/bioc/html/Biobase.html>.

## Usage

``` r
adat2eSet(adat)
```

## Arguments

- adat:

  A `soma_adat` class object as read into the R environment using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

## Value

A Bioconductor object of class `ExpressionSet`.

## Details

The Biobase package is required and must be installed from
**Bioconductor** via the following at the R console:

    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager")
    }
    BiocManager::install("Biobase", version = remotes::bioc_version())

## References

<https://bioconductor.org/install/>

## See also

Other eSet:
[`pivotExpressionSet()`](https://somalogic.github.io/SomaDataIO/dev/reference/pivotExpressionSet.md)

## Author

Stu Field

## Examples

``` r
eSet <- adat2eSet(example_data)
class(eSet)
#> [1] "ExpressionSet"
#> attr(,"package")
#> [1] "Biobase"
eSet
#> ExpressionSet (storageMode: lockedEnvironment)
#> assayData: 5284 features, 192 samples 
#>   element names: exprs 
#> protocolData: none
#> phenoData
#>   sampleNames: 258495800012_3 258495800004_7 ...
#>     258495800110_5 (192 total)
#>   varLabels: PlateId PlateRunDate ... Sex (34 total)
#>   varMetadata: labelDescription
#> featureData
#>   featureNames: seq.10000.28 seq.10001.7 ... seq.9999.1 (5284
#>     total)
#>   fvarLabels: SeqId SeqIdVersion ... Dilution2 (21 total)
#>   fvarMetadata: labelDescription
#> experimentData: use 'experimentData(object)'
#> Annotation:  

ft <- Biobase::exprs(eSet)
head(ft[, 1:10L], 10L)
#>               258495800012_3 258495800004_7 258495800010_8
#> seq.10000.28           476.5          474.4          415.6
#> seq.10001.7            310.1          293.5          299.6
#> seq.10003.15           100.3          101.8         3030.1
#> seq.10006.25           602.8          561.9          563.9
#> seq.10008.43           561.8          541.9          423.9
#> seq.10011.65          6897.1         2985.5         3203.6
#> seq.10012.5           1796.6         2123.0         2095.6
#> seq.10013.34           441.9          521.1          560.4
#> seq.10014.31           941.7          933.4         1012.0
#> seq.10015.119          728.1          477.3          535.1
#>               258495800003_4 258495800009_4 258495800012_8
#> seq.10000.28           442.6          465.7          496.6
#> seq.10001.7            247.9          710.7          669.6
#> seq.10003.15           112.9           95.9          135.5
#> seq.10006.25           563.7          791.0          826.0
#> seq.10008.43           469.8          443.5          458.7
#> seq.10011.65          3140.9         2707.5         1705.7
#> seq.10012.5           1922.2         1607.1         1396.0
#> seq.10013.34           582.0          438.6          415.7
#> seq.10014.31          5207.2          943.4          801.8
#> seq.10015.119          480.9          929.2          793.0
#>               258495800001_3 258495800004_8 258495800001_8
#> seq.10000.28           693.0          522.3          452.1
#> seq.10001.7            614.2          632.8          918.3
#> seq.10003.15           140.1          101.0          113.2
#> seq.10006.25           682.7          739.3          905.4
#> seq.10008.43           481.7          724.7          541.2
#> seq.10011.65          6424.4         3559.6         2674.6
#> seq.10012.5           1675.5         1832.8         1526.6
#> seq.10013.34           488.1          483.0          747.4
#> seq.10014.31           838.9          839.1          815.5
#> seq.10015.119          454.3          798.0          981.7
#>               258495800004_3
#> seq.10000.28           702.1
#> seq.10001.7            237.7
#> seq.10003.15           126.9
#> seq.10006.25           634.2
#> seq.10008.43           585.0
#> seq.10011.65          2807.1
#> seq.10012.5           1656.6
#> seq.10013.34           510.6
#> seq.10014.31           869.1
#> seq.10015.119          438.9
```
