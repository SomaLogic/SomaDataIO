# Loading and Wrangling 'SomaScan'

## Loading an ADAT

Load an ADAT text file into `R` memory with:

``` r
# path to *.adat file
# replace with your file path
adat_path <- system.file("extdata", "example_data10.adat",
                         package = "SomaDataIO", mustWork = TRUE)
adat_path
#> [1] "/Users/runner/work/_temp/Library/SomaDataIO/extdata/example_data10.adat"

my_adat <- read_adat(adat_path)

# class test
is.soma_adat(my_adat)
#> [1] TRUE

# S3 print method forwards -> tibble
my_adat
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 10
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt,
#> ℹ EntrezGeneID, EntrezGeneSymbol, Organism, Units, Type, Dilution,
#> ℹ PlateScale_Reference, CalReference, Cal_Example_Adat_Set001,
#> ℹ ColCheck, CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255,
#> ℹ Dilution2
#> ── Tibble ──────────────────────────────────────────────────────────────────────
#> # A tibble: 10 × 5,319
#>    row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId Subarray
#>    <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>    <dbl>
#>  1 258495800012_3 Example… 2020-06-18   SG152144… H9            2.58e11        3
#>  2 258495800004_7 Example… 2020-06-18   SG152144… H8            2.58e11        7
#>  3 258495800010_8 Example… 2020-06-18   SG152144… H7            2.58e11        8
#>  4 258495800003_4 Example… 2020-06-18   SG152144… H6            2.58e11        4
#>  5 258495800009_4 Example… 2020-06-18   SG152144… H5            2.58e11        4
#>  6 258495800012_8 Example… 2020-06-18   SG152144… H4            2.58e11        8
#>  7 258495800001_3 Example… 2020-06-18   SG152144… H3            2.58e11        3
#>  8 258495800004_8 Example… 2020-06-18   SG152144… H2            2.58e11        8
#>  9 258495800001_8 Example… 2020-06-18   SG152144… H12           2.58e11        8
#> 10 258495800004_3 Example… 2020-06-18   SG152144… H11           2.58e11        3
#> # ℹ 5,312 more variables: SampleId <chr>, SampleType <chr>,
#> #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
#> #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
#> #   SampleDescription <chr>, …
#> ════════════════════════════════════════════════════════════════════════════════

print(my_adat, show_header = TRUE)  # if simply wish to see Header info
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 10
#>      Columns              5318
#>      Clinical Data        34
#>      Features             5284
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt,
#> ℹ EntrezGeneID, EntrezGeneSymbol, Organism, Units, Type, Dilution,
#> ℹ PlateScale_Reference, CalReference, Cal_Example_Adat_Set001,
#> ℹ ColCheck, CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255,
#> ℹ Dilution2
#> ── Header Data ─────────────────────────────────────────────────────────────────
#> # A tibble: 35 × 2
#>    Key                  Value                                                   
#>    <chr>                <chr>                                                   
#>  1 AdatId               GID-1234-56-789-abcdef                                  
#>  2 Version              1.2                                                     
#>  3 AssayType            PharmaServices                                          
#>  4 AssayVersion         V4                                                      
#>  5 AssayRobot           Fluent 1 L-307                                          
#>  6 Legal                Experiment details and data have been processed to prot…
#>  7 CreatedBy            PharmaServices                                          
#>  8 CreatedDate          2020-07-24                                              
#>  9 EnteredBy            Technician1                                             
#> 10 ExpDate              2020-06-18, 2020-07-20                                  
#> 11 GeneratedBy          Px (Build:  : ), Canopy_0.1.1                           
#> 12 RunNotes             2 columns ('Age' and 'Sex') have been added to this ADA…
#> 13 ProcessSteps         Raw RFU, Hyb Normalization, medNormInt (SampleId), plat…
#> 14 ProteinEffectiveDate 2019-08-06                                              
#> 15 StudyMatrix          EDTA Plasma                                             
#> # ℹ 20 more rows
#> ════════════════════════════════════════════════════════════════════════════════

# S3 summary method
# View Target and summary statistics
seqs <- tail(names(my_adat), 3L)
summary(my_adat[, seqs])
#>  seq.9995.6          seq.9997.12         seq.9999.1          
#>  Target : DUT        Target : UBXN4      Target : IRF6       
#>  Min    :  1138      Min    :  4427      Min    :  851.9     
#>  1Q     :  1535      1Q     : 12423      1Q     : 1306.6     
#>  Median :  3861      Median : 20292      Median : 2847.9     
#>  Mean   :  5189      Mean   : 26058      Mean   : 3206.0     
#>  3Q     :  9343      3Q     : 41184      3Q     : 4641.7     
#>  Max    : 10171      Max    : 50390      Max    : 6978.9     
#>  sd     :  3983      sd     : 17420      sd     : 2164.4     
#>  MAD    :  3938      MAD    : 19516      MAD    : 2387.2     
#>  IQR    :  7807      IQR    : 28761      IQR    : 3335.1

# Summarize by Sex
my_adat[, seqs] |>
  split(my_adat$Sex) |>
  lapply(summary)
#> $F
#>  seq.9995.6          seq.9997.12         seq.9999.1          
#>  Target : DUT        Target : UBXN4      Target : IRF6       
#>  Min    :  2104      Min    : 13742      Min    : 1253       
#>  1Q     :  3898      1Q     : 20719      1Q     : 2190       
#>  Median :  9211      Median : 40743      Median : 4546       
#>  Mean   :  7104      Mean   : 34683      Mean   : 4048       
#>  3Q     :  9652      3Q     : 46513      3Q     : 5307       
#>  Max    : 10171      Max    : 50390      Max    : 6979       
#>  sd     :  3851      sd     : 16464      sd     : 2268       
#>  MAD    :  1082      MAD    : 12636      MAD    : 2508       
#>  IQR    :  5754      IQR    : 25794      IQR    : 3116       
#> 
#> $M
#>  seq.9995.6          seq.9997.12         seq.9999.1          
#>  Target : DUT        Target : UBXN4      Target : IRF6       
#>  Min    : 1137.7     Min    :  9829      Min    : 1222.8     
#>  1Q     : 1241.7     1Q     : 10906      1Q     : 1482.1     
#>  Median : 1345.6     Median : 11983      Median : 1741.4     
#>  Mean   : 2663.8     Mean   : 16019      Mean   : 2306.2     
#>  3Q     : 3426.8     3Q     : 19114      3Q     : 2847.9     
#>  Max    : 5508.0     Max    : 26246      Max    : 3954.3     
#>  sd     : 2465.4     sd     :  8922      sd     : 1450.7     
#>  MAD    :  308.2     MAD    :  3193      MAD    :  768.9     
#>  IQR    : 2185.2     IQR    :  8208      IQR    : 1365.8
```

### Debugging

Occasionally “problematic” ADATs can be difficult to parse. For this
purpose a convenient `debug = TRUE` argument to
[`read_adat()`](https://somalogic.github.io/SomaDataIO/reference/read_adat.md)
allows you to inspect the file specifications that `R` *thinks* exist in
the file. This can be useful in identifying where/why/how a parse
failure has occurred. It is recommended to view this output and compare
to the physical text file itself to identify any misidentified or
mismatched landmarks:

``` r
read_adat(adat_path, debug = TRUE)
#> ══ Parsing Specs ═══════════════════════════════════════════════════════════════
#> 45
#> • Table Begin
#> 46
#> • Col.Meta Start
#> 35
#> • Col.Meta Shift
#> 66
#> • Header Row
#> 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, and
#> 65
#> • Rows of the Col Meta      
#> ── Col Meta ────────────────────────────────────────────────────────────── 20 ──
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt,
#> ℹ EntrezGeneID, EntrezGeneSymbol, Organism, Units, Type, Dilution,
#> ℹ PlateScale_Reference, CalReference, Cal_Example_Adat_Set001,
#> ℹ ColCheck, CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255
#> ── Row Meta ────────────────────────────────────────────────────────────── 34 ──
#> ℹ PlateId, PlateRunDate, ScannerID, PlatePosition, SlideId, Subarray,
#> ℹ SampleId, SampleType, PercentDilution, SampleMatrix, Barcode,
#> ℹ Barcode2d, SampleName, SampleNotes, AliquotingNotes,
#> ℹ SampleDescription, AssayNotes, TimePoint, ExtIdentifier, SsfExtId,
#> ℹ SampleGroup, SiteId, TubeUniqueID, CLI, HybControlNormScale,
#> ℹ RowCheck, NormScale_20, NormScale_0_005, NormScale_0_5,
#> ℹ ANMLFractionUsed_20, ANMLFractionUsed_0_005, ANMLFractionUsed_0_5,
#> ℹ Age, Sex
#> ── Empty Strings Detected in Col.Meta ───────────────────────────────────── ! ──
#> → Visually inspect the following Col.Meta rows: "TargetFullName", "UniProt", "EntrezGeneID", and "EntrezGeneSymbol"
#> ℹ They may be missing in:
#> "Spuriomers" and "HybControls"
#> NULL
#> → This is non-critical in ADATs with new "seq.1234.56" format.
#> ══ Parse Diagnostic Complete ═══════════════════════════════════════════════════
```

------------------------------------------------------------------------

## Wrangling

### Attributes Contain File and Feature Information

``` r
names(attributes(my_adat))
#> [1] "names"       "class"       "row.names"   "Header.Meta" "Col.Meta"   
#> [6] "file_specs"  "row_meta"

# The `Col.Meta` attribute contains
# target annotation information
attr(my_adat, "Col.Meta")
#> # A tibble: 5,284 × 21
#>    SeqId     SeqIdVersion SomaId   TargetFullName    Target UniProt EntrezGeneID
#>    <chr>            <dbl> <chr>    <chr>             <chr>  <chr>   <chr>       
#>  1 10000-28             3 SL019233 Beta-crystallin … CRBB2  P43320  "1415"      
#>  2 10001-7              3 SL002564 RAF proto-oncoge… c-Raf  P04049  "5894"      
#>  3 10003-15             3 SL019245 Zinc finger prot… ZNF41  P51814  "7592"      
#>  4 10006-25             3 SL019228 ETS domain-conta… ELK1   P19419  "2002"      
#>  5 10008-43             3 SL019234 Guanylyl cyclase… GUC1A  P43080  "2978"      
#>  6 10011-65             3 SL019246 Inositol polypho… OCRL   Q01968  "4952"      
#>  7 10012-5              3 SL014669 SAM pointed doma… SPDEF  O95238  "25803"     
#>  8 10013-34             3 SL025418 Fc_MOUSE          Fc_MO… Q99LC4  ""          
#>  9 10014-31             3 SL007803 Zinc finger prot… SLUG   O43623  "6591"      
#> 10 10015-119            3 SL014924 Voltage-gated po… KCAB2  Q13303  "8514"      
#> # ℹ 5,274 more rows
#> # ℹ 14 more variables: EntrezGeneSymbol <chr>, Organism <chr>, Units <chr>,
#> #   Type <chr>, Dilution <chr>, PlateScale_Reference <dbl>, CalReference <dbl>,
#> #   Cal_Example_Adat_Set001 <dbl>, ColCheck <chr>,
#> #   CalQcRatio_Example_Adat_Set001_170255 <dbl>, QcReference_170255 <dbl>,
#> #   Cal_Example_Adat_Set002 <dbl>, CalQcRatio_Example_Adat_Set002_170255 <dbl>,
#> #   Dilution2 <dbl>
```

### Analyte Features (`seq.xxxx.xx`)

``` r
getAnalytes(my_adat) |> head(20L)    # first 20 analytes; see AptName above
#>  [1] "seq.10000.28"  "seq.10001.7"   "seq.10003.15"  "seq.10006.25" 
#>  [5] "seq.10008.43"  "seq.10011.65"  "seq.10012.5"   "seq.10013.34" 
#>  [9] "seq.10014.31"  "seq.10015.119" "seq.10021.1"   "seq.10022.207"
#> [13] "seq.10023.32"  "seq.10024.44"  "seq.10030.8"   "seq.10034.16" 
#> [17] "seq.10035.6"   "seq.10036.201" "seq.10037.98"  "seq.10040.63"
getAnalytes(my_adat) |> length()     # how many analytes
#> [1] 5284
getAnalytes(my_adat, n = TRUE)       # the `n` argument; no. analytes
#> [1] 5284
```

### Feature Data

The
[`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/reference/getAnalyteInfo.md)
function creates a lookup table that links analyte feature names in the
`soma_adat` object to the annotation data in
[`?Col.Meta`](https://somalogic.github.io/SomaDataIO/reference/Col.Meta.md)
via the common index-key, `AptName`, in column 1:

``` r
getAnalyteInfo(my_adat)
#> # A tibble: 5,284 × 22
#>    AptName  SeqId SeqIdVersion SomaId TargetFullName Target UniProt EntrezGeneID
#>    <chr>    <chr>        <dbl> <chr>  <chr>          <chr>  <chr>   <chr>       
#>  1 seq.100… 1000…            3 SL019… Beta-crystall… CRBB2  P43320  "1415"      
#>  2 seq.100… 1000…            3 SL002… RAF proto-onc… c-Raf  P04049  "5894"      
#>  3 seq.100… 1000…            3 SL019… Zinc finger p… ZNF41  P51814  "7592"      
#>  4 seq.100… 1000…            3 SL019… ETS domain-co… ELK1   P19419  "2002"      
#>  5 seq.100… 1000…            3 SL019… Guanylyl cycl… GUC1A  P43080  "2978"      
#>  6 seq.100… 1001…            3 SL019… Inositol poly… OCRL   Q01968  "4952"      
#>  7 seq.100… 1001…            3 SL014… SAM pointed d… SPDEF  O95238  "25803"     
#>  8 seq.100… 1001…            3 SL025… Fc_MOUSE       Fc_MO… Q99LC4  ""          
#>  9 seq.100… 1001…            3 SL007… Zinc finger p… SLUG   O43623  "6591"      
#> 10 seq.100… 1001…            3 SL014… Voltage-gated… KCAB2  Q13303  "8514"      
#> # ℹ 5,274 more rows
#> # ℹ 14 more variables: EntrezGeneSymbol <chr>, Organism <chr>, Units <chr>,
#> #   Type <chr>, Dilution <chr>, PlateScale_Reference <dbl>, CalReference <dbl>,
#> #   Cal_Example_Adat_Set001 <dbl>, ColCheck <chr>,
#> #   CalQcRatio_Example_Adat_Set001_170255 <dbl>, QcReference_170255 <dbl>,
#> #   Cal_Example_Adat_Set002 <dbl>, CalQcRatio_Example_Adat_Set002_170255 <dbl>,
#> #   Dilution2 <dbl>
```

### Clinical Data

``` r
getMeta(my_adat)             # clinical meta data for each sample
#>  [1] "PlateId"                "PlateRunDate"           "ScannerID"             
#>  [4] "PlatePosition"          "SlideId"                "Subarray"              
#>  [7] "SampleId"               "SampleType"             "PercentDilution"       
#> [10] "SampleMatrix"           "Barcode"                "Barcode2d"             
#> [13] "SampleName"             "SampleNotes"            "AliquotingNotes"       
#> [16] "SampleDescription"      "AssayNotes"             "TimePoint"             
#> [19] "ExtIdentifier"          "SsfExtId"               "SampleGroup"           
#> [22] "SiteId"                 "TubeUniqueID"           "CLI"                   
#> [25] "HybControlNormScale"    "RowCheck"               "NormScale_20"          
#> [28] "NormScale_0_005"        "NormScale_0_5"          "ANMLFractionUsed_20"   
#> [31] "ANMLFractionUsed_0_005" "ANMLFractionUsed_0_5"   "Age"                   
#> [34] "Sex"
getMeta(my_adat, n = TRUE)   # also an `n` argument
#> [1] 34
```

### ADAT structure

The `soma_adat` object also contains specific structure that are useful
to users. Please also see
[`?colmeta`](https://somalogic.github.io/SomaDataIO/reference/Col.Meta.md)
or
[`?annotations`](https://somalogic.github.io/SomaDataIO/reference/Col.Meta.md)
for further details about these fields.

------------------------------------------------------------------------

### Group Generics

You may perform basic mathematical transformations on the feature data
*only* with special `soma_adat` S3 methods (see
[`?groupGenerics`](https://somalogic.github.io/SomaDataIO/reference/groupGenerics.md)):

``` r
head(my_adat$seq.2429.27)
#> [1]  8642.3 12472.1 14627.7 13579.8  8938.8  6738.8

logData <- log10(my_adat)    # a typical log10() transform
head(logData$seq.2429.27)
#> [1] 3.936629 4.095940 4.165176 4.132893 3.951279 3.828583

roundData <- round(my_adat)
head(roundData$seq.2429.27)
#> [1]  8642 12472 14628 13580  8939  6739

sqData <- sqrt(my_adat)
head(sqData$seq.2429.27)
#> [1]  92.96397 111.67856 120.94503 116.53240  94.54523  82.09019

antilog(1:4)
#> [1]    10   100  1000 10000

sum(my_adat < 100)  # low signalling values
#> [1] 693

all.equal(my_adat, sqrt(my_adat^2))
#> [1] TRUE

all.equal(my_adat, antilog(log10(my_adat)))
#> [1] TRUE
```

#### Math Generics

``` r
getGroupMembers("Math")
#>  [1] "abs"      "sign"     "sqrt"     "ceiling"  "floor"    "trunc"   
#>  [7] "cummax"   "cummin"   "cumprod"  "cumsum"   "exp"      "expm1"   
#> [13] "log"      "log10"    "log2"     "log1p"    "cos"      "cosh"    
#> [19] "sin"      "sinh"     "tan"      "tanh"     "acos"     "acosh"   
#> [25] "asin"     "asinh"    "atan"     "atanh"    "cospi"    "sinpi"   
#> [31] "tanpi"    "gamma"    "lgamma"   "digamma"  "trigamma"

getGroupMembers("Compare")
#> [1] "==" ">"  "<"  "!=" "<=" ">="

getGroupMembers("Arith")
#> [1] "+"   "-"   "*"   "^"   "%%"  "%/%" "/"

getGroupMembers("Summary")
#> [1] "max"   "min"   "range" "prod"  "sum"   "any"   "all"
```

### Full Complement of [dplyr](https://dplyr.tidyverse.org) S3 Methods

The `soma_adat` also comes with numerous class specific methods to the
most popular [dplyr](https://dplyr.tidyverse.org) generics that make
working with `soma_adat` objects simpler for those familiar with this
standard toolkit:

``` r
dim(my_adat)
#> [1]   10 5318
males <- dplyr::filter(my_adat, Sex == "M")
dim(males)
#> [1]    3 5318

males |>
  dplyr::select(SampleType, SampleMatrix, starts_with("NormScale"))
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 3
#>      Columns              5
#>      Clinical Data        5
#>      Features             0
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt,
#> ℹ EntrezGeneID, EntrezGeneSymbol, Organism, Units, Type, Dilution,
#> ℹ PlateScale_Reference, CalReference, Cal_Example_Adat_Set001,
#> ℹ ColCheck, CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255,
#> ℹ Dilution2
#> ── Tibble ──────────────────────────────────────────────────────────────────────
#> # A tibble: 3 × 6
#>   row_names   SampleType SampleMatrix NormScale_20 NormScale_0_005 NormScale_0_5
#>   <chr>       <chr>      <chr>               <dbl>           <dbl>         <dbl>
#> 1 2584958000… Sample     Plasma-PPT          0.984           1.03          0.915
#> 2 2584958000… Sample     Plasma-PPT          1.08            0.946         0.912
#> 3 2584958000… Sample     Plasma-PPT          0.921           1.13          0.953
#> ════════════════════════════════════════════════════════════════════════════════
```

#### Merging Sample Annotation Data

The `example_data` object includes some sample annotation data built-in,
with the variables `Age` and `Sex` included for clinical samples, but in
practice ADAT files generally do not have any clinical or sample
annotation data fields included.

To merge sample annotation data into an existing `soma_adat` class
object, use the
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
method. Here, joining the `ex_clin_data` `tibble` object adds in two
additional clinical variables, `smoking_status` and `alcohol_use`:

``` r
# `clin_path` should be the elaborated path and file name of the *.csv or
# similar file to be loaded into the R workspace from your local file system
# (e.g. clin_path = "PATH_TO_CLIN/clin_data.csv")
# clin_data <- readr::read_csv(clin_path)

merged_adat <- my_adat |> 
  dplyr::left_join(ex_clin_data, by = "SampleId") 

merged_adat |> 
  dplyr::select(SampleId, Age, Sex, smoking_status, alcohol_use) |> 
  head(n = 3)
#> ══ SomaScan Data ═══════════════════════════════════════════════════════════════
#>      SomaScan version     V4 (5k)
#>      Signal Space         5k
#>      Attributes intact    ✓
#>      Rows                 3
#>      Columns              5
#>      Clinical Data        5
#>      Features             0
#> ── Column Meta ─────────────────────────────────────────────────────────────────
#> ℹ SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt,
#> ℹ EntrezGeneID, EntrezGeneSymbol, Organism, Units, Type, Dilution,
#> ℹ PlateScale_Reference, CalReference, Cal_Example_Adat_Set001,
#> ℹ ColCheck, CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
#> ℹ Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255,
#> ℹ Dilution2
#> ── Tibble ──────────────────────────────────────────────────────────────────────
#> # A tibble: 3 × 6
#>   row_names      SampleId   Age Sex   smoking_status alcohol_use
#>   <chr>          <chr>    <int> <chr> <chr>          <chr>      
#> 1 258495800012_3 1           76 F     Never          Yes        
#> 2 258495800004_7 2           55 F     Never          Yes        
#> 3 258495800010_8 3           47 M     Never          No         
#> ════════════════════════════════════════════════════════════════════════════════
```

### Available S3 Methods `soma_adat`

``` r
# see full complement of `soma_adat` methods
methods(class = "soma_adat")
#>  [1] [              [[             [[<-           [<-            ==            
#>  [6] $              $<-            anti_join      arrange        count         
#> [11] filter         full_join      getAdatVersion getAnalytes    getMeta       
#> [16] group_by       inner_join     is_seqFormat   left_join      Math          
#> [21] median         merge          mutate         Ops            print         
#> [26] rename         right_join     row.names<-    sample_frac    sample_n      
#> [31] semi_join      separate       slice_sample   slice          summary       
#> [36] Summary        transform      ungroup        unite         
#> see '?methods' for accessing help and source code
```

------------------------------------------------------------------------

## Writing a `soma_adat`

``` r
is_intact_attr(my_adat)   # MUST have intact attrs
#> [1] TRUE

write_adat(my_adat, file = tempfile("my-adat-", fileext = ".adat"))
#> ✔ ADAT passed all checks and traps.
#> ✔ ADAT written to: "/var/folders/05/lw6x4b813x3_l5mvmn51kvlc0000gn/T//RtmpMnuZq9/my-adat-6fdd1a1714e1.adat"
```
