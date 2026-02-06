# Example Data and Objects

The `example_data` object is intended to provide existing and
prospective SomaLogic customers with example data to enable analysis
preparation prior to receipt of SomaScan data, and also for those
generally curious about the SomaScan data deliverable. It is **not**
intended to be used as a control group for studies or provide any
metrics for SomaScan data in general.

## Format

- example_data:

  a `soma_adat` parsed via
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
  containing 192 samples (see below for breakdown of sample type). There
  are 5318 columns containing 5284 analyte features and 34 clinical meta
  data fields. These data have been pre-processed via the following
  steps:

  - hybridization normalized (all samples)

  - calibrators and buffers median normalized

  - plate scaled

  - calibrated

  - Adaptive Normalization by Maximum Likelihood (ANML) of QC and
    clinical samples

  **Note1:** The `Age` and `Sex` (`M`/`F`) fields contain simulated
  values designed to contain biological signal.

      **Note2:** The `SampleType` column contains sample source/type information
      and usually the `SampleType == Sample` represents the "client" samples.

      **Note3:** The original source file can be found at
      \url{https://github.com/SomaLogic/SomaLogic-Data}.

- ex_analytes:

  character string of the analyte features contained in the `soma_adat`
  object, derived from a call to
  [`getAnalytes()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md).

- ex_anno_tbl:

  a lookup table corresponding to a transposed data frame of the
  "Col.Meta" attribute of an ADAT, with an index key field `AptName`
  included in column 1, derived from a call to
  [`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md).

- ex_target_names:

  A lookup table mapping `SeqId` feature names -\> target names
  contained in `example_data`. This object (or one like it) is
  convenient at the console via auto-complete for labeling and/or
  creating plot titles on the fly.

- ex_clin_data:

  A table containing `SampleId`, `smoking_status`, and `alcohol_use`
  fields for each clinical sample in `example_data` used to demonstrate
  how to merge sample annotation information to an existing `soma_adat`
  object.

## Source

<https://github.com/SomaLogic/SomaLogic-Data>

SomaLogic Operating Co., Inc.

## Data Description

The `example_data` object contains a SomaScan V4 study from healthy
normal individuals. The RFU measurements themselves and other
identifiers have been altered to protect personally identifiable
information (PII), but also retain underlying biological signal as much
as possible. There are 192 total EDTA-plasma samples across two 96-well
plate runs which are broken down by the following types:

- 170 clinical samples (client study samples)

- 10 calibrators (replicate controls for combining data across runs)

- 6 QC samples (replicate controls used to assess run quality)

- 6 Buffer samples (no protein controls)

## Data Processing

The standard V4 data normalization procedure for EDTA-plasma samples was
applied to this dataset. For more details on the data standardization
process see the Data Standardization and File Specification Technical
Note. General details are outlined above.

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

# print header info
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

class(example_data)
#> [1] "soma_adat"  "data.frame"

# Features/Analytes
head(ex_analytes, 20L)
#>  [1] "seq.10000.28"  "seq.10001.7"   "seq.10003.15"  "seq.10006.25" 
#>  [5] "seq.10008.43"  "seq.10011.65"  "seq.10012.5"   "seq.10013.34" 
#>  [9] "seq.10014.31"  "seq.10015.119" "seq.10021.1"   "seq.10022.207"
#> [13] "seq.10023.32"  "seq.10024.44"  "seq.10030.8"   "seq.10034.16" 
#> [17] "seq.10035.6"   "seq.10036.201" "seq.10037.98"  "seq.10040.63" 

# Feature info table (annotations)
ex_anno_tbl
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

# Search via `filter()`
dplyr::filter(ex_anno_tbl, grepl("^MMP", Target))
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

# Lookup table -> targets
# MMP-9
ex_target_names$seq.2579.17
#> [1] "Matrix metalloproteinase-9"

# gender hormone FSH
tapply(example_data$seq.3032.11, example_data$Sex, median)
#>      F      M 
#> 3358.1  556.4 

# gender hormone LH
tapply(example_data$seq.2953.31, example_data$Sex, median)
#>      F      M 
#> 2693.8  883.6 

# Target lookup
ex_target_names$seq.2953.31     # tab-completion at console
#> [1] "Luteinizing hormone"

# Sample Type/Source
table(example_data$SampleType)
#> 
#>     Buffer Calibrator         QC     Sample 
#>          6         10          6        170 

# Sex/Gender Variable
table(example_data$Sex)
#> 
#>  F  M 
#> 85 85 

# Age Variable
summary(example_data$Age)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#>   18.00   46.00   55.00   55.66   67.00   77.00      22 
```
