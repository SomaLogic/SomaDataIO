#' Deprecated function(s) of the \pkg{SomaDataIO} package
#'
#' These functions are provided for compatibility with
#' older versions of the \pkg{SomaDataIO} package.
#' They may eventually be completely removed, so
#' please re-code your scripts accordingly.
#'
#' \tabular{rl}{
#'   `meltExpressionSet()` \tab now use [pivotExpressionSet()] \cr
#'   `getSomamers()`       \tab now use [getAnalytes()] \cr
#'   `getFeatures()`       \tab now use [getAnalytes()] \cr
#'   `getSomamerData()`    \tab now use [getAnalyteInfo()] \cr
#'   `getFeatureData()`    \tab now use [getAnalyteInfo()]
#' }
#'
#' @rdname SomaDataIO-deprecated
#' @name SomaDataIO-deprecated
#' @docType package
#' @author Stu Field
#' @param ... A simple argument pass-through to an alternative replacement
#'   function if available.
#' @aliases meltExpressionSet getSomamers getSomamerData
#' @export meltExpressionSet getSomamers getSomamerData
#' @importFrom lifecycle deprecate_warn deprecate_stop
NULL



#' @describeIn getAnalyteInfo renamed in \pkg{SomaDataIO v5.1.0}. Exported
#' (with life-cycle warning) to maintain backward compatibility.
#' Please adjust your code accordingly.
#' @export
getFeatureData <- function(adat) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatureData()", "getAnalyteInfo()")
  getAnalyteInfo(adat)
}

#' @describeIn getAnalytes renamed in \pkg{SomaDataIO v5.1.0}. Exported
#' (with life-cycle warning) to maintain backward compatibility.
#' Please adjust your code accordingly.
#' @export
getFeatures <- function(x, n = FALSE, rm.controls = FALSE) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatures()", "getAnalytes()")
  getAnalytes(x = x, n = n, rm.controls = rm.controls)
}

#' @noRd
meltExpressionSet <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::meltExpressionSet()", "pivotExpressionSet()")
}

#' @noRd
getSomamers <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamers()", "getAnalytes()")
}

#' @noRd
getSomamerData <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamerData()", "getAnalyteInfo()")
}
