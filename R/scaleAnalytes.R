#' Scale/transform Analyte RFUs
#'
#' Scale analytes by a scalar reference value with `SeqId` names to
#' match with the analytes contained in `.data`.
#'
#' @param .data A `soma_adat` class object ... _must_ be a `soma_adat` for
#'   downstream methods to properly dispatch.
#' @param scale_vec A vector of scalars, named by `SeqId`, see [getSeqId()].
#' @author Stu Field
#' @examples
#' adat <- head(example_data, 3L)
#' apts <- getAnalytes(adat)
#' ref  <- setNames(rep(1, length(apts)), getSeqId(apts))   # ref = 1.0
#' new  <- scaleAnalytes(adat, ref)
#' identical(new, adat)
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
    stop(
      "Missing scalar value for ", length(missing), " analytes. ",
      "Cannot continue.\nPlease check the reference scalars, their names, ",
      "or the annotations file to proceed.",
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

  # should now be identical
  stopifnot(identical(getSeqId(apts), names(svec)))

  # apply svec scalars by column
  transform(.data, unname(svec))
}
