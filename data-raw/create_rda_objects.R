#' ------------------------------------
#' Generate `SomaDataIO` objects
#' Run:
#'   source("create_rda_objects.R")
#' ------------------------------------
library(here)
example_data     <- read_adat(here("inst/example", "example_data.adat"))
ex_features      <- getFeatures(example_data)
ex_feature_table <- getFeatureData(example_data)
ex_target_names  <- as.list(ex_feature_table$TargetFullName)
names(ex_target_names) <- ex_feature_table$AptName
save(example_data, file = here("data/example_data.rda"), compress = "xz")
save(ex_features, ex_feature_table, ex_target_names,
     file = here("data/data_objects.rda"), compress = "xz")
