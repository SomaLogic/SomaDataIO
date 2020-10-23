#' Get Features
#'
#' Return the feature names (i.e. the column names for the feature data)
#' from a `soma_adat`, data frame, matrix, list, or character
#' vector. S3 methods exist for these classes.
#'
#' @param x Usually a `soma_adat` class object created using [read_adat()].
#' @param n Logical. Return an integer corresponding to the *length*
#' of the returned string?
#' @param rm.controls Logical. Should all control and non-human analytes
#' (e.g. `HybControls`, `Non-Human`, `Non-Biotin`, `Spuriomer`) be removed
#' from the returned value?
#' @return A character vector of ADAT feature ("analyte") names
#' or an integer number corresponding to the length of the
#' feature names (if `n = TRUE`).
#' @author Stu Field
#' @seealso [regex()], [grep()]
#' @examples
#' apts <- getFeatures(example_data)
#' head(apts)
#'
#' getFeatures(example_data, TRUE)
#' getFeatures(example_data, n = TRUE)
#' bb <- getFeatures(names(example_data))
#' identical(apts, bb)
#'
#' # Control Analytes
#' crtl <- setdiff(apts, getFeatures(example_data, rm.controls = TRUE))
#'
#' getFeatureData(example_data) %>% filter(AptName %in% crtl)
#' @export getFeatures
getFeatures <- function(x, n = FALSE, rm.controls = FALSE) {
  getAptamers(x, n, rm.controls)
}
