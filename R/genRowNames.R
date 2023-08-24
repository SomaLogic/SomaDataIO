#' Generates row names for a `soma_adat` object
#'
#' @param adat A data frame representing an ADAT.
#' @return A vector of row names derived from `SlideId_Subarray`.
#' @noRd
genRowNames <- function(adat) {

  checkDups <- function(x) any(duplicated(x))   # internal

  if ( all(c("Subarray", "SlideId") %in% names(adat)) ) {

    adat_rn <- paste0(adat$SlideId, "_", adat$Subarray)

    # Added for datasets with same slide_id sub-scanned with different software
    # nocov start
    if ( checkDups(adat_rn) ) {
      if ( "PlateId" %in% names(adat) ) {
        adat_rn <- paste0(adat$PlateId, "_", adat_rn)
      } else if ( "DatasetId" %in% names(adat) ) {
        adat_rn <- paste0(adat$DatasetId, "_", adat_rn)
      }
      if ( checkDups(adat_rn) ) {
        warning(
          "Found duplicate row names, i.e. `SlideId_Subarray` non-unique. ",
          "They will be numbered sequentially.", call. = FALSE
        )
        adat_rn <- seq_len(nrow(adat))
      }
    }
    # nocov end
  } else {
    warning(
      "No SlideId_Subarray found in ADAT. ",
      "Rows numbered sequentially.", call. = FALSE
    )
    adat_rn <- as.character(seq_len(nrow(adat)))
  }
  adat_rn
}
