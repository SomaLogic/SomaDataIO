#' Analyte Annotations, Col.Meta, and Row Info
#'
#' In a standard SomaLogic ADAT, the section of information that
#' sits directly above the measurement data (RFU data matrix) is
#' the column meta data (`Col.Meta`), which contains detailed information
#' and annotations about the analytes, [SeqId()]s, and their targets.
#' See section below for further information about available
#' fields and their descriptions. Use [getAnalyteInfo()] to
#' obtain an object containing this information for programmatic analyses,
#' and use [getMeta()] to obtain the column names representing the
#' row-specific meta data about the samples (see section below).
#'
#' @section Col Meta (Analyte Annotations):
#' Information describing the *analytes* is found to the above
#' the data matrix in a standard SomaLogic ADAT. This information may
#' consist of the any or all of the following:
#'
#' | __Field__          | __Description__                       | __Example__    |
#' | :----------------- | :------------------------------------ | :------------- |
#' | SeqId                         | SomaLogic sequence identifier                                    | 2182-54_1      |
#' | SeqidVersion                  | Version of SOMAmer sequence                                      | 2              |
#' | SomaId                        | Target identifier, of the form SLnnnnnn (8 characters in length) | SL000318       |
#' | TargetFullName                | Target name curated for consistency with UniProt name            | Complement C4b |
#' | Target                        | SomaLogic Target Name                                            | C4b            |
#' | UniProt                       | UniProt identifier(s)                                            | P0C0L4  P0C0L5 |
#' | EntrezGeneID                  | Entrez Gene Identifier(s)                                        | 720 721        |
#' | EntrezGeneSymbol              | Entrez Gene Symbol names                                         | C4A C4B        |
#' | Organism                      | Protein Source Organism                                          | Human          |
#' | Units                         | Relative Fluorescence Units                                      | RFU            |
#' | Type                          | SOMAmer target type                                              | Protein        |
#' | Dilution                      | Dilution mix assignment                                          | 0.01%          |
#' | PlateScale_Reference          | PlateScale reference value                                       | 1378.85        |
#' | CalReference                  | Calibration sample reference value                               | 1378.85        |
#' | medNormRef_ReferenceRFU       | Median normalization reference value                             | 490.342        |
#' | Cal_V4_\verb{<YY>_<SSS>_<PPP>}| Calibration scale factor (for given Year_Study_Plate)            | 0.64           |
#' | ColCheck                      | QC acceptance criteria across all plates/sets                    | PASS           |
#' | QcReference_\verb{<LLLLL>}    | QC sample reference value (for given QC lot)                     | PASS           |
#' | CalQcRatio_V4_\verb{<YY>_<SSS>_<PPP>} | Post calibration median QC ratio to reference (for given Year_Study_Plate) | 1.04 |
#'
#' @section Row Meta (Sample Annotations):
#' Information describing the *samples* is typically found to the left of
#' the data matrix in a standard SomaLogic ADAT. This information may
#' consist of clinical information provided by the client, or run-specific
#' diagnostic information included for assay quality control. Below are
#' some examples of what may be present in this section:
#'
#' | __Field__         | __Description__                                   | __Examples__   |
#' | :---------------- | :------------------------------------------------ | :------------- |
#' | PlateId           | Plate identifier                                  | V4-18-004_001, V4-18-004_002 |
#' | ScannerID         | Scanner used to analyze slide                     | SG12064173, SG14374437 |
#' | PlatePosition     | Location on 96 well plate (A1-H12)                | A1, H12              |
#' | SlideId           | Agilent slide barcode                             | 2.58E+11             |
#' | Subarray          | Agilent subarray (1 – 8)                          | 1,8                  |
#' | SampleId          | 1st form is Subject Identifier, 2nd form (calibrators, buffers) | 2031   |
#' | SampleType        | 1st form for clinical samples (Sample), 2nd form as above       | Sample, QC, Calibrator, Buffer |
#' | PercentDilution   | Highest concentration the SOMAmer dilution groups | 20                   |
#' | SampleMatrix      | Sample matrix                                     | Plasma-PPT           |
#' | Barcode           | 1D Barcode of aliquot                             | S622225              |
#' | Barcode2d         | 2D Barcode of aliquot                             | 1.91E+08             |
#' | SampleNotes       | Assay team sample observation                     | Cloudy, Low sample volume, Reddish |
#' | SampleDescription | Supplemental sample information                   | Plasma QC 1          |
#' | AssayNotes        | Assay team run observation                        | Beads aspirated, Leak/Hole, Smear  |
#' | TimePoint         | Sample time point                                 | Baseline             |
#' | ExtIdentifier     | Primary key for Subarray                          | EXID40000000032037   |
#' | SsfExtId          | Primary key for sample                            | EID102733            |
#' | SampleGroup       | Sample group                                      | A, B                 |
#' | SiteId            | Collection site                                   | SomaLogic, Covance   |
#' | TubeUniqueID      | Unique tube identifier                            | 1.12E+11             |
#' | CLI               | Cohort definition identifier                      | CLI6006F001          |
#' | HybControlNormScale | Hybridization control scale factor              | 0.948304             |
#' | RowCheck          | Normalization acceptance criteria for all row scale factors | PASS, FLAG |
#' | NormScale_0_5     | Median signal normalization scale factor (0.5% mix)    | 1.02718         |
#' | NormScale_0_005   | Median signal normalization scale factor (0.005% mix)  | 1.119754        |
#' | NormScale_20      | Median signal normalization scale factor (20% mix)     | 0.996148        |
#'
#' @examples
#' # Annotations/Col.Meta
#' tbl <- getAnalyteInfo(example_data)
#' tbl
#'
#' # Row/sample Meta
#' r_m <- getMeta(example_data)
#' head(r_m)
#'
#' # Normalization Scale Factors
#' grep("NormScale", r_m, value = TRUE)
#'
#' # adat subset
#' example_data[1:3, head(r_m)]
#' @name Col.Meta
#' @aliases colmeta annotations rowmeta
NULL
