#' Merge Clinical Data into SomaScan
#'
#' Occasionally, additional clinical data is obtained _after_ samples
#' have been submitted to SomaLogic, or even after 'SomaScan'
#' results have been delivered.
#' This requires the new clinical variables, i.e. non-proteomic, data to be
#' merged with 'SomaScan' data into a "new" ADAT prior to analysis.
#' [merge_clin()] easily merges such clinical variables into an
#' existing `soma_adat` object and is a simple wrapper around [dplyr::left_join()].
#'
#' This functionality also exists as a command-line tool (R script) contained
#' in `merge_clin.R` that lives in the `cli/merge` system file directory.
#' Please see:
#' \itemize{
#'   \item `dir(system.file("cli/merge", package = "SomaDataIO"), full.names = TRUE)`
#'   \item `vignette("cli-merge-tool", package = "SomaDataIO")`
#' }
#'
#' @inheritParams params
#' @param clin_data One of 2 options:
#' \itemize{
#'   \item a data frame containing clinical variables to merge into `x`, or
#'   \item a path to a file, typically a `*.csv`,
#'     containing clinical variables to merge into `x`.
#' }
#' @param by A character vector of variables to join by.
#'   See [dplyr::left_join()] for more details.
#' @param by_class If `clin_data` is a file path, a named character vector
#'   of the variable and its class. This ensures the "by-key" is compatible
#'   for the join. For example, `c(SampleId = "character")`.
#'   See [read.table()] for details about its `colClasses` argument, and
#'   also the examples below.
#' @param ... Additional parameters passed to [dplyr::left_join()].
#' @return A `soma_adat` with new clinical variables merged.
#' @author Stu Field
#' @seealso [dplyr::left_join()]
#' @examples
#' # retrieve clinical data
#' clin_file <- system.file("cli/merge", "meta.csv",
#'                          package = "SomaDataIO",
#'                          mustWork = TRUE)
#' clin_file
#'
#' # view clinical data to be merged:
#' # 1) `group`
#' # 2) `newvar`
#' clin_df <- read.csv(clin_file, colClasses = c(SampleId = "character"))
#' clin_df
#'
#' # create mini-adat
#' apts <- withr::with_seed(123, sample(getAnalytes(example_data), 2L))
#' adat <- head(example_data, 9L) |>   # 9 x 2
#'   dplyr::select(SampleId, all_of(apts))
#'
#' # merge clinical variables
#' merged <- merge_clin(adat, clin_df, by = "SampleId")
#' merged
#'
#' # Alternative syntax:
#' #   1) pass file path
#' #   2) merge on different variable names
#' #   3) convert join type on-the-fly
#' clin_file2 <- system.file("cli/merge", "meta2.csv",
#'                           package = "SomaDataIO",
#'                           mustWork = TRUE)
#'
#' id_type <- typeof(adat$SampleId)
#' merged2 <- merge_clin(adat, clin_file2,                # file path
#'                       by = c(SampleId = "ClinKey"),    # join on 2 variables
#'                       by_class = c(ClinKey = id_type)) # match types
#' merged2
#' @importFrom utils read.csv
#' @importFrom dplyr left_join
#' @export
merge_clin <- function(x, clin_data, by = NULL, by_class = NULL, ...) {

  stopifnot("`x` must be a `soma_adat`."  = is.soma_adat(x))

  if ( inherits(clin_data, "data.frame") ) {
    clin_df <- clin_data
  } else if ( is.character(clin_data) &&
              length(clin_data) == 1L &&
              file.exists(clin_data) ) {
    clin_df <- normalizePath(clin_data, mustWork = TRUE) |>
      utils::read.csv(header = TRUE, colClasses = by_class, row.names = NULL,
                      stringsAsFactors = FALSE)
  } else {
    stop(
      "Invalid `clin_data` argument: ", .value(class(clin_data)),
      "\n`clin_data` must be either a `data.frame` or file path.", call. = FALSE)
  }

  dplyr::left_join(x, clin_df, by = by, ...)
}
