#' Scale/transform Analyte RFUs
#'
#' Scale analytes by a scalar reference value with `SeqId` names to
#' match with the analytes contained in `.data`. Columns without a
#' corresponding reference value are not modified (with a warning).
#'
#' @param .data A `soma_adat` class object ... _must_ be a `soma_adat` for
#'   downstream methods to properly dispatch.
#' @param scale_vec A vector of scalars, named by `SeqId`, see [getSeqId()].
#' @author Stu Field
#' @examples
#' apts <- withr::with_seed(101, sample(getAnalytes(example_data), 3L))
#' adat <- head(example_data, 3L) |> dplyr::select(SampleId, all_of(apts))
#' ref  <- c("3072-4" = 10.0, "18184-28" = 0.1, "4430-44" = 1.0)
#' new  <- scaleAnalytes(adat, ref)
#' new
#' @importFrom tibble enframe deframe
#' @noRd
scaleAnalytes <- function(.data, scale_vec) {

  .code <- function(x) {
    paste0("\033[90m", encodeString(x, quote = "`"), "\033[39m")
  }

  if ( !is.soma_adat(.data) ) {
    obj  <- class(.data)[1L]
    call <- match.call()
    new  <- paste0("addClass(", deparse(call[[2L]]), ", \"soma_adat\")")
    call[[2L]] <- str2lang(new)
    msg <- sprintf(
      "`scaleAnalytes()` must be called on a %s object, not a %s.\n",
      .value("soma_adat"), .value(obj)
    )
    msg2 <- sprintf("Perhaps: %s?", .code(deparse(call)))
    stop(msg, msg2, call. = FALSE)
  }

  apts <- getAnalytes(.data)
  stbl <- enframe(scale_vec, "SeqId")
  matches <- getSeqIdMatches(apts, stbl$SeqId)   # order matters; apts 1st
  missing <- setdiff(apts, matches$apts)
  extra   <- setdiff(stbl$SeqId, matches$`stbl$SeqId`)
  if ( length(missing) > 0L ) {
    warning(
      "Missing scalar value for (", length(missing), ") analytes. ",
      "They will not be transformed.\n",
      "Please check the reference or its named SeqIds.",
      call. = FALSE
    )
  }
  if ( length(extra) > 0L ) {
    warning(
      "There are extra scaling values (", length(extra), ") in the reference.\n",
      "They will be ignored.", call. = FALSE
    )
    stbl <- dplyr::filter(stbl, SeqId %in% matches$`stbl$SeqId`)
  }

  svec <- deframe(stbl)               # return to named vector
  svec <- svec[matches$`stbl$SeqId`]  # order reference to the adat

  stopifnot(all(names(svec) %in% getSeqId(apts)))

  # apply svec scalars by column
  new <- transform(.data[, matches$apts, drop = FALSE], unname(svec))
  .data[, matches$apts] <- data.frame(new, row.names = NULL)
  .data
}
