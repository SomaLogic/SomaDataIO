#' Get Meta Data Field Names
#'
#' Return a character vector of field names of the meta data
#' for an ADAT, or `soma.data` object.
#'
#' @inheritParams getFeatures
#' @return A character vector of ADAT meta data names
#' or an integer number corresponding to the length of the
#' feature names (if `n = TRUE`).
#' @author Stu Field
#' @examples
#' meta.vec <- getMeta(example_data)
#' head(meta.vec, 20)
#' getMeta(example_data, n = TRUE)
#'
#' # test data.frame and character S3 methods
#' identical(getMeta(example_data), getMeta(names(example_data))) # TRUE
#' @importFrom usethis ui_stop
#' @export
getMeta <- function(x, n = FALSE) UseMethod("getMeta")

#' @noRd
#' @export
getMeta.default <- function(x, n) {
  usethis::ui_stop(
    "Couldn't find a S3 method for this object: {class(x)}."
  )
}

#' @noRd
#' @export
getMeta.data.frame <- function(x, n = FALSE) {
  getMeta(names(x), n = n)
}

#' @noRd
#' @export
getMeta.soma_adat <- getMeta.data.frame

#' @noRd
#' @export
getMeta.list <- getMeta.data.frame

#' S3 getMeta method for matrix
#' @noRd
#' @export
getMeta.matrix <- function(x, n = FALSE) {
  getMeta(colnames(x), n = n)
}

#' S3 getMeta method for character
#' @noRd
#' @export
getMeta.character <- function(x, n = FALSE) {
  lgl <- !is.seq(x)
  if ( n ) {
    sum(lgl)
  } else {
    x[lgl]
  }
}
