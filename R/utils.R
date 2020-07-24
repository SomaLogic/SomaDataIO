
# Internal objects for
# Standard SeqIds for Control Analytes
seq_HybControlElution <- c("2171-12", "2178-55", "2194-91",
                           "2229-54", "2249-25", "2273-34",
                           "2288-7", "2305-52", "2312-13",
                           "2359-65", "2430-52", "2513-7")
seq_Spuriomer <- c("2052-1", "2053-2", "2054-3", "2055-4",
                   "2056-5", "2057-6", "2058-7", "2060-9",
                   "2061-10", "4666-193", "4666-194", "4666-195",
                   "4666-199", "4666-200", "4666-202", "4666-205",
                   "4666-206", "4666-212", "4666-213", "4666-214")
seq_NonBiotin <- c("3525-1", "3525-2", "3525-3", "3525-4", "4666-218",
                   "4666-219", "4666-220", "4666-222", "4666-223", "4666-224")
seq_NonHuman <- c("16535-61", "3507-1", "3512-72", "3650-8", "3717-23",
                  "3721-5", "3724-64", "3742-78", "3849-56", "4584-5",
                  "8443-9", "8444-3", "8444-46", "8445-184", "8445-54",
                  "8449-103", "8449-124", "8471-53", "8481-26", "8481-44",
                  "8482-39", "8483-5")
seq_NonCleavable <- c("4666-225", "4666-230", "4666-232", "4666-236")

.getmeta <- getMeta
.getfeat <- getAptamers

#' trim leading/trailing empty strings
#' @importFrom magrittr extract2
#' @importFrom stringr str_trim str_c str_split
#' @noRd
trim_empty <- function(x, side) {
  stringr::str_c(x, collapse = "\t") %>%
    stringr::str_trim(side = side) %>%
    stringr::str_split("\t") %>%
    magrittr::extract2(1L)
}
