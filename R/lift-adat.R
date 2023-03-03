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
#' @param adat A `soma_adat` class object.
#' @param anno.tbl A table of annotations, typically the result of a call
#'   to [read_annotations()].
#' @return A "lifted" `soma_adat` object corresponding to the scaling
#'   reference in the `anno.tbl`. RFU values are rounded to 1 decimal to
#'   match standard SomaScan delivery format.
#' @examples
#' # `example_data` is SomaScan V4
#' adat <- head(example_data, 3L)
#'
#' # read in version specific annotations file
#' # containing scaling values between assay versions
#' \dontrun{
#' tbl <- read_annotations("path/to/annotations_file.xlsx")
#' }
#'
#' # mock annotations table in lieu of `*.xlsx` file
#' tbl <- tibble::tibble(SeqId = getSeqId(getAnalytes(adat)),
#'                      "Plasma Scalar v4.0 to v4.1" = 1)   # scale by 1.0
#' # usually performed inside `read_annotations()`
#' # assign valid testing version to annotations table
#' attr(tbl, "version") <- "SL-99999999-rev99-1999-01"
#'
#' # perform the 'lifting'
#' lifted <- lift_adat(adat, tbl)
#'
#' # `tbl` contained all scalars = 1.0 (same RFUs)
#' all.equal(adat, lifted, check.attributes = FALSE)
#'
#' # attributes updated to reflect the 'lift'
#' attr(lifted, "Header")$HEADER$ProcessSteps
#' attr(lifted, "Header")$HEADER$SignalSpace
#' @importFrom tibble enframe deframe
#' @export
lift_adat <- function(adat, anno.tbl) {

  stopifnot(inherits(adat, "soma_adat"))
  atts <- attr(adat, "Header.Meta")$HEADER
  anno_ver <- attr(anno.tbl, "version")
  .check_anno(anno_ver)
  .check_anml(atts)

  if ( grepl("Plasma", atts$StudyMatrix, ignore.case = TRUE) ) {
    scalar_col <- ver_dict[[anno_ver]]$col_plasma
  } else if ( grepl("Serum", atts$StudyMatrix, ignore.case = TRUE) ) {
    scalar_col <- ver_dict[[anno_ver]]$col_serum
  } else {
    stop(
      "Unsupported matrix: ", .value(atts$StudyMatrix), ".\n",
      "Current supported matrices: 'EDTA Plasma' or 'Serum' for a ",
      "lifting transformation.", call. = FALSE
    )
  }

  if ( scalar_col %in% names(anno.tbl) ) {
    anno.tbl <- anno.tbl[, c("SeqId", scalar_col)]
  } else {
    stop(
      "Unable to find the required 'Scalar' column in the annotations file.\n",
      "Do you have the correct annotations file?",
      call. = FALSE
    )
  }

  # the 'space' refers to the assay version signal space
  from_space <- atts$SignalSpace      # prefer this; NULL if absent
  if ( is.null(from_space) ) {
    from_space <- atts$AssayVersion   # if missing; use this
  }

  .check_ver(from_space)
  .check_direction(scalar_col, from_space)

  new_space <- gsub(".*(v[0-9]\\.[0-9])$", "\\1", scalar_col)
  attr(adat, "Header.Meta")$HEADER$SignalSpace <- new_space
  new_step <- sprintf("Annotation Lift (%s to %s)", tolower(from_space), new_space)
  steps    <- attr(adat, "Header.Meta")$HEADER$ProcessSteps
  attr(adat, "Header.Meta")$HEADER$ProcessSteps <- paste0(steps, ", ", new_step)
  ref_vec <- deframe(anno.tbl)
  scaleAnalytes(adat, ref_vec) |> round(1L)
}



# Checks ----
# check attributes of annotations tbl for a version
# x = annotations version from annotations tbl
.check_anno <- function(x) {
  if ( is.null(x) ) {
    stop("Unable to determine the Annotations file version in `anno.tbl`.\n",
         "Please check the attributes via `attr(anno.tbl, 'version')`.",
         call. = FALSE)
  }
  if ( !x %in% names(ver_dict) ) {
    stop("Unknown Annotations file version from `anno.tbl`: ", .value(x),
         "\nUnable to proceed without knowing annotations table specs.",
         call. = FALSE)
  }
  invisible(NULL)
}

# check that SomaScan data has been ANML normalized
# x = Header attributes
.check_anml <- function(x) {
  steps <- x$ProcessSteps
  if ( is.null(steps) | !grepl("ANML", steps, ignore.case = TRUE) ) {
    stop("ANML normalized SOMAscan data is required for lifting.",
         call. = FALSE)
  }
  invisible(NULL)
}

# check supported versions: v4, v4.0, v4.1
.check_ver <- function(ver) {
  allowed <- c("v4", "v4.0", "v4.1")
  if ( !tolower(ver) %in% allowed ) {
    stop(
      "Unsupported assay version: ", .value(ver),
      ". Supported versions: ", .value(allowed), call. = FALSE
    )
  }
  invisible(NULL)
}

#' @param x the name of the scalar column from the annotations table.
#' @param y the assay version from the adat header information.
#' @noRd
.check_direction <- function(x, y) {
  y <- tolower(y)
  if ( grepl("4\\.1.*4\\.0", x) & y == "v4" ) {
    stop(
      "Annotations table indicates v4.1 -> v4.0, however the ADAT object ",
      "already appears to be in version ", y, " space.", call. = FALSE
    )
  }
  if ( grepl("4\\.0.*4\\.1", x) & y == "v4.1" ) {
    stop(
      "Annotations table indicates v4.0 -> v4.1, however the ADAT object ",
      "already appears to be in version ", y, " space.", call. = FALSE
    )
  }
  invisible(NULL)
}
