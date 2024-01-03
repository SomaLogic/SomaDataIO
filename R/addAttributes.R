#' Add Attributes to `soma_adat` Objects
#'
#' Adds a set of attributes, typically "Header.Meta" and "Col.Meta",
#' to a `data.frame`, `tibble`, `soma_adat` or similar tabular object.
#' Existing attributes `data` are _not_ over-written.
#' Typically untouched are:
#'   \itemize{
#'     \item `names`
#'     \item `class`
#'     \item `row.names`
#'   }
#'
#' @param data The _receiving_ `data.frame` object for new attributes.
#' @param new.atts A _named_ `list` object containing new attributes
#'   to add to the existing ones.
#' @return A data frame object corresponding to `data` but with the
#'   attributes of `new.atts` grafted on to it.
#'   Existing attribute names are _not_ over-written.
#' @author Stu Field
#' @seealso [attr()], [setdiff()]
#' @export
addAttributes <- function(data, new.atts) {
  stopifnot(
    "`data` must be a data frame, tibble, or similar." = inherits(data, "data.frame"),
    "`new.atts` must be a *named* list." = inherits(new.atts, "list"),
    "`new.atts` must be a *named* list." = !is.null(names(new.atts))
  )
  attrs <- setdiff(names(new.atts), names(attributes(data)))
  if ( length(attrs) > 0L ) {
    for ( i in attrs ) {
      attr(data, i) <- new.atts[[i]]
    }
  }
  data
}
