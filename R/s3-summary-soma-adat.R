# Summary ----

#' @describeIn read_adat
#' The associated S3 generic summary method ([summary()]) returns
#' the following for each column of the ADAT object containing SOMAmer data
#' (clinical meta data is excluded):
#' \itemize{
#'   \item{Target (if available)}
#'   \item{Minimum value}
#'   \item{1st Quantile}
#'   \item{Median}
#'   \item{Mean}
#'   \item{3rd Quantile}
#'   \item{Maximum value}
#'   \item{Standard deviation}
#' }
#' @param object Object of class `soma_adat` used in
#' the S3 generic [summary()].
#' @param apt.data An optional object, the result of a call to
#' `getAptData`, from which Target names can be extracted.
#' If `NULL` (default), and the attributes of `object` are intact,
#' Target names are extracted from the "Col.Meta" of the attributes.
#' If neither of these options are available, the search path is interrogated
#' for `adat_data`, where it may find `apt_data`, which is used to
#' extract Target names. If none of the above options are available,
#' the "Target" row of the S3 [summary()] method is left blank.
#' @param digits Integer. Used for number formatting
#' with [signif()].
#' @examples
#' # S3 summary method
#' # MMP analytes
#' mmps <- c("seq.2579.17", "seq.2788.55", "seq.2789.26",
#'           "seq.2838.53", "seq.2954.56", "seq.3743.1",
#'           "seq.4160.49", "seq.4496.60", "seq.4924.32",
#'           "seq.4925.54", "seq.5002.76", "seq.5268.49")
#' summary(my_adat[, mmps])  # summary of MMPs
#'
#' # Alternatively pass apt.data for Target info
#' \dontrun{
#' ad <- apt_data                 # internal SomaLogic use
#' ad <- ex_somamer_table         # if using SomaDataIO
#' summary(my_adat[, mmps], apt.data = ad)
#' }
#'
#' @importFrom stats IQR mad sd
#' @importFrom purrr map set_names flatten
#' @export
summary.soma_adat <- function(object, apt.data,
                              digits = max(3L, getOption("digits") - 3L), ...) {

  if ( !missing(apt.data) ) {
    ad <- apt.data
  } else {
    ad <- attributes(object)$Col.Meta
  }

  nm <- names(object) %>% get_features()
  nc <- length(nm)
  new_labels <- c("Min", "1Q", "Median", "Mean", "3Q", "Max", "sd", "MAD", "IQR")
  nr <- length(new_labels) + 1
  col_nchar <- numeric(nc)

  summ <- dplyr::select(object, nm) %>%
    purrr::map(function(.x) {
      vec <- .x[!is.na(.x)]         # rm NaN/NA
      c(summary, sd, mad, IQR) %>%
        purrr::map(., function(f) f(vec, ...)) %>%
        purrr::flatten() %>%
        purrr::set_names(new_labels)
    })

  z <- list()

  for ( i in seq_len(nc) ) {
    nums <- format(summ[[i]], digits = digits)
    if ( getSeqId(nm[i]) %in% getSeqId(ad$SeqId, TRUE) ) {
      tgts <- ad$Target[ which(getSeqId(nm[i]) == getSeqId(ad$SeqId, TRUE)) ]
    } else {
      tgts <- ""
    }
    vals <- c(Target = tgts, nums)
    labs <- format(names(vals))
    col_nchar[i] <- nchar(labs[1L], type = "w")
    z[[i]] <- paste0(labs, ":", vals, "  ")
  }
  z      <- unlist(z, use.names = TRUE)
  dim(z) <- c(nr, nc)
  blanks <- paste(character(max(nchar(nm, type = "w"), na.rm = TRUE) + 2L),
                  collapse = " ")
  pad         <- floor(col_nchar - nchar(nm, type = "w") / 2) # pad blanks
  final_nm    <- paste0(substring(blanks, 1, pad), nm)
  dimnames(z) <- list(rep.int("", nr), final_nm)
  structure(z, class = "table")
}
