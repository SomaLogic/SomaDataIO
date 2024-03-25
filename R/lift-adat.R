#' Lift an ADAT Between Assay Versions
#'
#' @description
#' The SomaScan platform continually improves its technical processes
#' between assay versions. The primary change of interest is content expansion,
#' and other protocol changes may be implemented including: changing reagents,
#' liquid handling equipment, and well volumes.
#'
#' Table of SomaScan assay versions:
#'
#' \tabular{lcr}{
#'   **Version**  \tab **Commercial Name** \tab **Size** \cr
#'   `V4`         \tab 5k                  \tab 5284     \cr
#'   `v4.1`       \tab 7k                  \tab 7596     \cr
#'   `v5.0`       \tab 11k                 \tab 11083    \cr
#' }
#'
#' However, for a given analyte, these technical upgrades can result
#' in minute measurement signal differences,
#' requiring a calibration (aka "lifting" or "bridging") to bring RFUs into a
#' comparable signal space.
#' This is accomplished by applying an analyte-specific scalar,
#' a linear transformation, to each analyte RFU measurement (column).
#' If you have an annotations file (`*.xlsx`) and wish to examine the
#' bridging scalars themselves, please see [read_annotations()].
#'
#' Lifting between SomaScan versions no longer requires an
#' annotations file containing lifting scalars. We now enable users to pass
#' a `bridge` parameter, indicating the direction of the bridge.
#' For example, to "lift" between `11k` -> `7k`, you _must_ be acting on
#' SomaScan data in `11k` RFU space and would pass `bridge = "11k_to_7k"`.
#' Likewise, `7k` -> `5k` requires `bridge = "7k_to_5k"`.
#' Lastly, you may also lift directly from `11k` -> `5k`
#' (aka "double-bridge") with `bridge = "11k_to_5k"`.
#' See below for all options for the `bridge` argument.
#'
#' @details
#' Matched samples across assay versions are used to calculate bridging
#' scalars. For each analyte, this scalar is computed as the ratio of
#' population _medians_ across assay versions.
#' Please see the lifting vignette
#' `vignette("lifting-and-bridging", package = "SomaDataIO")`
#' for more details.
#'
#' @section Lin's CCC:
#'   The Lin's Concordance Correlation Coefficient (CCC) is calculated
#'   by computing the correlation between post-lift RFU values and the
#'   RFU values generated on the original SomaScan version.
#'   This CCC estimate is a measure of how well an analyte can be bridged
#'   across SomaScan versions.
#'   See `vignette("lifting-and-bridging", package = "SomaDataIO")`.
#'   As with the lifting scalars, if you have an annotations file
#'   you may view the analyte-specific CCC values via [read_annotations()].
#'   Alternatively, [getSomaScanLiftCCC()] retrieves these values
#'   from an internal object for both `"serum"` and `"plasma"`.
#'
#' @section Analyte Setdiff:
#' * Newer versions of SomaScan typically have additional content, i.e.
#'   new reagents added to the multi-plex assay that bind to additional proteins.
#'   When lifting _to_ a previous SomaScan version, new reagents that do _not_
#'   exist in the "earlier" assay version assay are scaled by 1.0, and thus
#'   maintained, unmodified in the returned object. Users may need to drop
#'   these columns in order to combine these data with a previous study
#'   from an earlier SomaScan version, e.g. with [collapseAdats()].
#' * In the inverse scenario, lifting "forward" _from_ a previous, lower-plex
#'   version, there will be extra reference values that are unnecessary
#'   to perform the lift, and a warning is triggered. The resulting data
#'   consists of RFU data in the "new" signal space, but with fewer analytes
#'   than would otherwise be expected (e.g. `11k` space with only 5284
#'   analytes; see example below).
#'
#' @inheritParams params
#' @param bridge The direction of the lift (i.e. bridge).
#' @param anno.tbl `r lifecycle::badge("deprecated")`. Please now
#'   use the `bridge` argument.
#' @references Lin, Lawrence I-Kuei. 1989. A Concordance Correlation
#'   Coefficient to Evaluate Reproducibility. __Biometrics__. 45:255-268.
#' @return [lift_adat()]: A "lifted" `soma_adat` object corresponding to
#'   the scaling requested in the `bridge` parameter. RFU values are
#'   rounded to 1 decimal place to match standard SomaScan delivery format.
#' @examples
#' # `example_data` is SomaScan (V4, 5k)
#' adat <- head(example_data, 3L)
#' dim(adat)
#'
#' getSomaScanVersion(adat)
#'
#' getSignalSpace(adat)
#'
#' # perform 'lift'
#' lift_11k <- lift_adat(adat, "5k_to_11k")  # warning
#'
#' is_lifted(lift_11k)
#'
#' dim(lift_11k)
#'
#' # attributes updated to reflect the 'lift'
#' attr(lift_11k, "Header")$HEADER$SignalSpace
#'
#' attr(lift_11k, "Header")$HEADER$ProcessSteps
#' @importFrom tibble enframe deframe
#' @importFrom lifecycle deprecated is_present deprecate_warn
#' @export
lift_adat <- function(adat,
                      bridge = c("11k_to_7k", "11k_to_5k",
                                 "7k_to_11k", "7k_to_5k",
                                 "5k_to_11k", "5k_to_7k"),
                      anno.tbl = deprecated()) {

  stopifnot(
    "`adat` must be a `soma_adat` class object." = inherits(adat, "soma_adat"),
    "`adat` must have intact attributes."        = is_intact_attr(adat)
  )

  # syntax check for allowed params
  bridge <- match.arg(bridge)

  if ( is_present(anno.tbl) ) {
    deprecate_warn(
      "6.1.0",
      "SomaDataIO::lift_adat(anno.tbl =)",
      "SomaDataIO::lift_adat(bridge =)",
      details = paste0("Proceeding with ", .value(bridge), ".")
    )
  }

  atts <- attr(adat, "Header.Meta")$HEADER
  .check_anml(atts)

  # the 'space' refers to the SomaScan assay version signal space
  # prefer SignalSpace if present; NULL if absent
  from_space <- getSignalSpace(adat)
  checkSomaScanVersion(from_space)
  from_space <- map_ver2k[[from_space]]   # map ver to k and strip names
  new_space  <- .check_direction(from_space, bridge)  # check and return new space

  if ( grepl("Plasma", atts$StudyMatrix, ignore.case = TRUE) ) {
    ref_vec <- .get_lift_ref(matrx = "plasma", bridge = bridge)
  } else if ( grepl("Serum", atts$StudyMatrix, ignore.case = TRUE) ) {
    ref_vec <- .get_lift_ref(matrx = "serum", bridge = bridge)
  } else {
    stop(
      "Unsupported matrix: ", .value(atts$StudyMatrix), ".\n",
      "Current supported matrices: 'EDTA Plasma' or 'Serum' for a ",
      "lifting transformation.", call. = FALSE
    )
  }

  # update attrs with new SignalSpace information
  attr(adat, "Header.Meta")$HEADER$SignalSpace  <- map_k2ver[[new_space]]
  new_step <- sprintf("Lifting Bridge (%s -> %s)", tolower(from_space), new_space)
  steps    <- attr(adat, "Header.Meta")$HEADER$ProcessSteps
  attr(adat, "Header.Meta")$HEADER$ProcessSteps <- paste0(steps, ", ", new_step)
  scaleAnalytes(adat, ref_vec) |> round(1L)
}


#' Test for lifted objects
#'
#' @rdname lift_adat
#' @return [is_lifted()]: Logical. Whether the RFU values in a `soma_adat`
#'   have been lifted from its original signal space to a new signal space.
#' @export
is_lifted <- function(adat) {
  x <- attr(adat, "Header.Meta")$HEADER
  !is.null(x$SignalSpace)
}
