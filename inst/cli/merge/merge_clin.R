# --------------------------
# Merge clinical variables into SomaScan data (ADAT)
#
# Command Line Interface (CLI) to merge/join clinical variables
# in a *.csv file format into SomaScan data as an existing *.adat file
# based on a common index key and write the resulting
# object to a new ADAT file (*.adat).
#
# The index key can be 1 of 2 forms:
#   1) a common index key to __both__ *.adat and *.csv
#   2) an expression of the form `key1=key2` indicating the index key
#      to use for the *.adat (`key1`) and *.csv (`key2`) respectively
#
# Copyright:
#   Copyright (c) 2023 SomaLogic Operating Co., Inc.
# Author:
#   Stu Field
#
# CLI Usage (4 args):
#   Rscript --vanilla merge_clin.R <adat_path.adat> <clin_path.csv> <key> <out_path.adat>
#
# Examples:
#   Rscript --vanilla merge_clin.R example_data10.adat meta.csv SampleId foo.adat
#   Rscript --vanilla merge_clin.R example_data10.adat meta2.csv SampleId=ClinKey foo.adat
#
# --------------------------
args <- commandArgs(trailingOnly = TRUE)
stopifnot("`merge_clin.R` should be called with *4* arguments." = length(args) == 4L)
path_x <- normalizePath(args[1L], mustWork = TRUE)
path_y <- normalizePath(args[2L], mustWork = TRUE)
x <- SomaDataIO::read_adat(path_x)
y <- utils::read.csv(path_y, header = TRUE)
stopifnot("`x` must be a `soma_adat`."  = SomaDataIO::is.soma_adat(x))
stopifnot("`y` must be a `data.frame`." = is.data.frame(y))
key <- args[3L]
if ( grepl("^\\S+=\\S+$", key) ) {
  spl <- strsplit(key, split = "=")[[1L]]
  key_x <- spl[1L]
  key_y <- spl[2L]
  if ( !key_y %in% names(y) ) {
    stop("Index key must be present in clinical data: ", key_y, call. = FALSE)
  }
} else {
  key_x <- key
  key_y <- key
}
if ( !identical(class(x[[key_x]]), class(y[[key_y]]))) {
  class(y[[key_y]]) <- class(x[[key_x]])   # coerce classes for join below
}
join_key <- setNames(key_y, key_x)
stopifnot("The `key` argument must be of character(1)." = length(join_key) == 1L)
adat <- dplyr::left_join(x, y, by = join_key)
SomaDataIO::write_adat(adat, file = args[4L])
