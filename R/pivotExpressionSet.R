#' Convert to Long Format
#'
#' Utility function that converts an `"ExpressionSet"` object
#' from the "wide" data format to the "long" format [pivot_longer()].
#'
#' @param eSet An `ExpressionSet` class object, created using [adat2eSet()].
#' @return An `tibble` class consisting of the long format
#' conversion of an `ExpressionSet` object.
#' @author Stu Field
#' @seealso [adat2eSet()], \pkg{Biobase}
#' @examples
#' # subet into a reduced ADAT object
#' # 5 clinical variables and 3 features
#' # 10 samples
#' sub_adat <- sample.adat[1:10, c(1:5, 25:27)]
#' ex_set <- adat2eSet(sub_adat)
#'
#' # convert to long format
#' adat_long <- pivotExpressionSet(ex_set)
#' @importFrom usethis ui_stop
#' @importFrom tibble rownames_to_column as_tibble
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr arrange left_join select everything
#' @importFrom stringr str_glue
#' @export pivotExpressionSet
pivotExpressionSet <- function(eSet) {

  if ( !requireNamespace("Biobase", quietly = TRUE) ) {
    usethis::ui_stop(
      "The `Biobase` package is required to use this function.
      See ?adat2eSet for installation instructions.",
    )
  }

  # samples (rows) x features (cols)
  f_data <- tibble::rownames_to_column(Biobase::fData(eSet), "feature")
  p_data <- tibble::rownames_to_column(Biobase::pData(eSet), "array_id")

  data_long <- Biobase::exprs(eSet) %>%
    t() %>% data.frame() %>%
    tibble::rownames_to_column("array_id") %>%
    tidyr::pivot_longer(cols = -array_id, names_to = "feature")

  data_long %>%
    dplyr::left_join(f_data, by = "feature") %>%    # merge feature data
    dplyr::left_join(p_data, by = "array_id") %>%   # merge clinical data
    dplyr::arrange(array_id) %>%                    # order by sample/array
    dplyr::select(array_id, feature, dplyr::everything()) %>%  # re-order
    dplyr::select(-value, dplyr::everything()) %>%  # move 'value' to end
    tibble::as_tibble()                             # conver to tibble
}
