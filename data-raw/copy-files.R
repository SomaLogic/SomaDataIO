#' -------------------------------
#' utility for copying over internal
#' `somaverse` files for use in
#' `SomaDataIO`
#' -------------------------------
library(here)
root <- path.expand("~/bitbucket/SomaReadr")
files <- c(
  "diffAdats.R",
  "dplyr-reexports.R",
  "dplyr-verbs.R",
  "extract.R",
  #"revertAptNames.R",
  #"convertAptNames.R",
  "is-seqFormat.R",
  "is-intact-attributes.R",
  "getAnalytes.R",
  "getAnalyteInfo.R",
  "getMeta.R",
  "matchSeqIds.R",
  "MathGenerics.R",
  "parseHeader.R",
  "prepHeaderMeta.R",
  "read-adat.R",
  "rownames.R",
  "SeqId.R",
  "s3-print-soma-adat.R",
  "s3-summary-soma-adat.R",
  "tidyr-reexports.R",
  "tidyr-verbs.R",
  "utils-read-adat.R",
  "write-adat.R"
)
paths <- file.path(root, "R", files)
file.copy(paths, here("R"), overwrite = TRUE)
