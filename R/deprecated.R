#' Deprecated function(s) of the `SomaDataIO` package
#'
#' These functions are provided for compatibility with
#' older versions of the `SomaDataIO` package.
#' They may eventually be completely removed, so
#' please re-code your scripts accordingly as soon as possible.
#'
#' \tabular{rl}{
#'   `meltExpressionSet()` \tab now use [pivotExpressionSet()] \cr
#'   `getSomamers()`       \tab now use [getFeatures()] \cr
#'   `getSomamerData()`    \tab now use [getFeatureData()]
#' }
#'
#' @rdname SomaDataIO-deprecated
#' @name SomaDataIO-deprecated
#' @docType package
#' @author Stu Field
#' @param ... A simple pass-through to a replacement alternative if available.
#' @aliases meltExpressionSet getSomamers getSomamerData
#' @export meltExpressionSet getSomamers getSomamerData
#' @importFrom lifecycle deprecate_stop deprecate_warn
NULL

#' @noRd
meltExpressionSet <- function(...) {
  deprecate_warn("5.0.0", "SomaDataIO::meltExpressionSet()",
                 "pivotExpressionSet()")
  pivotExpressionSet(...)
}

#' @noRd
getSomamers <- function(...) {
  deprecate_warn("5.0.0", "SomaDataIO::getSomamers()",
                 "getFeatures()")
  getFeatures(...)
}

#' @noRd
getSomamerData <- function(...) {
  deprecate_warn("5.0.0", "SomaDataIO::getSomamerData()",
                 "getFeatureData()")
  getFeatureData(...)
}
