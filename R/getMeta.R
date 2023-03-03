#' Get Meta
#'
#' [getMeta()] returns the inverse, a character vector of string
#' names of *non*-analyte feature columns/variables, which typically
#' correspond to the clinical ("meta") data variables.
#' S3 methods exist for these classes:
#' ```{r method-classes2, echo = FALSE}
#' options(width = 80)
#' methods("getMeta")
#' ```
#'
#' @rdname getAnalytes
#' @return [getMeta()]: a character vector of ADAT clinical ("meta") data names.
#' @return For both, if `n = TRUE`, an integer corresponding to the
#'   __length__ of the character vector.
#' @examples
#'
#' # clinical variables
#' mvec <- getMeta(example_data)
#' head(mvec, 10)
#' getMeta(example_data, n = TRUE)
#'
#' # test 'data.frame' and 'character' S3 methods are identical
#' identical(getMeta(example_data), getMeta(names(example_data))) # TRUE
#' @export
getMeta <- function(x, n = FALSE) UseMethod("getMeta")

#' @noRd
#' @export
getMeta.default <- function(x, n) {
  stop(
    "Couldn't find a S3 method for this class object: ", .value(class(x)),
    call. = FALSE
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

#' @noRd
#' @export
getMeta.matrix <- function(x, n = FALSE) {
  getMeta(colnames(x), n = n)
}

#' @noRd
#' @export
getMeta.character <- function(x, n = FALSE) {
  lgl <- !is.apt(x)
  if ( n ) {
    sum(lgl)
  } else {
    x[lgl]
  }
}
