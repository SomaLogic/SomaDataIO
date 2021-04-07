#' Working with SomaLogic SeqIds
#'
#' The `SeqId`, e.g. `1234-56`, is the cornerstone used to uniquely identify
#' SomaLogic analytes. The tools below enable users to extract, test,
#' identify, and manipulate `SeqIds`.
#'
#' @name SeqId
#' @param x Character. A vector of strings, usually analyte/feature column
#' names, `AptNames`, or `SeqIds`. For [seqid2apt()], a vector of `SeqIds`.
#' For [matchSeqIds()], a vector of pattern matches containing `SeqIds`. Can be
#' `AptNames` with `GeneIDs` or `seq.XXXX` format, or even naked `SeqIds`.
NULL



#' Extract the `SeqId` String
#'
#' @describeIn SeqId
#' Extracts the the `SeqId` portion (`SeqId-Clone_Version`) from an
#' analyte column identifier, i.e. column name of an ADAT loaded
#' with [read_adat()].
#'
#' @param trim.version Logical. Whether to remove the version number,
#' i.e. "1234-56" vs "1234-56_7". This is primarily for legacy ADATs
#' where version numbers were common. Newer `SeqId` format does not
#' contain version numbers.
#' @return [getSeqId()]: a character vector of only the `SeqId` portion
#' of a string.
#' @author Stu Field
#' @seealso [str_locate()]
#' @examples
#' x <- c("ABDC.3948.48.2", "3948.88",
#'        "3948.48.2", "3948-48_2", "3948.48.2",
#'        "3948-48_2", "3948-88",
#'        "My.Favorite.Apt.3948.88.9")
#'
#' tibble::tibble(orig       = x,
#'                SeqId      = getSeqId(x),
#'                SeqId_trim = getSeqId(x, TRUE),
#'                AptName    = seqid2apt(SeqId_trim))
#'
#' @importFrom stringr str_trim str_sub str_locate
#' @importFrom stringr str_replace str_remove str_split
#' @importFrom purrr pmap_chr
#' @export
getSeqId <- function(x, trim.version = FALSE) {
  x         <- stringr::str_trim(x)   # zap trailing/leading whitespace
  match_mat <- stringr::str_locate(x, regexSeqId())
  args <- list(string = x,
               start  = match_mat[, "start"],
               end    = match_mat[, "end"])
  seqId <- purrr::pmap_chr(args, stringr::str_sub) %>%
    stringr::str_replace("\\.", "-") %>%
    stringr::str_replace("\\.", "_")

  if ( trim.version ) {
    stringr::str_split(seqId, "_") %>% purrr::map_chr(1L)
  } else {
    seqId
  }
}


#' @describeIn SeqId
#' Converts a `SeqId` format into anonymous-AptName format, i.e.
#' `1234-56` -> `seq.1234.56`.
#' @importFrom usethis ui_warn ui_value
#' @export
seqid2apt <- function(x) {
  stopifnot(inherits(x, "character"))
  if ( !all(is.SeqId(x)) ) {
    usethis::ui_stop(
      "As least some values are not in 'SeqId' format.
      Try running `getSeqId()` for: {ui_value(x[!is.SeqId(x)])}"
    )
  }
  paste0("seq.", sub("-", ".", x))
}



#' Does a string contain a `SeqId`?
#'
#' @describeIn SeqId
#' Regular expression match to determine if a string *contains*
#' a `SeqId`, and thus is probably an `AptName` format string. Both
#' legacy `EntrezGeneSymbol-SeqId` combinations or newer
#' `"anonymous-AptNames"` formats (`seq.1234.45`) are matched.
#'
#' @return [is.apt()], [is.SeqId()]: Logical. `TRUE` or `FALSE`.
#' @examples
#' # Logical Matching
#' is.apt("AGR2.4959.2") # TRUE
#' is.apt("seq.4959.2")  # TRUE
#' is.apt("4959-2")      # TRUE
#' is.apt("AGR2")        # FALSE
#'
#' @importFrom stringr str_detect
#' @export
is.apt <- function(x) {
  stringr::str_detect(x, regexSeqId())
}


#' @describeIn SeqId
#' Tests for `SeqId` format. Values returned from [getSeqId()]
#' evaluate to `TRUE`.
#' @export
is.SeqId <- function(x) {
  stringr::str_detect(x, "^[0-9]{4,5}-[0-9]{1,3}(_[0-9]{1,3})?$")
}



#' Regular expression match for `SeqIds`
#'
#' @describeIn SeqId
#' Generates a pre-formatted regular expression for
#' matching of `SeqIds`. Used internally in *many* utility functions
#' @export
regexSeqId <- function() {
  #   SeqId ------ Clone ------ Version (optional)
  "[0-9]{4,5}[-.][0-9]{1,3}([._][0-9]{1,3})?$"
}

# nolint start
# An equivalent using the `rex` pkg
# .regexSeqId <- function() {
#   rex::rex(
#     between(digit, 4, 5),        # SeqId; 4-5 numeric digits
#     "-" %or% dot,                # either "-" or "."
#     between(digit, 1, 3),        # Clone;  1-3 numeric digits

#       "_" %or% dot,              # either "_" or "."
#       between(digit, 1, 3)       # optional Version; 1-3 numeric digits
#     ),
#     end
#     )
# }
# nolint end
