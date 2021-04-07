# Summary ----

#' @describeIn read_adat
#' An associated S3 generic summary method ([summary()]) returns
#' the following for each column of the ADAT object containing SOMAmer data
#' (clinical meta data is excluded):
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
#' @param object Object of class `soma_adat` used in
#' the S3 generic [summary()].
#' @param ft.data If `NULL` (default), and the attributes of `object` are
#' intact, `Target` names are extracted from the "Col.Meta" of the attributes.
#' Alternatively, the result of a call to [getFeatureData()], from
#' which Target names can be extracted. If neither of the above options are
#' available, the "Target" row of the S3 [summary()] method is left blank.
#' @param digits Integer. Used for number formatting with [signif()].
#' @examples
#' # S3 summary method
#' # MMP (4) analytes
#' mmps <- c("seq.2579.17", "seq.2788.55", "seq.2789.26", "seq.4925.54")
#' summary(my_adat[, mmps])
#'
#' # Summarize by group
#' my_adat[, mmps] %>%
#'   split(my_adat$Sex) %>%
#'   lapply(summary)
#'
#' # Alternatively pass `ft.data` for Target info
#' # Obtained from `getFeatureData()`
#' tbl <- attributes(my_adat)$Col.Meta
#' tbl$AptName <- sub("-", ".", paste0("seq.", tbl$SeqId))
#' summary(my_adat[, mmps], ft.data = tbl)
#'
#' @importFrom stats IQR mad sd
#' @importFrom purrr map map2_df walk
#' @importFrom rlang set_names
#' @importFrom stringr str_pad
#' @importFrom utils capture.output
#' @export
summary.soma_adat <- function(object, ft.data,
                              digits = max(3L, getOption("digits") - 3L), ...) {

  if ( !missing(ft.data) ) {
    ad <- ft.data
  } else {
    ad <- attributes(object)$Col.Meta
    ad$AptName <- sub("-", ".", paste0("seq.", ad$SeqId))
  }

  labs <- c("Target", "Min", "1Q", "Median", "Mean", "3Q",
            "Max", "sd", "MAD", "IQR") %>%
    stringr::str_pad(width = 6, side = "right")
  nm   <- getFeatures(object)
  vals <- dplyr::select(object, nm) %>%
    purrr::map(function(.x) {
      vec <- .x[!is.na(.x)]         # rm NaN/NA; outside b/c summary()
      unname(c(summary(vec), sd(vec), mad(vec), IQR(vec))) %>%
        format(digits = digits)
    })

  # lookup table
  tbl  <- as.list(ad$Target) %>% rlang::set_names(ad$AptName)
  tgts <- names(vals) %>%
    rlang::set_names() %>%
    lapply(function(.x) ifelse(is.null(tbl[[.x]]), "", tbl[[.x]]))  # if NULL -> ""

  purrr::map2_df(
    tgts, vals, ~ paste(labs, ":", stringr::str_pad(c(.x, .y), width = 10,
                                                    side = "right"))
    ) %>%
    addClass("adat_summary")
}

#' @noRd
#' @importFrom crayon red blue
#' @importFrom purrr walk
#' @importFrom utils capture.output
#' @export
print.adat_summary <- function(x, ...) {
  z <- as.matrix(x)
  rownames(z) <- rep.int("", nrow(z))
  out <- capture.output(print.default(z, quote = FALSE))
  purrr::walk(out, ~ {
    if ( grepl("seq", .x) ) {
      cat(red(.x), "\n")
    } else if ( grepl("Target", .x) ) {
      cat(blue(.x), "\n")
    } else {
      cat(.x, "\n")
    }
  })
  invisible(x)
}
