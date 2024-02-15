#' Lift an ADAT Between Assay Versions
#'
#' The SomaScan platform continually improves its technical processes
#' between assay versions; from changing reagents, liquid handling equipment,
#' and increased analyte content. However, these upgrades can result in
#' minute differences in RFU space for a given analyte, requiring a calibration
#' (aka "lifting" or "bridging") to bring RFUs into a comparable space.
#' This is accomplished by applying an analyte-specific scalar to each analyte
#' RFU (ADAT column). The scalar values themselves are typically provided
#' via `*.xlsx` file, which can be parsed via [read_annotations()]. See Details.
#'
#' Lifting between various versions requires a specific
#' annotations file containing scalars specific to desired lifting direction.
#' For example, to "lift" between `v4.1` -> `v4.0`, you *must* be working
#' with SomaScan data in `v4.1` space and an annotations file containing
#' scalars to convert __to__ `v4.0`.
#' Likewise, "lifting" from `v4.0` -> `v4.1` requires
#' a separate annotations file and a `soma_adat` from SomaScan `v4.0`.
#'
#' @inheritParams params
#' @param bridge The direction of the lift (i.e. bridge).
#' @param anno.tbl Deprecated.
#' @return A "lifted" `soma_adat` object corresponding to the scaling
#'   reference in the `anno.tbl`. RFU values are rounded to 1 decimal to
#'   match standard SomaScan delivery format.
#' @examples
#' # `example_data` is SomaScan V4 (5k)
#' adat <- head(example_data, 3L)
#' getSomaScanVersion(example_data)
#'
#' # perform the 'lifting'
#' lift_7k <- lift_adat(adat, "5k_to_7k")
#' is_lifted(lift_7k)
#'
#' # attributes updated to reflect the 'lift'
#' attr(lift_7k, "Header")$HEADER$SignalSpace
#' attr(lift_7k, "Header")$HEADER$ProcessSteps
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
#' [is_lifted()] checks whether an object
#' has been lifted (bridged) by the presence
#' (or absence) of the `SignalSpace` entry
#' in the `soma_adat` attributes.
#'
#' @rdname lift_adat
#' @return Logical. Whether `adat` has been lifted.
#' @export
is_lifted <- function(adat) {
  x <- attr(adat, "Header.Meta")$HEADER
  !is.null(x$SignalSpace)
}
