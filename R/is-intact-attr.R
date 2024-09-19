#' Are Attributes Intact?
#'
#' This function runs a series of checks to determine
#' if a `soma_adat` object has a complete
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
#' @param adat A `soma_adat` object to query.
#' @param verbose Logical. Should diagnostic information about failures
#'   be printed to the console? If the default, see [interactive()], is invoked,
#'   only messages via direct calls are triggered. This prohibits messages
#'   generated deep in the call stack from bubbling up to the user.
#' @return Logical. `TRUE` if all checks pass, otherwise `FALSE`.
#' @seealso [attributes()]
#' @examples
#' # checking attributes
#' my_adat <- example_data
#' is_intact_attr(my_adat)           # TRUE
#' is_intact_attr(my_adat[, -303L])   # doesn't break atts; TRUE
#' attributes(my_adat)$Col.Meta$Target <- NULL    # break attributes
#' is_intact_attr(my_adat)  # FALSE (Target missing)
#' @export
is_intact_attr <- function(adat, verbose = interactive()) {

  if ( missing(verbose) ) {
    # only enter branch if non-user defined
    direct <- sys.parent() < 1L
    verbose <- direct && verbose
  }
  atts <- attributes(adat)
  col_meta_checks <- c("SeqId", "Dilution", "Target", "Units")

  if ( !is.soma_adat(adat) ) {
    if ( verbose ) {
      .oops(
        "The object is not a `soma_adat` class object: {.val {class(adat)}}"
      )
    }
    FALSE
  } else if ( length(atts) <= 3L ) {
    if ( verbose ) {
      .oops(
        "Attributes has only 3 entries: {.val {names(atts)}}"
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
      diff <- setdiff(c("HEADER", "COL_DATA", "ROW_DATA"), names(atts$Header.Meta))
      .oops("Header.Meta is missing: {.val {diff}}")
    }
    FALSE
  } else if ( !all(col_meta_checks %in% names(atts$Col.Meta)) ) {
    if ( verbose ) {
      diff <- setdiff(col_meta_checks, names(atts$Col.Meta))
      .oops("Col.Meta is missing: {.val {diff}}")
    }
    FALSE
  } else if ( !inherits(atts$Col.Meta, "tbl_df") ) {
    if ( verbose ) {
      .oops(
        "Col.Meta is not a tibble! -> {.val {class(atts$Col.Meta)}}"
      )
    }
    FALSE
  } else {
    TRUE  # everything looks good!
  }
}

#' Alias to `is_intact_atttr`
#'
#' [is.intact.attributes()] is `r lifecycle::badge("superseded")`.
#' It remains for backward compatibility and may be removed in the future.
#' You are encouraged to shift your code to [is_intact_attr()].
#'
#' @rdname is_intact_attr
#' @importFrom lifecycle deprecate_soft
#' @export
is.intact.attributes <- function(adat, verbose = interactive()) {
  deprecate_soft("6.0.0", "SomaDataIO::is.intact.attributes()",
                 "SomaDataIO::is_intact_attr()")
  is_intact_attr(adat, verbose)
}
