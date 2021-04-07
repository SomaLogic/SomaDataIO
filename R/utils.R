
#' trim leading/trailing empty strings
#' @importFrom magrittr extract2
#' @importFrom stringr str_trim str_c str_split
#' @noRd
trim_empty <- function(x, side) {
  stringr::str_c(x, collapse = "\t") %>%
    stringr::str_trim(side = side) %>%
    stringr::str_split("\t") %>%
    magrittr::extract2(1L)
}
