#' Are Attributes Intact?
#'
#' `is.intact.attributes` uses a series of checks to determine
#' if a "soma_adat" object has a complete
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
#' @return For `is.intact.attributes`: `TRUE` if attributes are intact,
#' otherwise `FALSE`.
#' @seealso [attributes()]
#' @examples
#' # checking attributes
#' my_adat <- example_data
#' is.intact.attributes(my_adat)           # TRUE
#' is.intact.attributes(my_adat[, -303])   # doesn't break atts; TRUE
#' attributes(my_adat)$Col.Meta <- NULL    # break attributes
#' is.intact.attributes(my_adat, verbose = TRUE) # FALSE
#' @importFrom usethis ui_oops
#' @export is.intact.attributes
is.intact.attributes <- function(adat, verbose = getOption("verbose")) {

  atts <- attributes(adat)
  col_meta_checks <- c("SeqId", "Dilution", "Target", "Units")

  if ( length(atts) <= 3 ) {
    if ( verbose ) {
      usethis::ui_oops(
        "Attributes has only 3 entries: {paste(names(atts), collapse = ', ')}"
      )
    }
    return(FALSE)
  } else if ( !all(c("Header.Meta", "Col.Meta") %in% names(atts)) ) {
    if ( verbose ) {
      usethis::ui_oops("Header.Meta and/or Col.Meta missing from attributes.")
    }
    return(FALSE)
  } else if ( !all(c("HEADER", "COL_DATA", "ROW_DATA") %in% names(atts$Header.Meta)) ) {
    if ( verbose ) {
      diff <- setdiff(c("HEADER", "COL_DATA", "ROW_DATA"), names(atts$Header.Meta))
      usethis::ui_oops("Header.Meta missing: {paste(diff, collapse = ', ')}")
    }
    return(FALSE)
  } else if ( !all(col_meta_checks %in% names(atts$Col.Meta)) ) {
    if ( verbose ) {
      diff <- setdiff(col_meta_checks, names(atts$Co.Meta))
      usethis::ui_oops("Col.Meta is missing: {paste(diff, collapse = ', ')}")
    }
    return(FALSE)
  } else if ( !inherits(atts$Col.Meta, "tbl_df") ) {
    if ( verbose ) {
      usethis::ui_oops(
        "Col.Meta is not a tibble! -> {class(atts$Col.Meta)}"
      )
    }
    return(FALSE)
  } else {
    return(TRUE)  # Everything looks good!
  }
}
