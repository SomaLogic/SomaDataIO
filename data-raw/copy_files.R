#' -------------------------------
#' utility for copying over internal
#' `somaverse` files for use in
#' `SomaDataIO`
#' -------------------------------
library(here)
root <- fs::path_expand(fs::path("~/bitbucket/SomaReadr"))
files <- c(
  "diffAdats.R",
  "dplyr-verbs.R",
  "dplyr-reexports.R",
  "extract.R",
  #"revertAptNames.R",
  #"convertAptNames.R",
  "is-seqFormat.R",
  "is-intact-attributes.R",
  "getAnalytes.R",
  "getMeta.R",
  "MathGenerics.R",
  "parseHeader.R",
  "prepHeaderMeta.R",
  "read-adat.R",
  "SeqId.R",
  "tidyr-verbs.R",
  "tidyr-reexports.R",
  "rownames.R",
  "utils-read-adat.R",
  "s3-print-soma-adat.R",
  "s3-summary-soma-adat.R",
  "write-adat.R"
)
paths <- fs::path(root, "R", files)
fs::file_copy(paths, here("R"), overwrite = TRUE)
