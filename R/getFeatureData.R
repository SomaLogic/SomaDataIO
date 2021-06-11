#' Get Feature Data
#'
#' Uses the Column Meta data (meta data that appears above the protein
#' measurements in the ADAT file) from the intact attributes of a `soma_adat`
#' object and compiles them into a `tibble` ([tibble()]) object for simple
#' manipulation and indexing. The feature names of the ADAT become the
#' first column named `AptName`, which represents the key index between the
#' annotations table and `soma_adat` from which it comes.
#' This generates a "lookup table" that can be used for simple manipulation
#' and indexing of analyte annotation information.
#'
#' @param adat An ADAT with intact attributes (i.e. has not been modified thus
#' stripping original attributes), typically created using [read_adat()].
#' @return A [tibble()] with columns corresponding to the column meta
#' data entries in the ADAT. The tibble has a designated column "AptName"
#' corresponding to the features in the ADAT, which can be retrieved using
#' [getAnalytes()]. This column can be use for indexing desired analytes.
#' @author Stu Field
#' @seealso [getAnalytes()]
#' @examples
#' # Attribute check
#' is.intact.attributes(example_data)   # must be TRUE
#'
#' tbl <- getFeatureData(example_data)
#' tbl
#'
#' # Use `dplyr::group_by()`
#' dplyr::tally(dplyr::group_by(tbl, Dilution))     # Print summary by dilution
#'
#' # Columns containing "Target"
#' tbl %>% dplyr::select(dplyr::contains("Target"))
#'
#' # Rows of "Target" starting with MMP
#' tbl %>% dplyr::filter(stringr::str_detect(Target, "^MMP"))
#' @importFrom usethis ui_stop ui_warn
#' @importFrom tibble as_tibble tibble
#' @importFrom purrr map_if map_int
#' @importFrom dplyr ungroup left_join
#' @export
getFeatureData <- function(adat) {
  stopifnot(is.intact.attributes(adat))
  colmeta <- attributes(adat)$Col.Meta %>% dplyr::ungroup()
  L <- purrr::map_int(colmeta, length)
  if ( !all(L == L[1L]) ) {
    usethis::ui_warn("Unequal lengths in column meta data")
    max <- max(L)
    colmeta %<>%
      purrr::map_if(L < max, ~ c(.x, rep(NA, max - length(.x))))
  }
  if ( !inherits(colmeta, "tbl_df") ) {
    colmeta %<>% tibble::as_tibble()
  }
  # We want to ensure `AptName` is an index
  # that can be used in the ADAT it comes from
  # AptName is the column that links AptData -> ADAT
  tbl <- tibble::tibble(AptName = getAnalytes(adat),
                        SeqId   = getSeqId(AptName, TRUE))
  if ( nrow(tbl) != nrow(colmeta) ) {
    usethis::ui_warn(
      "Features inconsistent between `AptName` vs `SeqId` in `getFeatureData()`.
      Merging annotations based on features of `adat`."
    )
  }
  dplyr::left_join(tbl, colmeta, by = "SeqId")
}
