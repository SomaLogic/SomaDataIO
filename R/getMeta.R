#' Get Meta Data Field Names
#'
#' Return a character vector of field names of the meta data
#' for an ADAT, or `soma.data` object.
#'
#' @param x A `soma_adat` object created using [read_adat()].
#' Alternatively, can be a `matrix` class object with column names
#' corresponding to feature names, or a character vector of features.
#' @param n Logical. Return the number of meta data field names rather
#' than a vector string of meta data fields?
#' @return A character vector of adat meta data names or,
#' an integer number, the length of the meta data names.
#' @author Stu Field
#' @examples
#' meta.vec <- getMeta(sample.adat)
#' head(meta.vec, 20)
#' getMeta(sample.adat, n = TRUE)
#'
#' # test data.frame and character S3 methods
#' identical(getMeta(sample.adat), getMeta(names(sample.adat))) # TRUE
#' @importFrom usethis ui_stop
#' @export
getMeta <- function(x, n = FALSE) UseMethod("getMeta")

#' S3 getMeta default method
#' @noRd
#' @export
getMeta.default <- function(x, ...) {
  usethis::ui_stop(
    "Couldn't find a S3 method for this object: {class(x)}."
  )
}

#' S3 getMeta method for data.frame
#' @noRd
#' @export
getMeta.data.frame <- function(x, ...) {
  names(x) %>% getMeta(...)
}

#' S3 getMeta method for soma_adat
#' @noRd
#' @export
getMeta.soma_adat <- getMeta.data.frame

#' S3 getMeta method for list
#' @noRd
#' @export
getMeta.list <- getMeta.data.frame

#' S3 getMeta method for character
#' @noRd
#' @export
getMeta.character <- function(x, n = FALSE) {
  y <- setdiff(x, get_features(x))
  if (n) length(y) else y
}

#' S3 getMeta method for matrix
#' @noRd
#' @export
getMeta.matrix <- function(x, ...) {
  colnames(x) %>% getMeta(...)
}

