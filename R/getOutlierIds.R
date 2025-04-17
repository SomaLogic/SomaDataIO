#' Get Flagged Ids From MAD Outlier Map
#'
#' Return the IDs of flagged samples for objects of the `outlier_map` class.
#' Samples are flagged based on the percent analytes (RFU columns) for a given
#' sample that were identified as outliers using the median absolute
#' deviation (MAD).
#'
#' @family Calc Map
#' @inheritParams plot.Map
#' @param x An object of class:
#'   * `outlier_map` - from [calcOutlierMap()]
#' @param data Optional. The data originally used to create the map `x`. If
#'   omitted, a single column data frame is returned.
#' @param include Optional. Character vector of column name(s) in `data` to
#'   include in the resulting data frame. Ignored if `data = NULL`.
#' @return A `data.frame` of the indices (`idx`) of flagged samples, along
#'   with any additional variables as specified by `include`.
#' @author Caleb Scheidel
#' @examples
#' # flagged outliers
#' # create a single sample outlier (12)
#' out_adat <- example_data
#' apts     <- getAnalytes(out_adat)
#' out_adat[12, apts] <- out_adat[12, apts] * 10
#'
#' om <- calcOutlierMap(out_adat)
#' getOutlierIds(om, out_adat, flags = 0.05, include = c("Sex", "Subarray"))
#' @export
getOutlierIds <- function(x, flags = 0.05, data = NULL, include = NULL) {

  if ( !inherits(x, "outlier_map") ) {
    stop("Input `x` object must be class `outlier_map`!",
         call. = FALSE)
  }

  # ensure that flags value is between 0 & 1
  if ( flags < 0 || flags > 1 ) {
    stop("`flags =` argument must be between 0 and 1!", call. = FALSE)
  }

  flagged <- which(rowSums(x$matrix) >= ncol(x$matrix) * flags) |> unname()
  df_idx  <- data.frame(idx = flagged)  # default 1-col df

  if ( !length(flagged) ) {
    .todo("No observations were flagged at this flagging proportion: {.val {flags}}")
  }

  if ( is.null(data) ) {
    df_idx
  } else {
    stopifnot(
      "The `data` argument must be a `data.frame` object." = is.data.frame(data),
      "All `include` must be in `data`." = all(include %in% names(data))
    )
    df <- as.data.frame(data)  # strip soma_adat class
    cbind(
      df_idx,
      rm_rn(df[flagged, include, drop = FALSE])   # ensure no rn
    )
  }
}
