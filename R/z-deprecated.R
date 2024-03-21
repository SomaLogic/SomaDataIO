#' Deprecated function(s) of the \pkg{SomaDataIO} package
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' `r lifecycle::badge("deprecated")`
#'
#' `r lifecycle::badge("soft-deprecated")`
#'
#' These functions are provided for compatibility with
#' older versions of the \pkg{SomaDataIO} package.
#' They may eventually be completely removed, so
#' please re-code your scripts accordingly based on the
#' suggestions below:
#'
#' \tabular{lcr}{
#'   `meltExpressionSet()` \tab now use \tab [pivotExpressionSet()] \cr
#'   `getSomamers()`       \tab now use \tab [getAnalytes()] \cr
#'   `getFeatures()`       \tab now use \tab [getAnalytes()] \cr
#'   `getSomamerData()`    \tab now use \tab [getAnalyteInfo()] \cr
#'   `getFeatureData()`    \tab now use \tab [getAnalyteInfo()]
#' }
#'
#' @rdname SomaDataIO-deprecated
#' @name SomaDataIO-deprecated
#' @author Stu Field
#' @param ... A pass-through to allow the function to
#'   trigger the `lifecycle` message.
#' @aliases meltExpressionSet getSomamers getSomamerData
#' @importFrom lifecycle deprecate_warn deprecate_stop
NULL



#' @describeIn getAnalyteInfo
#'   `r lifecycle::badge("superseded")`. Please adjust your code accordingly.
#' @export
getFeatureData <- function(adat) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatureData()", "getAnalyteInfo()")
  getAnalyteInfo(adat)
}

#' @describeIn getAnalytes
#'   `r lifecycle::badge("superseded")`. Please adjust your code accordingly.
#' @export
getFeatures <- function(x, n = FALSE, rm.controls = FALSE) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatures()", "getAnalytes()")
  getAnalytes(x = x, n = n, rm.controls = rm.controls)
}

#' @noRd
#' @export
meltExpressionSet <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::meltExpressionSet()", "pivotExpressionSet()")
}

#' @noRd
#' @export
getSomamers <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamers()", "getAnalytes()")
}

#' @noRd
#' @export
getSomamerData <- function(...) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamerData()", "getAnalyteInfo()")
}
