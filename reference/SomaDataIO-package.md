# SomaDataIO: Input/Output 'SomaScan' Data

Load and export 'SomaScan' data via the 'SomaLogic Operating Co., Inc.'
structured text file called an ADAT ('\*.adat'). For file format see
<https://github.com/SomaLogic/SomaLogic-Data/blob/main/README.md>. The
package also exports auxiliary functions for manipulating, wrangling,
and extracting relevant information from an ADAT object once in memory.

## Details

Load an ADAT file into the global workspace with a call to
[`read_adat()`](https://somalogic.github.io/SomaDataIO/reference/read_adat.md).
This function parses the main data table into a `data.frame` object and
assigns the remaining data from the file as object `attributes`, i.e.
call `attributes(adat)`. Other functions in the package are designed to
make extracting, manipulating, and wrangling data in the newly created
[soma_adat](https://somalogic.github.io/SomaDataIO/reference/soma_adat.md)
object more convenient.

Those familiar with micro-array data analysis and associated packages,
e.g. Biobase, will notice that the feature data (proteins) are arranged
as columns and the samples (arrays) are the rows. This is the transpose
of typical micro-array data. This conflict can be easily solved using
the transpose function, [`t()`](https://rdrr.io/r/base/t.html), which is
part of the `base R`. In addition, those familiar with the standard
`ExpressionSet` object, available from `Bioconductor`, might find the
functions
[`adat2eSet()`](https://somalogic.github.io/SomaDataIO/reference/adat2eSet.md)
and
[`pivotExpressionSet()`](https://somalogic.github.io/SomaDataIO/reference/pivotExpressionSet.md)
particularly useful.

## See also

Useful links:

- <https://somalogic.github.io/SomaDataIO/>

- <https://somalogic.com>

- Report bugs at <https://github.com/SomaLogic/SomaDataIO/issues>

## Author

**Maintainer**: Caleb Scheidel <calebjscheidel@gmail.com>

Authors:

- Stu Field <stu.g.field@gmail.com>
  ([ORCID](https://orcid.org/0000-0002-1024-5859))

Other contributors:

- SomaLogic Operating Co., Inc. \[copyright holder, funder\]

## Examples

``` r
# a listing of all pkg functions
library(help = SomaDataIO)

# the `soma_adat` class
class(example_data)
#> [1] "soma_adat"  "data.frame"
is.soma_adat(example_data)
#> [1] TRUE

# Annotations Lookup Table
anno_tbl <- getAnalyteInfo(example_data)
anno_tbl
#> # A tibble: 5,284 × 22
#>    AptName      SeqId SeqIdVersion SomaId TargetFullName Target UniProt
#>    <chr>        <chr>        <dbl> <chr>  <chr>          <chr>  <chr>  
#>  1 seq.10000.28 1000…            3 SL019… Beta-crystall… CRBB2  P43320 
#>  2 seq.10001.7  1000…            3 SL002… RAF proto-onc… c-Raf  P04049 
#>  3 seq.10003.15 1000…            3 SL019… Zinc finger p… ZNF41  P51814 
#>  4 seq.10006.25 1000…            3 SL019… ETS domain-co… ELK1   P19419 
#>  5 seq.10008.43 1000…            3 SL019… Guanylyl cycl… GUC1A  P43080 
#>  6 seq.10011.65 1001…            3 SL019… Inositol poly… OCRL   Q01968 
#>  7 seq.10012.5  1001…            3 SL014… SAM pointed d… SPDEF  O95238 
#>  8 seq.10013.34 1001…            3 SL025… Fc_MOUSE       Fc_MO… Q99LC4 
#>  9 seq.10014.31 1001…            3 SL007… Zinc finger p… SLUG   O43623 
#> 10 seq.10015.1… 1001…            3 SL014… Voltage-gated… KCAB2  Q13303 
#> # ℹ 5,274 more rows
#> # ℹ 15 more variables: EntrezGeneID <chr>, EntrezGeneSymbol <chr>,
#> #   Organism <chr>, Units <chr>, Type <chr>, Dilution <chr>,
#> #   PlateScale_Reference <dbl>, CalReference <dbl>,
#> #   Cal_Example_Adat_Set001 <dbl>, ColCheck <chr>,
#> #   CalQcRatio_Example_Adat_Set001_170255 <dbl>,
#> #   QcReference_170255 <dbl>, Cal_Example_Adat_Set002 <dbl>, …

# Find all analytes starting with "MMP" in `anno_tbl`
dplyr::filter(anno_tbl, grepl("^MMP", Target))
#> # A tibble: 15 × 22
#>    AptName      SeqId SeqIdVersion SomaId TargetFullName Target UniProt
#>    <chr>        <chr>        <dbl> <chr>  <chr>          <chr>  <chr>  
#>  1 seq.15419.15 1541…            3 SL012… Matrix metall… MMP20  O60882 
#>  2 seq.2579.17  2579…            5 SL000… Matrix metall… MMP-9  P14780 
#>  3 seq.2788.55  2788…            1 SL000… Stromelysin-1  MMP-3  P08254 
#>  4 seq.2789.26  2789…            2 SL000… Matrilysin     MMP-7  P09237 
#>  5 seq.2838.53  2838…            1 SL003… Matrix metall… MMP-17 Q9ULZ9 
#>  6 seq.4160.49  4160…            1 SL000… 72 kDa type I… MMP-2  P08253 
#>  7 seq.4496.60  4496…            2 SL000… Macrophage me… MMP-12 P39900 
#>  8 seq.4924.32  4924…            1 SL000… Interstitial … MMP-1  P03956 
#>  9 seq.4925.54  4925…            2 SL000… Collagenase 3  MMP-13 P45452 
#> 10 seq.5002.76  5002…            1 SL002… Matrix metall… MMP-14 P50281 
#> 11 seq.5268.49  5268…            3 SL003… Matrix metall… MMP-16 P51512 
#> 12 seq.6425.87  6425…            3 SL007… Matrix metall… MMP19  Q99542 
#> 13 seq.8479.4   8479…            3 SL000… Stromelysin-2  MMP-10 P09238 
#> 14 seq.9172.69  9172…            3 SL000… Neutrophil co… MMP-8  P22894 
#> 15 seq.9719.145 9719…            3 SL003… Matrix metall… MMP-16 P51512 
#> # ℹ 15 more variables: EntrezGeneID <chr>, EntrezGeneSymbol <chr>,
#> #   Organism <chr>, Units <chr>, Type <chr>, Dilution <chr>,
#> #   PlateScale_Reference <dbl>, CalReference <dbl>,
#> #   Cal_Example_Adat_Set001 <dbl>, ColCheck <chr>,
#> #   CalQcRatio_Example_Adat_Set001_170255 <dbl>,
#> #   QcReference_170255 <dbl>, Cal_Example_Adat_Set002 <dbl>,
#> #   CalQcRatio_Example_Adat_Set002_170255 <dbl>, Dilution2 <dbl>
```
