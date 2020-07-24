#' Sample ADAT and ADAT Objects
#'
#' A series of 5 ADAT related objects bundled with `SomaDataIO`.
#' The SOMAmer (RFU) data frame (class `soma_adat`) contains
#' samples from the Covance reference collection which has been hybridization
#' normalized, followed by median normalization, and finally calibrated.
#'
#' These data are is derived from 20 plasma samples from healthy normal
#' individuals purchased by SomaLogic, Inc. from the Covance reference
#' repository. The `TimePoint` field refers to age at collection (< 50 = Young)
#' and the `SampleGroup` field refers to subject gender (M / F).
#'
#' @name SampleObjects
#' @aliases sample.adat ex_features ex_feature_table ex_target_names
#' @docType data
#' @format A sample ADAT object plus 4 ADAT related objects:
#'
#' \describe{
#'   \item{sample.adat}{a sample adat containing 20 clinical samples (rows)
#'   from the "Covance collection" (see Details), 1129 SOMAmers (columns/features),
#'   and 20 meta data columns. This data set has been hybridization normalized,
#'   median normalized, and calibrated.}
#'
#'   \item{ex_features}{sample character string of the SOMAmers contained in the
#'   `soma_adat` object, derived from a call to \code{\link{getFeatures}}.}
#'
#'   \item{ex_feature_table}{sample `feature_table` object corresponding to a
#'   transposed data frame of the "Col.Meta" of an ADAT, derived from a call to
#'   \code{\link{getFeatureData}}.}
#'
#'   \item{ex_target_names}{A lookup table of target names; a list of
#'   character strings corresponding to the *target* names of the SOMAmers
#'   contained in the `soma_adat` object. Again, this object is convenient
#'   at the command line via auto-complete for labeling and creating plot titles.}
#' }
#'
#' @references SomaLogic, Inc., Covance Plasma
#' @source SomaLogic Inc. Covance Plasma collection.
#' @keywords datasets
#' @examples
#' # S3 print method
#' sample.adat
#'
#' class(sample.adat)
#'
#' # Features/Analytes
#' head(ex_features, 20)
#'
#' # Feature info table
#' head(ex_feature_table)
#'
#' # Lookup table - targets
#' # MMP7
#' ex_target_names$seq.2789.26
#'
#' # gender hormone FSH
#' tapply(sample.adat$seq.3032.11, sample.adat$SampleGroup, median)
#'
#' # gender hormone LH
#' tapply(sample.adat$seq.2953.31, sample.adat$SampleGroup, median)
NULL
