#' Create Example SomaScan Data
#'
#' Creates a `soma_adat` object for examples, testing, and demonstrations.
#' This function returns the original `example_data` either in full or as a
#' minimal 10-sample subset for faster execution.
#'
#' @param size Character. Either `"full"` (default, 192 samples) or `"minimal"`
#'   (10 samples). The `"minimal"` size is useful for faster execution in tests
#'   and examples.
#' @return A `soma_adat` object with:
#'   \itemize{
#'     \item **Full**: 192 samples (170 clinical, 10 calibrators, 6 QC, 6 buffer)
#'     \item **Minimal**: 10 samples (first 10 from full dataset)
#'     \item 5284 analyte features (`seq.XXXX.XX` format)
#'     \item 34 metadata columns
#'     \item Proper `soma_adat` attributes (Header.Meta, Col.Meta, file_specs, etc.)
#'   }
#' @details
#' The data is based on the original SomaScan V4 EDTA-plasma example data from
#' \url{https://github.com/SomaLogic/SomaLogic-Data/blob/main/example_data.adat}.
#' The data includes:
#' \itemize{
#'   \item Sample types include: Sample, Calibrator, QC, and Buffer
#'   \item Age and Sex variables contain simulated biological signal
#'   \item RFU values from real SomaScan assay data
#'   \item All proper ADAT attributes and metadata are included
#'   \item Data is stored internally in `sysdata` for instant access
#' }
#'
#' @note This function replaces the static `example_data` package data object.
#'   For backward compatibility, `example_data` is still available via lazy loading
#'   and calls this function internally.
#'
#' @seealso [create_ex_analytes()], [create_ex_anno_tbl()], [create_ex_target_names()],
#'   [create_ex_clin_data()]
#' @examples
#' # Create full dataset (192 samples)
#' full_data <- create_example_data(size = "full")
#' dim(full_data)
#' table(full_data$SampleType)
#'
#' # Create minimal dataset (10 samples) for faster examples
#' mini_data <- create_example_data(size = "minimal")
#' dim(mini_data)
#'
#' # The object has proper soma_adat structure
#' class(mini_data)
#' is.soma_adat(mini_data)
#' @export
create_example_data <- function(size = c("full", "minimal")) {
  size <- match.arg(size)

  if (size == "full") {
    # Return the complete original example_data from internal package data
    # The metadata (CreatedBy, CreatedDate) is already set in the stored object
    return(original_example_data_full)
  }

  # For minimal size, return first 10 samples from the original data
  adat <- original_example_data_full[1:10, ]
  return(adat)
}


#' Create Example Analytes Vector
#'
#' Returns the analyte (feature) variable names from the example dataset.
#'
#' @param example_data Optional. A `soma_adat` object. If `NULL`, will create
#'   a full example dataset using `create_example_data("full")`.
#' @return A character vector of analyte names (`seq.XXXX.XX` format).
#' @seealso [create_example_data()], [getAnalytes()]
#' @examples
#' apts <- create_ex_analytes()
#' head(apts)
#' length(apts)
#' @export
create_ex_analytes <- function(example_data = NULL) {
  if (is.null(example_data)) {
    example_data <- create_example_data("full")
  }
  getAnalytes(example_data)
}


#' Create Example Annotation Table
#'
#' Returns the annotations table (column metadata) from the example dataset.
#'
#' @param example_data Optional. A `soma_adat` object. If `NULL`, will create
#'   a full example dataset using `create_example_data("full")`.
#' @return A tibble with analyte annotation information.
#' @seealso [create_example_data()], [getAnalyteInfo()]
#' @examples
#' anno <- create_ex_anno_tbl()
#' dim(anno)
#' names(anno)
#' @export
create_ex_anno_tbl <- function(example_data = NULL) {
  if (is.null(example_data)) {
    example_data <- create_example_data("full")
  }
  getAnalyteInfo(example_data)
}


#' Create Example Target Names Map
#'
#' Returns a mapping of analyte names to target protein names from the
#' example dataset.
#'
#' @param example_data Optional. A `soma_adat` object. If `NULL`, will create
#'   a full example dataset using `create_example_data("full")`.
#' @return A named list of class `target_map` mapping SeqId feature names to
#'   target protein names.
#' @seealso [create_example_data()], [getTargetNames()]
#' @examples
#' targets <- create_ex_target_names()
#' length(targets)
#' head(targets, 3)
#' @export
create_ex_target_names <- function(example_data = NULL) {
  if (is.null(example_data)) {
    example_data <- create_example_data("full")
  }
  anno_tbl <- getAnalyteInfo(example_data)
  getTargetNames(anno_tbl)
}


#' Create Example Clinical Data
#'
#' Returns a clinical data table with additional sample annotations for merging
#' to example data.
#'
#' @param example_data Optional. A `soma_adat` object. If `NULL`, will create
#'   a full example dataset using `create_example_data("full")`.
#' @return A tibble with `SampleId`, `smoking_status`, and `alcohol_use` columns
#'   for clinical samples.
#' @seealso [create_example_data()]
#' @examples
#' clin <- create_ex_clin_data()
#' dim(clin)
#' head(clin)
#' @export
create_ex_clin_data <- function(example_data = NULL) {
  if (is.null(example_data)) {
    example_data <- create_example_data("full")
  }

  # Generate with fixed seed for reproducibility (matching original)
  withr::with_seed(123, {
    example_data |>
      dplyr::filter(SampleType == "Sample") |>
      dplyr::mutate(
        smoking_status = sample(c("Current", "Past", "Never"),
                               size = dplyr::n(), replace = TRUE),
        alcohol_use = sample(c("Yes", "No"),
                            size = dplyr::n(), replace = TRUE)
      ) |>
      dplyr::select(SampleId, smoking_status, alcohol_use) |>
      tibble::as_tibble()
  })
}
