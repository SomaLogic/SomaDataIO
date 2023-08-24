#' Create Annotations Table
#'
#' Uses the column meta data (Col.Meta; feature data that appears above
#' the protein measurements in the adat file)
#' and compiles them into a grouped tibble lookup table
#' for simple manipulation and indexing.
#'
#' @param x The "Col.Meta" element from an adat attributes.
#' @return A `tibble` object with columns corresponding
#'   to the column meta data entries in the adat.
#' @author Stu Field
#' @importFrom tibble as_tibble
#' @noRd
convertColMeta <- function(x) {
  # conversion fails if un-equal length columns
  tbl <- setNames(as_tibble(x), cleanNames(names(x)))

  if ( !is.null(tbl$Dilution) ) {
    tbl$Dilution2 <- as.numeric(gsub("%$|Mix ", "", tbl$Dilution)) / 100
  }

  convert_lgl <- function(.x) {
    w <- tryCatch(as.numeric(.x), warning = function(w) w)
    is_warn <- inherits(w, "simpleWarning")
    # NA warning tripped?
    na_warn <- is_warn && identical(w$message, "NAs introduced by coercion")
    num_ok  <- !na_warn
    num_ok && !inherits(.x, c("factor", "integer")) # don't touch factors/integers
  }
  idx <- which(vapply(tbl, convert_lgl, NA))
  for ( i in idx ) tbl[[i]] <- as.numeric(tbl[[i]])
  tbl$Dilution <- as.character(tbl$Dilution)    # keep character
  tbl$SeqId    <- getSeqId(tbl$SeqId, TRUE)     # rm versions; safety
  tbl
}
