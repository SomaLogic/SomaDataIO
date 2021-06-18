#' ------------------------------------
#' Generate `SomaDataIO` objects
#' run:
#'   source("create_rda_objects.R")
#' ------------------------------------
library(here)
example_data <- read_adat(here("inst/example", "example_data.adat"))
ex_analytes  <- getAnalytes(example_data)
ex_anno_tbl  <- getAnalyteInfo(example_data)
ex_target_names  <- as.list(ex_anno_tbl$TargetFullName)
names(ex_target_names) <- ex_anno_tbl$AptName
save(example_data, file = here("data/example_data.rda"), compress = "xz")
save(ex_analytes, ex_anno_tbl, ex_target_names,
     file = here("data/data_objects.rda"), compress = "xz")
