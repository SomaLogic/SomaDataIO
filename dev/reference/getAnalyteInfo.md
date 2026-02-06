# Get Analyte Annotation Information

Uses the `Col.Meta` attribute (analyte annotation data that appears
above the protein measurements in the `*.adat` text file) of a
`soma_adat` object, adds the `AptName` column key, conducts a few sanity
checks, and generates a "lookup table" of analyte data that can be used
for simple manipulation and indexing of analyte annotation information.
Most importantly, the analyte column names of the `soma_adat` (e.g.
`seq.XXXX.XX`) become the `AptName` column of the lookup table and
represents the key index between the table and `soma_adat` from which it
comes.

## Usage

``` r
getAnalyteInfo(adat)

getTargetNames(tbl)

getFeatureData(adat)
```

## Arguments

- adat:

  A `soma_adat` object (with intact attributes), typically created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- tbl:

  A `tibble` object containing analyte target annotation information.
  This is usually the result of a call to `getAnalyteInfo()`.

## Value

A `tibble` object with columns corresponding to the column meta data
entries in the `soma_adat`. One row per analyte.

## Functions

- `getTargetNames()`: creates a lookup table (or dictionary) as a named
  list object of `AptNames` and Target names in key-value pairs. This is
  a convenient tool to quickly access a `TargetName` given the `AptName`
  in which the key-value pairs map the `seq.XXXX.XX` to its
  corresponding `TargetName` in `tbl`. This structure which provides a
  convenient auto-completion mechanism at the command line or for
  generating plot titles.

- `getFeatureData()`: **\[superseded\]**. Please now use
  `getAnalyteInfo()`.

## See also

[`getAnalytes()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md),
[`is_intact_attr()`](https://somalogic.github.io/SomaDataIO/dev/reference/is_intact_attr.md),
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)

## Author

Stu Field

## Examples

``` r
# Get Aptamer table
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

# Use `dplyr::group_by()`
dplyr::tally(dplyr::group_by(anno_tbl, Dilution))  # print summary by dilution
#> # A tibble: 4 × 2
#>   Dilution     n
#>   <chr>    <int>
#> 1 0           12
#> 2 0.005      173
#> 3 0.5        828
#> 4 20        4271

# Columns containing "Target"
anno_tbl |>
  dplyr::select(dplyr::contains("Target"))
#> # A tibble: 5,284 × 2
#>    TargetFullName                                         Target  
#>    <chr>                                                  <chr>   
#>  1 Beta-crystallin B2                                     CRBB2   
#>  2 RAF proto-oncogene serine/threonine-protein kinase     c-Raf   
#>  3 Zinc finger protein 41                                 ZNF41   
#>  4 ETS domain-containing protein Elk-1                    ELK1    
#>  5 Guanylyl cyclase-activating protein 1                  GUC1A   
#>  6 Inositol polyphosphate 5-phosphatase OCRL-1            OCRL    
#>  7 SAM pointed domain-containing Ets transcription factor SPDEF   
#>  8 Fc_MOUSE                                               Fc_MOUSE
#>  9 Zinc finger protein SNAI2                              SLUG    
#> 10 Voltage-gated potassium channel subunit beta-2         KCAB2   
#> # ℹ 5,274 more rows

# Rows of "Target" starting with MMP
anno_tbl |>
  dplyr::filter(grepl("^MMP", Target))
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

# Target names
tg <- getTargetNames(anno_tbl)

# how to use for plotting
feats <- sample(anno_tbl$AptName, 6)
op <- par(mfrow = c(2, 3))
sapply(feats, function(.x) plot(1:10, main = tg[[.x]]))

#> $seq.5465.32
#> NULL
#> 
#> $seq.13116.25
#> NULL
#> 
#> $seq.18871.24
#> NULL
#> 
#> $seq.12934.1
#> NULL
#> 
#> $seq.13666.222
#> NULL
#> 
#> $seq.12771.19
#> NULL
#> 
par(op)
```
