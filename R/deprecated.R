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
#' @param ... A simple pass-through to the replacement function.
#' @aliases meltExpressionSet getSomamers getSomamerData
#' @export meltExpressionSet getSomamers getSomamerData
NULL


#' @noRd
meltExpressionSet <- function(...) {
  .Deprecated("pivotExpressionSet", package = "SomaDataIO")
  pivotExpressionSet(...)
}

#' @noRd
getSomamers <- function(...) {
  .Deprecated("getFeatures", package = "SomaDataIO")
  getFeatures(...)
}

#' @noRd
getSomamerData <- function(...) {
  .Deprecated("getFeatureData", package = "SomaDataIO")
  getFeatureData(...)
}
