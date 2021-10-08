#' Are Attributes Intact?
#'
#' This function runs a series of checks to determine
#' if a `"soma_adat"` object has a complete
#' set of attributes. If not, this indicates that the object has
#' been modified since the initial [read_adat()] call.
#' Checks for the presence of both "Header.Meta" and "Col.Meta" in the
#' attribute names. These entries are added during the
#' [read_adat()] call. Specifically, within these sections
#' it also checks for the presence of the following entries:
#' \describe{
#'   \item{"Header.Meta" section:}{"HEADER", "COL_DATA", and "ROW_DATA"}
#'   \item{"Col.Meta" section:}{"SeqId", "Target", "Units", and "Dilution"}
#' }
#' If any of the above they are altered or missing, `FALSE` is returned.
#'
#' @inheritParams read_adat
#' @param adat A `soma_adat` object to query.
#' @return Logical. `TRUE` if all checks pass, otherwise `FALSE`.
#' @seealso [attributes()]
#' @examples
#' # checking attributes
#' my_adat <- example_data
#' is.intact.attributes(my_adat)           # TRUE
#' is.intact.attributes(my_adat[, -303])   # doesn't break atts; TRUE
#' attributes(my_adat)$Col.Meta$Target <- NULL    # break attributes
#' is.intact.attributes(my_adat, verbose = TRUE)  # FALSE (Target missing)
#' @export
is.intact.attributes <- function(adat, verbose = interactive()) {

  atts <- attributes(adat)
  col_meta_checks <- c("SeqId", "Dilution", "Target", "Units")

  if ( !is.soma_adat(adat) ) {
    if ( verbose ) {
      .oops(
        "The object is not a `soma_adat` class object: {.value(class(adat))}"
      )
    }
    FALSE
  } else if ( length(atts) <= 3 ) {
    if ( verbose ) {
      .oops(
        "Attributes has only 3 entries: {.value(names(atts))}"
      )
    }
    FALSE
  } else if ( !all(c("Header.Meta", "Col.Meta") %in% names(atts)) ) {
    if ( verbose ) {
      .oops("Header.Meta and/or Col.Meta missing from attributes.")
    }
    FALSE
  } else if ( !all(c("HEADER", "COL_DATA", "ROW_DATA") %in% names(atts$Header.Meta)) ) {
    if ( verbose ) {
      diff <- setdiff(c("HEADER", "COL_DATA", "ROW_DATA"), names(atts$Header.Meta)) # nolint
      .oops("Header.Meta missing: {.value(diff)}")
    }
    FALSE
  } else if ( !all(col_meta_checks %in% names(atts$Col.Meta)) ) {
    if ( verbose ) {
      diff <- setdiff(col_meta_checks, names(atts$Col.Meta))
      .oops("Col.Meta is missing: {.value(diff)}")
    }
    FALSE
  } else if ( !inherits(atts$Col.Meta, "tbl_df") ) {
    if ( verbose ) {
      .oops(
        "Col.Meta is not a tibble! -> {.value(class(atts$Col.Meta))}"
      )
    }
    FALSE
  } else {
    TRUE  # Everything looks good!
  }
}
