#' Get Target Names
#'
#' @describeIn getAnalyteInfo
#' creates a lookup table (or dictionary) as a named list object of `AptNames`
#' and Target names in key-value pairs.
#' This is a convenient tool to quickly access a `TargetName` given
#' the `AptName` in which the key-value pairs map the `seq.XXXX.XX`
#' to its corresponding `TargetName` in `tbl`.
#' This structure which provides a convenient auto-completion mechanism at
#' the command line or for generating plot titles.
#'
#' @param tbl A `tibble` object containing analyte target annotation
#'   information. This is usually the result of a call to [getAnalyteInfo()].
#' @examples
#'
#' # Target names
#' tg <- getTargetNames(anno_tbl)
#'
#' # how to use for plotting
#' feats <- sample(anno_tbl$AptName, 6)
#' op <- par(mfrow = c(2, 3))
#' sapply(feats, function(.x) plot(1:10, main = tg[[.x]]))
#' par(op)
#' @export
getTargetNames <- function(tbl) {
  stopifnot(
    "`tbl` must contain Target info." =
      sum(c("TargetFullName", "Target") %in% names(tbl)) > 0,
    "`tbl` must contain an `AptName` column." = "AptName" %in% names(tbl)
  )
  targets <- tbl$TargetFullName %||% tbl$Target
  structure(as.list(targets), names = tbl$AptName, class = "target_map")
}


#' @noRd
#' @export
print.target_map <- function(x, ...) {
  writeLines(cli_rule("AptName-Target Lookup Map", line = 2, line_col = "magenta"))
  print(tibble::enframe(unlist(x), name = "AptName", value = "Target"))
  writeLines(cli_rule(line = 2, line_col = "green"))
  invisible(x)
}
