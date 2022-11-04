# --------------------------- #
# Declaring Global Variables:
# This is mostly for passing R CMD checks
# global variables that come from other dependant
# packages, or objects in the 'data/' directory
# Reference: https://github.com/tidyverse/magrittr/issues/29
# ---------------------------------------------------------- #
if ( getRversion() >= "2.15.1" )
utils::globalVariables(
  c(".",
    "AptName",
    "array_id",
    "blank_col",
    "Dilution",
    "feature",
    "prefix",
    "rn",
    "SeqId",
    "seqid",
    "value"
  )
)
