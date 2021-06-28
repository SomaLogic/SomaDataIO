
#' trim leading/trailing empty strings
#' @importFrom stringr str_trim str_c str_split
#' @noRd
trim_empty <- function(x, side) {
  stringr::str_c(x, collapse = "\t") %>%
    stringr::str_trim(side = side) %>%
    stringr::str_split("\t") %>%
    magrittr::extract2(1L)
}

# kinder version of identical
`%equals%` <- function(x, y) {
  isTRUE(all.equal(x, y))
}
