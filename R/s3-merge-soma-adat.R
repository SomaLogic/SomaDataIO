
#' @importFrom lifecycle deprecate_stop
#' @export
merge.soma_adat <- function(x, y, by = intersect(names(x), names(y)),
                            by.x = by, by.y = by, all = FALSE,
                            all.x = all, all.y = all, sort = TRUE,
                            suffixes = c(".x", ".y"), nu.dups = TRUE,
                            incomparables = NULL, ...) {
  # redirect to use `dplyr` alternatives
  call <- match.call()
  call[[1L]] <- str2lang("dplyr::left_join")
  deprecate_stop(
    "6.0.0", I("Using `merge()` on a `soma_adat`"),
    I("any of the `dplyr::*_join()` alternatives"),
    details = paste0("Perhaps ", .code(deparse(call)), "?")
  )
}
