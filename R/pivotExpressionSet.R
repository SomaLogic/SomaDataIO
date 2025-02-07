#' Convert to Long Format
#'
#' Utility to convert an `ExpressionSet` class object
#' from the "wide" data format to the "long" format via [tidyr::pivot_longer()].
#' The \pkg{Biobase} package is required for this function.
#'
#' @family eSet
#' @param eSet An `ExpressionSet` class object, created using [adat2eSet()].
#' @return A `tibble` consisting of the long format
#'   conversion of an `ExpressionSet` object.
#' @author Stu Field
#' @examplesIf rlang::is_installed("Biobase")
#' # subset into a reduced mini-ADAT object
#' # 10 samples (rows)
#' # 5 clinical variables and 3 features (cols)
#' sub_adat <- example_data[1:10, c(1:5, 35:37)]
#' ex_set   <- adat2eSet(sub_adat)
#'
#' # convert ExpressionSet object to long format
#' adat_long <- pivotExpressionSet(ex_set)
#' @importFrom tibble as_tibble
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr left_join select
#' @export
pivotExpressionSet <- function(eSet) {

  if ( !requireNamespace("Biobase", quietly = TRUE) ) {
    # nocov start
    stop(
      "The `Biobase` package is required to use this function.\n",
      "See ?adat2eSet for installation instructions.", call. = FALSE
    )
    # nocov end
  }

  # samples (rows) x features (cols); move rn -> 1st column
  f_data <- Biobase::fData(eSet) |> rn2col("feature")
  p_data <- Biobase::pData(eSet) |> rn2col("array_id")

  data_long <- Biobase::exprs(eSet) |>
    t() |> data.frame() |> rn2col("array_id") |>
    tidyr::pivot_longer(cols = -array_id, names_to = "feature")

  data_long |>
    dplyr::left_join(f_data, by = "feature") |>    # merge feature data
    dplyr::left_join(p_data, by = "array_id") |>   # merge clinical data
    dplyr::arrange(array_id) |>                    # order by sample/array
    dplyr::select(array_id, feature, dplyr::everything()) |>  # re-order
    dplyr::select(-value, dplyr::everything()) |>  # move 'value' to end
    tibble::as_tibble()                             # convert to tibble
}
