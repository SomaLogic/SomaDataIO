#' Get Features
#'
#' Return the feature names (i.e. the column names for the
#' feature data) from a ADAT data frame, matrix, or character vector.
#'
#' @param adat An ADAT object created using [read_adat()].
#' Alternatively, can be a "matrix" object with column names
#' corresponding to feature names, or a character vector of features
#' @param rm.controls Logical. Should all control and
#' non-human features (e.g. "NonHuman", "NonBiotins",
#' "Spuriomers") be removed from the returned value?
#' @param n Logical. Return the number of features rather
#' than a vector string of features.
#' @return A character vector of ADAT feature ("analyte") names
#' or an integer number corresponding to the length of the
#' feature names (if `n = TRUE`).
#' @author Stu Field
#' @seealso [regex()], [grep()]
#' @examples
#' apts <- getFeatures(sample.adat)
#' head(apts)
#' getFeatures(sample.adat, TRUE)
#' getFeatures(sample.adat, n = TRUE)
#' bb <- getFeatures(names(sample.adat))
#' identical(apts, bb)
#' @export getFeatures
getFeatures <- function(adat, rm.controls = FALSE, n = FALSE) {
  getAptamers(adat, rm.controls, n)
}
