
#' These are `tidyr` verb methods for `soma_adat` class
#' @noRd
NULL

#' @export
separate.soma_adat <- function(data, col, into, sep = "[^[:alnum:]]+",
                               remove = TRUE, convert = FALSE, extra = "warn",
                               fill = "warn", ...) {
  atts <- attributes(data)
  data <- rn2col(data, ".separate_rn")
  # must do it this way b/c NextMethod() doesn't play nice with tidyeval
  col2 <- tryCatch(col, error = function(e) NULL) # NULL if 'col' is lazyeval
  if ( is.null(col2) ) col2 <- deparse(substitute(col))
  stopifnot(
    length(col2) == 1L,
    is.character(col2),
    col2 %in% names(data)
  )
  data  <- data.frame(data)
  .data <- tidyr::separate(data, col2, into, sep, remove, convert, extra, fill, ...)
  .data <- col2rn(.data, ".separate_rn")
  addAttributes(.data, atts) |> addClass("soma_adat")
}

#' @export
unite.soma_adat <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  atts  <- attributes(data)
  data  <- rn2col(data, ".unite_rn")
  data  <- data.frame(data)
  .data <- tidyr::unite(data, !!col, ..., sep = sep, remove = remove, na.rm = na.rm)
  .data <- col2rn(.data, ".unite_rn")
  addAttributes(.data, atts) |> addClass("soma_adat")
}
