# --------------------------------------------------
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
#   Copyright (c) 2024 SomaLogic Operating Co., Inc.
# Author:
#   Stu Field
#
# CLI Usage (4 args):
#   Rscript --vanilla merge_clin.R <adat_path.adat> <clin_path.csv> <key> <out_path.adat>
#
# Examples:
#   Rscript --vanilla merge_clin.R example_data10.adat meta.csv SampleId foo.adat
#   Rscript --vanilla merge_clin.R example_data10.adat meta2.csv SampleId=ClinKey foo.adat
# --------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
stopifnot("`merge_clin.R` should be called with *4* arguments." = length(args) == 4L)
key <- args[3L]
if ( grepl("^\\S+=\\S+$", key) ) {
  key <- sub("=", "==", key)
}
key      <- str2lang(key)
join_key <- dplyr::join_by(!! key)
path_x   <- normalizePath(args[1L], mustWork = TRUE)
path_y   <- normalizePath(args[2L], mustWork = TRUE)
adat <- SomaDataIO::merge_clin(
  x         = SomaDataIO::read_adat(path_x),
  clin_data = path_y,
  by        = join_key,
  by_class  = setNames("character", join_key$y)
)
SomaDataIO::write_adat(adat, file = args[4L])
