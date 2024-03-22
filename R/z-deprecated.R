#' Deprecated function(s) of the \pkg{SomaDataIO} package
#'
#' @description
#' These functions have either been
#' `r lifecycle::badge("superseded")` or
#' `r lifecycle::badge("deprecated")`
#' in the current version of \pkg{SomaDataIO} package.
#' They may eventually be completely removed, so
#' please re-code your scripts accordingly based on the
#' suggestions below:
#'
#' \tabular{lcr}{
#'   **Function**       \tab                                    \tab **Now Use** \cr
#'   [getSomamers()]    \tab `r lifecycle::badge("superseded")` \tab [getAnalytes()] \cr
#'   [getSomamerData()] \tab `r lifecycle::badge("superseded")` \tab [getAnalyteInfo()] \cr
#' }
#'
#' @details
#' Some badges you may see in \pkg{SomaDataIO}:
#'
#' `r lifecycle::badge("superseded")`
#'
#' `r lifecycle::badge("deprecated")`
#'
#' `r lifecycle::badge("soft-deprecated")`
#'
#' `r lifecycle::badge("stable")`
#'
#' @name SomaDataIO-deprecated
#' @aliases getSomamers getSomamerData
#' @importFrom lifecycle deprecate_warn deprecate_stop
NULL


#' @describeIn getAnalyteInfo
#'   `r lifecycle::badge("superseded")`. Please now use [getAnalyteInfo()].
#' @export
getFeatureData <- function(adat) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatureData()", "getAnalyteInfo()")
  getAnalyteInfo(adat)
}

#' @describeIn getAnalytes
#'   `r lifecycle::badge("superseded")`. Please now use [getAnalytes()].
#' @export
getFeatures <- function(x, n = FALSE, rm.controls = FALSE) {
  deprecate_warn("5.1.0", "SomaDataIO::getFeatures()", "getAnalytes()")
  getAnalytes(x = x, n = n, rm.controls = rm.controls)
}

#' @describeIn pivotExpressionSet
#'   `r lifecycle::badge("superseded")`. Please now use [pivotExpressionSet()].
#' @export
meltExpressionSet <- function(eSet) {
  deprecate_stop("5.0.0", "SomaDataIO::meltExpressionSet()", "pivotExpressionSet()")
}

#' @noRd
#' @export
getSomamers <- function(x) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamers()", "getAnalytes()")
}

#' @noRd
#' @export
getSomamerData <- function(x) {
  deprecate_stop("5.0.0", "SomaDataIO::getSomamerData()", "getAnalyteInfo()")
}
