##################################
# Declaring Global Variables:
# This is mostly for passing R CMD checks
# global variables that come from other dependant
# packages, or objects in the data/ directory
# Reference: https://github.com/tidyverse/magrittr/issues/29
##################################
utils::globalVariables(
  c(".", "rn",
    "array_id",
    "feature",
    "value",
    "Dilution",
    "SeqId",
    "seqid",
    "prefix",
    "AptName",
    "blank_col"
  )
)
