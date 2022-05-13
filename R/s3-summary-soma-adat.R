
#' S3 Summary
#'
#' S3 [summary()] method returns the following for each column of the ADAT
#' object containing SOMAmer data (clinical meta data is *excluded*):
#'   * Target (if available)
#'   * Minimum value
#'   * 1st Quantile
#'   * Median
#'   * Mean
#'   * 3rd Quantile
#'   * Maximum value
#'   * Standard deviation
#'   * Median absolute deviation ([mad()])
#'   * Interquartile range ([IQR()])
#'
#' @rdname soma_adat
#' @order 3
#' @param tbl An annotations table. If `NULL` (default),
#' annotation information is extracted from the object itself (if possible).
#' Alternatively, the result of a call to [getAnalyteInfo()], from
#' which Target names can be extracted.
#' @param digits Integer. Used for number formatting with [signif()].
#' @examples
#' # S3 summary method
#' # MMP (4) analytes
#' mmps <- c("seq.2579.17", "seq.2788.55", "seq.2789.26", "seq.4925.54")
#' summary(my_adat[, mmps])
#'
#' # Summarize by group
#' my_adat[, mmps] |>
#'   split(my_adat$Sex) |>
#'   lapply(summary)
#'
#' # Alternatively pass annotations with Target info
#' anno <- getAnalyteInfo(my_adat)
#' summary(my_adat[, mmps], tbl = anno)
#' @importFrom stats IQR mad sd
#' @importFrom stats setNames
#' @export
summary.soma_adat <- function(object, tbl = NULL,
                              digits = max(3L, getOption("digits") - 3L), ...) {

  if ( is.null(tbl) ) {
    tbl <- getAnalyteInfo(object)
  }

  nm   <- getAnalytes(object)
  labs <- c("Target", "Min", "1Q", "Median", "Mean", "3Q",
            "Max", "sd", "MAD", "IQR") |> .pad(6)

  vals <- dplyr::select(object, nm) |>
    lapply(function(.x) {
      vec <- .x[!is.na(.x)]         # rm NaN/NA; outside b/c summary()
      format(c(unname(summary(vec)), sd(vec), mad(vec), IQR(vec)),
             digits = digits)
    })

  # lookup table
  look <- as.list(tbl$Target) |> setNames(tbl$AptName)
  tgts <- setNames(names(vals), names(vals)) |>
    lapply(function(.x) ifelse(is.null(look[[.x]]), "", look[[.x]]))  # if NULL -> ""

  setNames(nm, nm) |>
    lapply(function(.col)
      paste(labs, ":", .pad(c(tgts[[.col]], vals[[.col]]), width = 10))) |>
    data.frame() |>
    addClass("adat_summary")
}

#' @noRd
#' @importFrom utils capture.output
#' @export
print.adat_summary <- function(x, ...) {
  z <- as.matrix(x)
  rownames(z) <- rep.int("", nrow(z))
  out <- capture.output(print.default(z, quote = FALSE))
  lapply(out, function(.x) {
    if ( grepl("seq", .x) ) {
      cat(cr_red(.x), "\n")
    } else if ( grepl("Target", .x) ) {
      cat(cr_blue(.x), "\n")
    } else {
      cat(.x, "\n")
    }
  })
  invisible(x)
}
