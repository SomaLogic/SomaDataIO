#' Test `AptName` Format
#'
#' Test whether an object is in the new `seq.XXXX.XX` format.
#'
#' @param x The object to be tested.
#' @return A logical indicating whether `x` contains `AptNames` consistent
#' with the new format, beginning with a `seq.` prefix.
#' @examples
#' # character S3 method
#' is_seqFormat(names(example_data))   # no; meta data not ^seq.
#' is_seqFormat(tail(names(example_data), -20L))   # yes
#'
#' # soma_adat S3 method
#' is_seqFormat(example_data)
#' @author Stu Field, Eduardo Tabacman
#' @export
is_seqFormat <- function(x) UseMethod("is_seqFormat")

#' Default method
#' @noRd
#' @export
is_seqFormat.default <- function(x) {
  stop(
    "Couldn't find a S3 method for this class object: ", .value(class(x)),
    call. = FALSE
  )
}

#' S3 soma_adat method
#' @noRd
#' @export
is_seqFormat.soma_adat <- function(x) {
  is_seqFormat(getAnalytes(x))
}

#' S3 data.frame method
#' @noRd
#' @export
is_seqFormat.data.frame <- is_seqFormat.soma_adat

#' S3 character method
#' @noRd
#' @export
is_seqFormat.character <- function(x) {
  ifelse(length(x) == 0L, FALSE, all(grepl("^seq\\.", x)))
}
