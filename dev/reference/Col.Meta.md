# Analyte Annotations, Col.Meta, and Row Info

In a standard SomaLogic ADAT, the section of information that sits
directly above the measurement data (RFU data matrix) is the column meta
data (`Col.Meta`), which contains detailed information and annotations
about the analytes,
[`SeqId()`](https://somalogic.github.io/SomaDataIO/dev/reference/SeqId.md)s,
and their targets. See section below for further information about
available fields and their descriptions. Use
[`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md)
to obtain an object containing this information for programmatic
analyses, and use
[`getMeta()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalytes.md)
to obtain the column names representing the row-specific meta data about
the samples (see section below).

## Col Meta (Analyte Annotations)

Information describing the *analytes* is found to the above the data
matrix in a standard SomaLogic ADAT. This information may consist of the
any or all of the following:

|                                   |                                                                            |                |
|-----------------------------------|----------------------------------------------------------------------------|----------------|
| **Field**                         | **Description**                                                            | **Example**    |
| SeqId                             | SomaLogic sequence identifier                                              | 2182-54_1      |
| SeqidVersion                      | Version of SOMAmer sequence                                                | 2              |
| SomaId                            | Target identifier, of the form SLnnnnnn (8 characters in length)           | SL000318       |
| TargetFullName                    | Target name curated for consistency with UniProt name                      | Complement C4b |
| Target                            | SomaLogic Target Name                                                      | C4b            |
| UniProt                           | UniProt identifier(s)                                                      | P0C0L4 P0C0L5  |
| EntrezGeneID                      | Entrez Gene Identifier(s)                                                  | 720 721        |
| EntrezGeneSymbol                  | Entrez Gene Symbol names                                                   | C4A C4B        |
| Organism                          | Protein Source Organism                                                    | Human          |
| Units                             | Relative Fluorescence Units                                                | RFU            |
| Type                              | SOMAmer target type                                                        | Protein        |
| Dilution                          | Dilution mix assignment                                                    | 0.01%          |
| PlateScale_Reference              | PlateScale reference value                                                 | 1378.85        |
| CalReference                      | Calibration sample reference value                                         | 1378.85        |
| medNormRef_ReferenceRFU           | Median normalization reference value                                       | 490.342        |
| Cal_V4\_`<YY>_<SSS>_<PPP>`        | Calibration scale factor (for given Year_Study_Plate)                      | 0.64           |
| ColCheck                          | QC acceptance criteria across all plates/sets                              | PASS           |
| QcReference\_`<LLLLL>`            | QC sample reference value (for given QC lot)                               | PASS           |
| CalQcRatio_V4\_`<YY>_<SSS>_<PPP>` | Post calibration median QC ratio to reference (for given Year_Study_Plate) | 1.04           |

## Row Meta (Sample Annotations)

Information describing the *samples* is typically found to the left of
the data matrix in a standard SomaLogic ADAT. This information may
consist of clinical information provided by the client, or run-specific
diagnostic information included for assay quality control. Below are
some examples of what may be present in this section:

|                     |                                                                 |                                    |
|---------------------|-----------------------------------------------------------------|------------------------------------|
| **Field**           | **Description**                                                 | **Examples**                       |
| PlateId             | Plate identifier                                                | V4-18-004_001, V4-18-004_002       |
| ScannerID           | Scanner used to analyze slide                                   | SG12064173, SG14374437             |
| PlatePosition       | Location on 96 well plate (A1-H12)                              | A1, H12                            |
| SlideId             | Agilent slide barcode                                           | 2.58E+11                           |
| Subarray            | Agilent subarray (1 – 8)                                        | 1,8                                |
| SampleId            | 1st form is Subject Identifier, 2nd form (calibrators, buffers) | 2031                               |
| SampleType          | 1st form for clinical samples (Sample), 2nd form as above       | Sample, QC, Calibrator, Buffer     |
| PercentDilution     | Highest concentration the SOMAmer dilution groups               | 20                                 |
| SampleMatrix        | Sample matrix                                                   | Plasma-PPT                         |
| Barcode             | 1D Barcode of aliquot                                           | S622225                            |
| Barcode2d           | 2D Barcode of aliquot                                           | 1.91E+08                           |
| SampleNotes         | Assay team sample observation                                   | Cloudy, Low sample volume, Reddish |
| SampleDescription   | Supplemental sample information                                 | Plasma QC 1                        |
| AssayNotes          | Assay team run observation                                      | Beads aspirated, Leak/Hole, Smear  |
| TimePoint           | Sample time point                                               | Baseline                           |
| ExtIdentifier       | Primary key for Subarray                                        | EXID40000000032037                 |
| SsfExtId            | Primary key for sample                                          | EID102733                          |
| SampleGroup         | Sample group                                                    | A, B                               |
| SiteId              | Collection site                                                 | SomaLogic, Covance                 |
| TubeUniqueID        | Unique tube identifier                                          | 1.12E+11                           |
| CLI                 | Cohort definition identifier                                    | CLI6006F001                        |
| HybControlNormScale | Hybridization control scale factor                              | 0.948304                           |
| RowCheck            | Normalization acceptance criteria for all row scale factors     | PASS, FLAG                         |
| NormScale_0_5       | Median signal normalization scale factor (0.5% mix)             | 1.02718                            |
| NormScale_0_005     | Median signal normalization scale factor (0.005% mix)           | 1.119754                           |
| NormScale_20        | Median signal normalization scale factor (20% mix)              | 0.996148                           |

## Examples

``` r
# Annotations/Col.Meta
tbl <- getAnalyteInfo(example_data)
tbl
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

# Row/sample Meta
r_m <- getMeta(example_data)
head(r_m)
#> [1] "PlateId"       "PlateRunDate"  "ScannerID"     "PlatePosition"
#> [5] "SlideId"       "Subarray"     

# Normalization Scale Factors
grep("NormScale", r_m, value = TRUE)
#> [1] "HybControlNormScale" "NormScale_20"        "NormScale_0_005"    
#> [4] "NormScale_0_5"      

# adat subset
example_data[1:3, head(r_m)]
#> ══ SomaScan Data ══════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 3
#>      Columns              6
#>      Clinical Data        6
#>      Features             0
#> ── Column Meta ────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target,
#> ℹ UniProt, EntrezGeneID, EntrezGeneSymbol, Organism, Units,
#> ℹ Type, Dilution, PlateScale_Reference, CalReference,
#> ℹ Cal_Example_Adat_Set001, ColCheck,
#> ℹ CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002,
#> ℹ CalQcRatio_Example_Adat_Set002_170255, Dilution2
#> ── Tibble ─────────────────────────────────────────────────────────────
#> # A tibble: 3 × 7
#>   row_names      PlateId   PlateRunDate ScannerID PlatePosition SlideId
#>   <chr>          <chr>     <chr>        <chr>     <chr>           <dbl>
#> 1 258495800012_3 Example … 2020-06-18   SG152144… H9            2.58e11
#> 2 258495800004_7 Example … 2020-06-18   SG152144… H8            2.58e11
#> 3 258495800010_8 Example … 2020-06-18   SG152144… H7            2.58e11
#> # ℹ 1 more variable: Subarray <dbl>
#> ═══════════════════════════════════════════════════════════════════════
```
