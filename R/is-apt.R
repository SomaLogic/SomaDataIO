#' @importFrom stringr str_detect
#' @noRd
is.apt <- function(x) stringr::str_detect(x, regexSeqId())

#' Alias for [is.apt()]
#' @noRd
is.seq <- is.apt
