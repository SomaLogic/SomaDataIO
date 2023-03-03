
#' @importFrom utils head tail
#' @keywords internal package
"_PACKAGE"


#' @name SomaDataIO-package
#'
#' @details Load an ADAT file into the global workspace with a call
#'   to [read_adat()]. This function parses the main data
#'   table into a `data.frame` object and assigns the remaining data from
#'   the file as object `attributes`, i.e. call `attributes(adat)`.
#'   Other functions in the package are designed to make extracting,
#'   manipulating, and wrangling data in the newly created [SomaDataIO::soma_adat]
#'   object more convenient.
#'
#'   Those familiar with micro-array data analysis and associated packages, e.g.
#'   \pkg{Biobase}, will notice that the feature data (proteins) are arranged as
#'   columns and the samples (arrays) are the rows. This is the
#'   transpose of typical micro-array data. This conflict can be easily solved
#'   using the transpose function, [t()], which is part of the `base R`.
#'   In addition, those familiar with the standard `ExpressionSet` object,
#'   available from `Bioconductor`, might find the functions [adat2eSet()] and
#'   [pivotExpressionSet()] particularly useful.
#'
#' @examples
#' # a listing of all pkg functions
#' library(help = SomaDataIO)
#'
#' # the `soma_adat` class
#' class(example_data)
#' is.soma_adat(example_data)
#'
#' # Annotations Lookup Table
#' anno_tbl <- getAnalyteInfo(example_data)
#' anno_tbl
#'
#' # Find all analytes starting with "MMP" in `anno_tbl`
#' dplyr::filter(anno_tbl, grepl("^MMP", Target))
NULL
