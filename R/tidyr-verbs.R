#' These are `tidyr` verb methods for `soma_adat` class
#' @noRd
NULL

#' @importFrom tidyselect vars_pull
#' @importFrom rlang enquo
#' @export
separate.soma_adat <- function(data, col, into, sep = "[^[:alnum:]]+",
                               remove = TRUE,  convert = FALSE, extra = "warn",
                               fill = "warn", ...) {
  atts <- attributes(data)
  data <- rn2col(data, ".separate_rn")
  col  <- tidyselect::vars_pull(names(data), !!rlang::enquo(col))
  # must do it this way b/c NextMethod() doesn't play nice with tidyeval
  data  <- data.frame(data)
  .data <- tidyr::separate(data, col, into, sep, remove, convert, extra, fill, ...)
  .data <- col2rn(.data, ".separate_rn")
  addAttributes(.data, atts) %>% addClass("soma_adat")
}

#' @export
unite.soma_adat <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  atts  <- attributes(data)
  data  <- rn2col(data, ".unite_rn")
  data  <- data.frame(data)
  .data <- tidyr::unite(data, !!col, ..., sep = sep, remove = remove, na.rm = na.rm)
  .data <- col2rn(.data, ".unite_rn")
  addAttributes(.data, atts) %>% addClass("soma_adat")
}
