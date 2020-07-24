#' Extract method for class `soma_adat`
#'
#' Redirect of the generic \code{`[`} extract function that keeps
#' the attributes intact *and* subsets the `Col.Meta` so that it
#' is consistent with the new object.
#' @rdname read_adat
#' @order 3
#' @inheritParams base::`[`
#' @export
`[.soma_adat` <- function(x, i, j, drop = TRUE) {

  if ( missing(j) ) {
    # not sub-setting columns
    return(NextMethod())
  } else if ( is.intact.attributes(x) ) {
    # sub-setting columns & attributes to worry about
    if ( length(j) == 1 && j > 0 ) {
      # if extracting a single column
      # this behavior may change one day to match `tibbles`
      # where you output is what you input, i.e. `drop = FALSE` by default
      return(NextMethod(drop = drop))
    } else {
      atts <- attributes(x)
    }
  } else {
    # if attributes already broken
    return(NextMethod())
  }

  apts <- get_features(names(x))

  if ( is.character(j) ) {
    k <- match(j[j %in% apts], apts)              # Character case
  } else if ( is.numeric(j) | is.logical(j) ) {
                                                  # Integer/Logical case
    # this is tricky
    # must figure out which numeric indices are feature data; which meta data
    k <- get_features(names(x)[j]) %>%
      match(., apts)
  }

  # Update the attributes -> Col.Meta information
  atts$Col.Meta <- atts$Col.Meta[k, ] # assume apts same order as Col.Meta (should be ok)
  .data <- addAttributes(NextMethod(), atts)
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  .data
}

#'  [`[`] assignment for class `soma_adat`.
#' @noRd
#' @export
`[<-.soma_adat` <- function(x, i, j, ..., value) {
  anames <- names(attributes(x))
  .data  <- NextMethod()
  attributes(.data) <- attributes(.data)[anames]   # re-order back to original
  .data
}

#' Partial matching is not allowed for class `soma_adat`.
#' @noRd
#' @importFrom usethis ui_warn
#' @export
`$.soma_adat` <- function(x, name) {
  if ( is.character(name) ) {
    ret <- .subset2(x, name)
    if ( is.null(ret) ) {
      usethis::ui_warn("Unknown or uninitialised column: '{name}'")
    }
    return(ret)
  }
  .subset2(x, name)
}


#' We want to restrict the usage of `[[` for `soma_adat`. Use only a
#' numeric index (e.g. `1L`) or a character identifying the column
#' (e.g. `SampleGroup`). Partial matching is not allowed.
#' @noRd
#' @param i Numeric index or Character for the column desired.
#' @param exact Ignored with a warning.
#' @param j Error. Do not use i,j syntax for `[[`, use `[` instead.
#' @importFrom usethis ui_stop ui_warn
#' @export
`[[.soma_adat` <- function(x, i, j, ..., exact = TRUE) {
  if ( !exact ) {
    usethis::ui_warn("`exact=` is ignored in `[[`.")
  }
  if ( !missing(j) ) {
    usethis::ui_stop(
      "Passing jth column index not supported via `[[` for `soma_adat`. \\
      Please use x[{i}, {j}] instead."
    )
  }
  return(`$.soma_adat`(x, i))
}
