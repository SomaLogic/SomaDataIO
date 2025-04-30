#' Example Data and Objects
#'
#' The `example_data` object is intended to provide existing and prospective
#' SomaLogic customers with example data to enable analysis preparation prior
#' to receipt of SomaScan data, and also for those generally curious about the
#' SomaScan data deliverable. It is **not** intended to be used as a control
#' group for studies or provide any metrics for SomaScan data in general.
#'
#' @name SomaScanObjects
#' @aliases example_data ex_analytes ex_anno_tbl ex_target_names ex_clin_data
#' @docType data
#'
#' @section Data Description:
#'   The `example_data` object contains a SomaScan V4 study from healthy
#'   normal individuals. The RFU measurements themselves and other identifiers
#'   have been altered to protect personally identifiable information (PII),
#'   but also retain underlying biological signal as much as possible.
#'   There are 192 total EDTA-plasma samples across two 96-well plate runs
#'   which are broken down by the following types:
#'   * 170 clinical samples (client study samples)
#'   * 10 calibrators (replicate controls for combining data across runs)
#'   * 6 QC samples (replicate controls used to assess run quality)
#'   * 6 Buffer samples (no protein controls)
#'
#' @section Data Processing:
#'   The standard V4 data normalization procedure for EDTA-plasma samples was
#'   applied to this dataset. For more details on the data standardization process
#'   see the Data Standardization and File Specification Technical Note. General
#'   details are outlined above.
#'
#' @format
#' \describe{
#'   \item{example_data}{a `soma_adat` parsed via [read_adat()] containing
#'     192 samples (see below for breakdown of sample type). There are 5318
#'     columns containing 5284 analyte features and 34 clinical meta data fields.
#'     These data have been pre-processed via the following steps:
#'       \itemize{
#'         \item hybridization normalized (all samples)
#'         \item calibrators and buffers median normalized
#'         \item plate scaled
#'         \item calibrated
#'         \item Adaptive Normalization by Maximum Likelihood (ANML) of
#'           QC and clinical samples
#'       }
#'     **Note1:** The `Age` and `Sex` (`M`/`F`) fields contain simulated values
#'     designed to contain biological signal.
#'
#'     **Note2:** The `SampleType` column contains sample source/type information
#'     and usually the `SampleType == Sample` represents the "client" samples.
#'
#'     **Note3:** The original source file can be found at
#'     \url{https://github.com/SomaLogic/SomaLogic-Data}.
#'   }
#'
#'   \item{ex_analytes}{character string of the analyte features contained
#'     in the `soma_adat` object, derived from a call to [getAnalytes()].}
#'
#'   \item{ex_anno_tbl}{a lookup table corresponding to a
#'     transposed data frame of the "Col.Meta" attribute of an ADAT, with an
#'     index key field `AptName` included in column 1, derived from a call to
#'     [getAnalyteInfo()].}
#'
#'   \item{ex_target_names}{A lookup table mapping `SeqId` feature names ->
#'     target names contained in `example_data`. This object (or one like it) is
#'     convenient at the console via auto-complete for labeling and/or creating
#'     plot titles on the fly.}
#'
#'   \item{ex_clin_data}{A table containing `SampleId`, `smoking_status`, and
#'     `alcohol_use` fields for each clinical sample in `example_data` used to
#'     demonstrate how to merge sample annotation information to an existing
#'     `soma_adat` object.}
#' }
#'
#' @source \url{https://github.com/SomaLogic/SomaLogic-Data}
#' @source Standard BioTools, Inc.
#' @keywords datasets
#' @examples
#' # S3 print method
#' example_data
#'
#' # print header info
#' print(example_data, show_header = TRUE)
#'
#' class(example_data)
#'
#' # Features/Analytes
#' head(ex_analytes, 20L)
#'
#' # Feature info table (annotations)
#' ex_anno_tbl
#'
#' # Search via `filter()`
#' dplyr::filter(ex_anno_tbl, grepl("^MMP", Target))
#'
#' # Lookup table -> targets
#' # MMP-9
#' ex_target_names$seq.2579.17
#'
#' # gender hormone FSH
#' tapply(example_data$seq.3032.11, example_data$Sex, median)
#'
#' # gender hormone LH
#' tapply(example_data$seq.2953.31, example_data$Sex, median)
#'
#' # Target lookup
#' ex_target_names$seq.2953.31     # tab-completion at console
#'
#' # Sample Type/Source
#' table(example_data$SampleType)
#'
#' # Sex/Gender Variable
#' table(example_data$Sex)
#'
#' # Age Variable
#' summary(example_data$Age)
NULL
