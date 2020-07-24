
getAptamers <- function(x, n = FALSE, rm.controls = FALSE) UseMethod("getAptamers")
getAptamers.default <- function(x, ...) {
  usethis::ui_stop(
    "Couldn't find a S3 method for this class object: {class(x)}."
  )
}
getAptamers.data.frame <- function(x, ...) {
  names(x) %>% getAptamers(...)
}
getAptamers.soma_adat <- getAptamers.data.frame
getAptamers.list <- getAptamers.data.frame
getAptamers.matrix <- function(x, ...) {
   getAptamers(colnames(x), ...)
}
#' @importFrom stringr str_subset
#' @noRd
getAptamers.character <- function(x, ...) {
  vec <- stringr::str_subset(x, regexSeqId())
  processOutput(vec, ...)
}
processOutput <- function(vec, rm.controls = FALSE, n = FALSE) {
  if ( rm.controls ) {
    vec %<>% stripControls()
  }
  if ( n ) {
    length(vec)
  } else {
    vec
  }
}
stripControls <- function(x) {
  crtls <- paste0("seq.", c(seq_NonBiotin, seq_NonHuman,
                            seq_Spuriomer, seq_HybControlElution)) %>%
    stringr::str_replace("-", ".")
  x[ !x %in% crtls ]
}

