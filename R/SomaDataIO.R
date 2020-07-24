
#' @importFrom dplyr anti_join mutate select rename arrange full_join
#' @importFrom dplyr inner_join left_join right_join semi_join ungroup
#' @importFrom purrr map_df set_names
#' @importFrom tidyselect all_of
#' @keywords internal package
"_PACKAGE"


#' @name SomaDataIO-package
#'
#' @details To load an ADAT file into the global workspace, call
#' `read_adat("path/to/file.adat")`. This function parses the main data
#' table into a `data.frame` and assigns the remaining data from the
#' `"*.adat"` file as object `attributes`, call `attributes(adat)`.
#' The other functions in the package are designed to make extracting data
#' from and manipulating the newly created `soma_adat` object convenient.
#'
#' Those familiar with micro-array data analysis and associated packages, e.g.
#' \pkg{Biobase}, will notice that the feature data (proteins) are arranged as
#' columns and the samples (arrays) are the rows of the data frame. This is the
#' inverse of typical micro-array data. This conflict can be easily solved
#' using the transpose function, `t()`, which is part of the
#' "package:base" in a standard R installation. In addition, those familiar
#' with the standard `ExpressionSet` object, available from
#' `Bioconductor`, might find the functions [adat2eSet()] and
#' [pivotExpressionSet()] particularly useful.
#' @examples
#' # For a listing of all SomaDataIO functions
#' library(help = SomaDataIO)
#'
#' # To load an original adat call read_adat():
#' # There is a sample *.adat file provided in SomaDataIO
#' file <- system.file("sample", "sample.adat",
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
