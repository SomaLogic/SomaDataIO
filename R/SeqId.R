#' Working with SomaLogic SeqIds
#'
#' The `SeqId` is the cornerstone used to uniquely identify
#' SomaLogic analytes.
#' `SeqIds` follow the format **`<Pool>-<Clone>_<Version>`**, for example
#' `"1234-56_7"` can be represented as:
#' \tabular{ccc}{
#'   **Pool** \tab **Clone** \tab **Version** \cr
#'   `1234`   \tab `56`      \tab `7`
#' }
#' See **Details** below for the definition of each sub-unit.
#' The **`<Pool>-<Clone>`** combination is sufficient to uniquely identify a
#' specific analyte and therefore versions are no longer in provided (though
#' they may be present in legacy ADATs).
#' The tools below enable users to extract, test, identify, compare,
#' and manipulate `SeqIds` across assay runs and/or versions.
#'
#' \tabular{ll}{
#'   **Pool:**    \tab ties back to the original well during **SELEX** \cr
#'   **Clone:**   \tab ties to the specific sequence within a pool \cr
#'   **Version:** \tab refers to custom modifications (optional/defunct)
#' }
#'
#' @name SeqId
#' @param x Character. A vector of strings, usually analyte/feature column
#' names, `AptNames`, or `SeqIds`. For [seqid2apt()], a vector of `SeqIds`.
#' For [matchSeqIds()], a vector of pattern matches containing `SeqIds`.
#' Can be `AptNames` with `GeneIDs` or `seq.XXXX` format, or even
#' "naked" `SeqIds`.
NULL



#' Extract the `SeqId` String
#'
#' @describeIn SeqId
#' Extracts/captures the the `SeqId` match from an analyte column identifier,
#' i.e. column name of an ADAT loaded with [read_adat()]. Assumes the
#' `SeqId` pattern occurs at the end of the string, which for
#' the vast majority of cases will be true. For edge cases, see the
#' `trailing` argument to [locateSeqId()].
#'
#' @param trim.version Logical. Whether to remove the version number,
#' i.e. "1234-56_7" -> "1234-56". Primarily for legacy ADATs.
#' @return [getSeqId()]: a character vector of `SeqId` capture from a string.
#' @author Stu Field
#' @examples
#' x <- c("ABDC.3948.48.2", "3948.88",
#'        "3948.48.2", "3948-48_2", "3948.48.2",
#'        "3948-48_2", "3948-88",
#'        "My.Favorite.Apt.3948.88.9")
#'
#' tibble::tibble(orig       = x,
#'                SeqId      = getSeqId(x),
#'                SeqId_trim = getSeqId(x, TRUE),
#'                AptName    = seqid2apt(SeqId))
#'
#' @export
getSeqId <- function(x, trim.version = FALSE) {
  # factor --> character; list --> character
  # zap trailing/leading whitespace
  df    <- locateSeqId(trimws(x))
  seqId <- substr(df$x, df$start, df$stop)
  seqId <- sub("\\.", "-", seqId) # 1st '.' -> '-'
  seqId <- sub("\\.", "_", seqId) # 2nd '.' -> '_' if present

  if ( trim.version ) {
    vapply(strsplit(seqId, "_", fixed = TRUE), `[[`, i = 1L, character(1))
  } else {
    seqId
  }
}


#' Regular expression match for `SeqIds`
#'
#' @describeIn SeqId
#' Generates a pre-formatted regular expression for
#' matching of `SeqIds`. Note the *trailing* match, which is most
#' commonly required, but [locateSeqId()] offers
#' an alternative to mach *anywhere* in a string.
#' Used internally in *many* utility functions
#' @return [regexSeqId()]: a regular expression (`regex`) string
#' pre-defined to match SomaLogic the `SeqId` pattern.
#' @export
regexSeqId <- function() {
  #  Pool ------- Clone ------- Version (optional)
  "[0-9]{4,5}[-.][0-9]{1,3}([._][0-9]{1,3})?$"
}


#' Locate string positions of `SeqIds`
#'
#' @describeIn SeqId
#' Generates a data frame of the positional `SeqId` matches. Specifically
#' designed to facilitate `SeqId` extraction via [substr()].
#' Similar to [stringr::str_locate()].
#' @param trailing Logical. Should the regular expression explicitly specify
#' *trailing* `SeqId` pattern match, i.e. `"regex$"`?
#' This is the most common case and the default.
#' @return [locateSeqId()]: a data frame containing the `start` and `stop`
#' integer positions for `SeqId` matches at each value of `x`.
#' @export
locateSeqId <- function(x, trailing = TRUE) {
  pattern <- regexSeqId()
  if ( !trailing ) {
    pattern <- strtrim(pattern, nchar(pattern) - 1)   # trim `"$"`
  }
  regex <- regexpr(pattern, x)
  start <- as.integer(regex)
  start[start < 0] <- NA_integer_
  stop  <- start + (regex %@@% "match.length") - 1L
  data.frame(x = x, start = start, stop = stop, stringsAsFactors = FALSE)
}


#' @describeIn SeqId
#' Converts a `SeqId` into anonymous-AptName format, i.e.
#' `1234-56` -> `seq.1234.56`. Versions, i.e. `1234-56_ver`, are trimmed.
#' @export
seqid2apt <- function(x) {
  stopifnot(inherits(x, "character"))
  if ( !all(is.SeqId(x)) ) {
    stop(
      "As least some values are not in 'SeqId' format.\n",
      "Try running `getSeqId()` for: ", .value(x[!is.SeqId(x)]),
      call. = FALSE
    )
  }
  # strip versions if present
  x <- vapply(strsplit(x, "_", fixed = TRUE), `[[`, i = 1L, character(1))
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
#' @export
is.apt <- function(x) {
  # ensures pattern ends with SeqId
  grepl(regexSeqId(), x)
}


#' @describeIn SeqId
#' Tests for `SeqId` format. Values returned from [getSeqId()]
#' evaluate to `TRUE`.
#' @export
is.SeqId <- function(x) {
  grepl("^[0-9]{4,5}-[0-9]{1,3}(_[0-9]{1,3})?$", x)
}
