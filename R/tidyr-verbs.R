
#' These are `tidyr` verb methods for `soma_adat` class
#' @noRd
NULL

#' @export
separate.soma_adat <- function(data, col, into, sep = "[^[:alnum:]]+",
                               remove = TRUE, convert = FALSE, extra = "warn",
                               fill = "warn", ...) {
  atts <- attributes(data)
  data <- rn2col(data, ".separate_rn")
  # must do it this way b/c NextMethod() doesn't play nice with lazyeval
  col2 <- tryCatch(eval(col), error = function(e) NULL) %||% deparse(substitute(col))
  stopifnot(
    "`col` must be a `character(1)` or a symbol." = is.character(col2),
    "`col` must have length = 1." = length(col2) == 1L,
    "`col` must be a variable name in `data`." = col2 %in% names(data)
  )
  data  <- data.frame(data)
  .data <- tidyr::separate(data, col2, into, sep, remove, convert, extra, fill, ...)
  col2rn(.data, ".separate_rn") |>
    addAttributes(atts) |>
    addClass("soma_adat")
}

#' @export
unite.soma_adat <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  atts  <- attributes(data)
  data  <- rn2col(data, ".unite_rn")
  data  <- data.frame(data)
  .data <- tidyr::unite(data, !!col, ..., sep = sep, remove = remove, na.rm = na.rm)
  col2rn(.data, ".unite_rn") |>
    addAttributes(atts) |>
    addClass("soma_adat")
}
