# The `soma_adat` Class and S3 Methods

The `soma_adat` data structure is the primary internal `R`
representation of SomaScan data. A `soma_adat` is automatically created
via
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
when loading a `*.adat` text file. It consists of a `data.frame`-like
object with leading columns as clinical variables and SomaScan RFU data
as the remaining variables. Two main attributes corresponding to analyte
and SomaScan run information contained in the `*.adat` file are added:

- `Header.Meta`: information about the SomaScan run, see
  [`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md)
  or `attr(x, "Header.Meta")`

- `Col.Meta`: annotations information about the SomaScan
  reagents/analytes, see
  [`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md)
  or `attr(x, "Col.Meta")`

- `file_specs`: parsing specifications for the ingested `*.adat` file

- `row_meta`: the names of the non-RFU fields. See
  [`getMeta()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md).

See
[`groupGenerics()`](https://somalogic.github.io/SomaDataIO/dev/reference/groupGenerics.md)
for a details on [`Math()`](https://rdrr.io/r/base/groupGeneric.html),
[`Ops()`](https://rdrr.io/r/base/groupGeneric.html), and
[`Summary()`](https://rdrr.io/r/base/groupGeneric.html) methods that
dispatch on class `soma_adat`.  
  
See `reexports()` for a details on re-exported S3 generics from other
packages (mostly `dplyr` and `tidyr`) to enable S3 methods to be
dispatched on class `soma_adat`.  
  
Below is a list of *all* currently available S3 methods that dispatch on
the `soma_adat` class:

    #>  [1] [              [[             [[<-           [<-
    #>  [5] ==             $              $<-            anti_join
    #>  [9] arrange        count          filter         full_join
    #> [13] getAdatVersion getAnalytes    getMeta        group_by
    #> [17] inner_join     is_seqFormat   left_join      Math
    #> [21] median         merge          mutate         Ops
    #> [25] print          rename         right_join     row.names<-
    #> [29] sample_frac    sample_n       select         semi_join
    #> [33] separate       slice_sample   slice          summary
    #> [37] Summary        transform      ungroup        unite
    #> see '?methods' for accessing help and source code

The S3 [`print()`](https://rdrr.io/r/base/print.html) method returns
summary information parsed from the object attributes, if present,
followed by a dispatch to the
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
print method. Rownames are printed as the first column in the print
method only.

The S3 [`summary()`](https://rdrr.io/r/base/summary.html) method returns
the following for each column of the ADAT object containing SOMAmer data
(clinical meta data is *excluded*):

- Target (if available)

- Minimum value

- 1st Quantile

- Median

- Mean

- 3rd Quantile

- Maximum value

- Standard deviation

- Median absolute deviation
  ([`mad()`](https://rdrr.io/r/stats/mad.html))

- Interquartile range ([`IQR()`](https://rdrr.io/r/stats/IQR.html))

The S3 [`Extract()`](https://rdrr.io/r/base/Extract.html) method is used
for sub-setting a `soma_adat` object and relies heavily on the `[`
method that maintains the `soma_adat` attributes intact *and* subsets
the `Col.Meta` so that it is consistent with the newly created object.

S3 extraction via `$` is fully supported, however, as opposed to the
`data.frame` method, partial matching is *not* allowed for class
`soma_adat`.

S3 extraction via `[[` is supported, however, we restrict the usage of
`[[` for `soma_adat`. Use only a numeric index (e.g. `1L`) or a
character identifying the column (e.g. `"SampleID"`). Do not use
`[[i,j]]` syntax with `[[`, use `[` instead. As with `$`, partial
matching is *not* allowed.

S3 assignment via `[` is supported for class `soma_adat`.

S3 assignment via `$` is fully supported for class `soma_adat`.

S3 assignment via `[[` is supported for class `soma_adat`.

S3 [`median()`](https://rdrr.io/r/stats/median.html) is *not* currently
supported for the `soma_adat` class, however a dispatch is in place to
direct users to alternatives.

## Usage

``` r
# S3 method for class 'soma_adat'
print(x, show_header = FALSE, ...)

# S3 method for class 'soma_adat'
summary(object, tbl = NULL, digits = max(3L, getOption("digits") - 3L), ...)

# S3 method for class 'soma_adat'
x[i, j, drop = TRUE, ...]

# S3 method for class 'soma_adat'
x$name

# S3 method for class 'soma_adat'
x[[i, j, ..., exact = TRUE]]

# S3 method for class 'soma_adat'
x[i, j, ...] <- value

# S3 method for class 'soma_adat'
`$`(x, i, j, ...) <- value

# S3 method for class 'soma_adat'
x[[i, j, ...]] <- value

# S3 method for class 'soma_adat'
median(x, na.rm = FALSE, ...)
```

## Arguments

- x, object:

  A `soma_adat` class object.

- show_header:

  Logical. Should all the `Header Data` information be displayed instead
  of the data frame (`tibble`) object?

- ...:

  Ignored.

- tbl:

  An annotations table. If `NULL` (default), annotation information is
  extracted from the object itself (if possible). Alternatively, the
  result of a call to
  [`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md),
  from which Target names can be extracted.

- digits:

  Integer. Used for number formatting with
  [`signif()`](https://rdrr.io/r/base/Round.html).

- i, j:

  Row and column indices respectively. If `j` is omitted, `i` is used as
  the column index.

- drop:

  Coerce to a vector if fetching one column via `tbl[, j]`. Default
  `FALSE`, ignored when accessing a column via `tbl[j]`.

- name:

  A [name](https://rdrr.io/r/base/name.html) or a string.

- exact:

  Ignored with a [`warning()`](https://rdrr.io/r/base/warning.html).

- value:

  A value to store in a row, column, range or cell.

- na.rm:

  a logical value indicating whether `NA` values should be stripped
  before the computation proceeds.

## Value

The set of S3 methods above return the `soma_adat` object with the
corresponding S3 method applied.

## See also

[`groupGenerics()`](https://somalogic.github.io/SomaDataIO/dev/reference/groupGenerics.md)

Other IO:
[`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md),
[`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md),
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
[`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)

## Examples

``` r
# S3 print method
example_data
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 192
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 192 × 5,319
#>    row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId
#>    <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>
#>  1 258495800012_3 Example… 2020-06-18   SG152144… H9            2.58e11
#>  2 258495800004_7 Example… 2020-06-18   SG152144… H8            2.58e11
#>  3 258495800010_8 Example… 2020-06-18   SG152144… H7            2.58e11
#>  4 258495800003_4 Example… 2020-06-18   SG152144… H6            2.58e11
#>  5 258495800009_4 Example… 2020-06-18   SG152144… H5            2.58e11
#>  6 258495800012_8 Example… 2020-06-18   SG152144… H4            2.58e11
#>  7 258495800001_3 Example… 2020-06-18   SG152144… H3            2.58e11
#>  8 258495800004_8 Example… 2020-06-18   SG152144… H2            2.58e11
#>  9 258495800001_8 Example… 2020-06-18   SG152144… H12           2.58e11
#> 10 258495800004_3 Example… 2020-06-18   SG152144… H11           2.58e11
#> # ℹ 182 more rows
#> # ℹ 5,313 more variables: Subarray <dbl>, SampleId <chr>,
#> #   SampleType <chr>, PercentDilution <int>, SampleMatrix <chr>,
#> #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
#> #   SampleNotes <lgl>, AliquotingNotes <lgl>, …
#> ═══════════════════════════════════════════════════════════════════════

# show the header info (no RFU data)
print(example_data, show_header = TRUE)
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 192
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Header Data ────────────────────────────────────────────────────────
#> # A tibble: 35 × 2
#>    Key                  Value                                          
#>    <chr>                <chr>                                          
#>  1 AdatId               GID-1234-56-789-abcdef                         
#>  2 Version              1.2                                            
#>  3 AssayType            PharmaServices                                 
#>  4 AssayVersion         V4                                             
#>  5 AssayRobot           Fluent 1 L-307                                 
#>  6 Legal                Experiment details and data have been processe…
#>  7 CreatedBy            PharmaServices                                 
#>  8 CreatedDate          2020-07-24                                     
#>  9 EnteredBy            Technician1                                    
#> 10 ExpDate              2020-06-18, 2020-07-20                         
#> 11 GeneratedBy          Px (Build:  : ), Canopy_0.1.1                  
#> 12 RunNotes             2 columns ('Age' and 'Sex') have been added to…
#> 13 ProcessSteps         Raw RFU, Hyb Normalization, medNormInt (Sample…
#> 14 ProteinEffectiveDate 2019-08-06                                     
#> 15 StudyMatrix          EDTA Plasma                                    
#> # ℹ 20 more rows
#> ═══════════════════════════════════════════════════════════════════════

# S3 summary method
# MMP analytes (4)
mmps <- c("seq.2579.17", "seq.2788.55", "seq.2789.26", "seq.4925.54")
mmp_adat <- example_data[, c("Sex", mmps)]
summary(mmp_adat)
#>  seq.2579.17         seq.2788.55         seq.2789.26         
#>  Target : MMP-9      Target : MMP-3      Target : MMP-7      
#>  Min    :    59.3    Min    :  29.30     Min    :    24.1    
#>  1Q     :  9360.5    1Q     : 126.67     1Q     :  8182.0    
#>  Median : 13191.2    Median : 149.75     Median : 10947.8    
#>  Mean   : 14372.5    Mean   : 157.78     Mean   : 11277.6    
#>  3Q     : 19387.3    3Q     : 179.08     3Q     : 13577.0    
#>  Max    : 51263.0    Max    : 423.20     Max    : 33496.9    
#>  sd     :  7449.9    sd     :  53.57     sd     :  5802.6    
#>  MAD    :  6877.9    MAD    :  38.62     MAD    :  4001.2    
#>  IQR    : 10026.8    IQR    :  52.40     IQR    :  5395.0    
#>  seq.4925.54         
#>  Target : MMP-13     
#>  Min    :   25.20    
#>  1Q     :  328.30    
#>  Median :  389.70    
#>  Mean   :  424.48    
#>  3Q     :  452.85    
#>  Max    : 2883.20    
#>  sd     :  259.01    
#>  MAD    :   93.85    
#>  IQR    :  124.55    

# Summarize by group
mmp_adat |>
  split(mmp_adat$Sex) |>
  lapply(summary)
#> $F
#>  seq.2579.17         seq.2788.55         seq.2789.26         
#>  Target : MMP-9      Target : MMP-3      Target : MMP-7      
#>  Min    :  4484      Min    :  97.10     Min    :   289.7    
#>  1Q     :  8336      1Q     : 127.70     1Q     :  9410.0    
#>  Median : 12859      Median : 150.60     Median : 12157.2    
#>  Mean   : 13674      Mean   : 156.02     Mean   : 12877.3    
#>  3Q     : 16148      3Q     : 181.10     3Q     : 15151.9    
#>  Max    : 31879      Max    : 235.40     Max    : 32221.3    
#>  sd     :  6389      sd     :  34.66     sd     :  5214.4    
#>  MAD    :  6488      MAD    :  38.10     MAD    :  4342.7    
#>  IQR    :  7811      IQR    :  53.40     IQR    :  5741.9    
#>  seq.4925.54         
#>  Target : MMP-13     
#>  Min    :  241.80    
#>  1Q     :  333.80    
#>  Median :  388.10    
#>  Mean   :  422.14    
#>  3Q     :  460.70    
#>  Max    : 1353.80    
#>  sd     :  171.89    
#>  MAD    :   95.78    
#>  IQR    :  126.90    
#> 
#> $M
#>  seq.2579.17         seq.2788.55         seq.2789.26         
#>  Target : MMP-9      Target : MMP-3      Target : MMP-7      
#>  Min    :  5894      Min    :  99.90     Min    :  2850      
#>  1Q     :  9973      1Q     : 132.40     1Q     :  8640      
#>  Median : 13645      Median : 157.40     Median : 11230      
#>  Mean   : 15715      Mean   : 173.63     Mean   : 11699      
#>  3Q     : 20595      3Q     : 196.20     3Q     : 13061      
#>  Max    : 51263      Max    : 423.20     Max    : 33497      
#>  sd     :  7979      sd     :  61.17     sd     :  5243      
#>  MAD    :  6344      MAD    :  40.18     MAD    :  3477      
#>  IQR    : 10622      IQR    :  63.80     IQR    :  4421      
#>  seq.4925.54         
#>  Target : MMP-13     
#>  Min    :  205.7     
#>  1Q     :  329.3     
#>  Median :  401.6     
#>  Mean   :  462.7     
#>  3Q     :  468.9     
#>  Max    : 2883.2     
#>  sd     :  331.3     
#>  MAD    :  103.8     
#>  IQR    :  139.6     
#> 

# Alternatively pass annotations with Target info
anno <- getAnalyteInfo(mmp_adat)
summary(mmp_adat, tbl = anno)
#>  seq.2579.17         seq.2788.55         seq.2789.26         
#>  Target : MMP-9      Target : MMP-3      Target : MMP-7      
#>  Min    :    59.3    Min    :  29.30     Min    :    24.1    
#>  1Q     :  9360.5    1Q     : 126.67     1Q     :  8182.0    
#>  Median : 13191.2    Median : 149.75     Median : 10947.8    
#>  Mean   : 14372.5    Mean   : 157.78     Mean   : 11277.6    
#>  3Q     : 19387.3    3Q     : 179.08     3Q     : 13577.0    
#>  Max    : 51263.0    Max    : 423.20     Max    : 33496.9    
#>  sd     :  7449.9    sd     :  53.57     sd     :  5802.6    
#>  MAD    :  6877.9    MAD    :  38.62     MAD    :  4001.2    
#>  IQR    : 10026.8    IQR    :  52.40     IQR    :  5395.0    
#>  seq.4925.54         
#>  Target : MMP-13     
#>  Min    :   25.20    
#>  1Q     :  328.30    
#>  Median :  389.70    
#>  Mean   :  424.48    
#>  3Q     :  452.85    
#>  Max    : 2883.20    
#>  sd     :  259.01    
#>  MAD    :   93.85    
#>  IQR    :  124.55    
```
