
getAptamers <- function(x, n, rm.controls) UseMethod("getAptamers")
getAptamers.default <- function(x, n, rm.controls) {
  usethis::ui_stop(
    "Couldn't find a S3 method for this class object: {class(x)}."
  )
}
getAptamers.data.frame <- function(x, n = FALSE, rm.controls = FALSE) {
  getAptamers(names(x), n = n, rm.controls = rm.controls)
}
getAptamers.soma_adat <- getAptamers.data.frame
getAptamers.list <- getAptamers.data.frame
getAptamers.matrix <- function(x, n = FALSE, rm.controls = FALSE) {
  getAptamers(colnames(x), n = n, rm.controls = rm.controls)
}
getAptamers.character <- function(x, n = FALSE, rm.controls = FALSE) {
  lgl <- is.seq(x)
  if ( rm.controls ) {
    lgl <- lgl & !x %in% .getControls()
  }
  if ( n ) {
    sum(lgl)
  } else {
    x[lgl]
  }
}
.getControls <- function() {
  paste0("seq.", c(seq_NonBiotin, seq_NonHuman, seq_Spuriomer, seq_HybControlElution)) %>%
    stringr::str_replace("-", ".")
}
