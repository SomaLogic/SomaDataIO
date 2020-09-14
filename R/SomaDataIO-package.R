
#' @importFrom dplyr anti_join mutate select rename arrange full_join
#' @importFrom dplyr inner_join left_join right_join semi_join ungroup
#' @importFrom purrr map_df set_names
#' @importFrom tidyselect all_of
#' @keywords internal package
"_PACKAGE"


#' @name SomaDataIO-package
#'
#' @details Load an ADAT file into the global workspace with a call
#' to [read_adat()]. This function parses the main data
#' table into a `data.frame` object and assigns the remaining data from
#' the file as object `attributes`, i.e. call `attributes(adat)`.
#' Other functions in the package are designed to make extracting,
#' manipulating, and wrangling data in the newly created `soma_adat` 
#' object more convenient.
#'
#' Those familiar with micro-array data analysis and associated packages, e.g.
#' \pkg{Biobase}, will notice that the feature data (proteins) are arranged as
#' columns and the samples (arrays) are the rows. This is the
#' transpose of typical micro-array data. This conflict can be easily solved
#' using the transpose function, [t()], which is part of the `base` R.
#' In addition, those familiar with the standard `ExpressionSet` object,
#' available from `Bioconductor`, might find the functions [adat2eSet()] and
#' [pivotExpressionSet()] particularly useful.
#' @examples
#' # For a listing of all SomaDataIO functions
#' library(help = SomaDataIO)
#'
#' # To load an original adat call read_adat():
#' # There is a sample *.adat file provided in SomaDataIO
#' file <- system.file("example", "example_data.adat",
#'                     package = "SomaDataIO", mustWork = TRUE)
#' my_adat <- read_adat(file)
#'
#' # Object class `soma_adat`
#' class(my_adat)
#' is.soma_adat(my_adat)
#'
#' # Annotations Lookup Table
#' feature_table <- getFeatureData(my_adat)
#' feature_table
#'
#' # Find all analytes starting with "MMP" in `feature_table`
#' feature_table %>%
#'   dplyr::filter(grepl("^MMP", Target))
NULL
