#' Get Analyte Annotation Information
#'
#' Uses the `Col.Meta` attribute (analyte annotation data that appears above
#' the protein measurements in the `*.adat` text file) of a `soma_adat` object,
#' adds the `AptName` column key, conducts a few sanity checks, and
#' generates a "lookup table" of analyte data that can be used for simple
#' manipulation and indexing of analyte annotation information.
#' Most importantly, the analyte column names of the `soma_adat`
#' (e.g. `seq.XXXX.XX`) become the `AptName` column of the lookup table and
#' represents the key index between the table and `soma_adat` from which it comes.
#'
#' @param adat A `soma_adat` object (with intact attributes),
#' typically created using [read_adat()].
#' @return A `tibble` object with columns corresponding
#' to the column meta data entries in the `soma_adat`; 1 row per analyte.
#' @author Stu Field
#' @seealso [getAnalytes()], [is.intact.attributes()], [read_adat()]
#' @examples
#' # Get Aptamer table
#' anno_tbl <- getAnalyteInfo(example_data)
#' anno_tbl
#'
#' # Use `dplyr::group_by()`
#' dplyr::tally(dplyr::group_by(anno_tbl, Dilution))     # Print summary by dilution
#'
#' # Columns containing "Target"
#' anno_tbl %>% dplyr::select(dplyr::contains("Target"))
#'
#' # Rows of "Target" starting with MMP
#' anno_tbl %>% dplyr::filter(grepl("^MMP", Target))
#' @importFrom tibble tibble
#' @export
getAnalyteInfo <- function(adat) {

  colmeta <- adat %@@% "Col.Meta"
  stopifnot(!is.null(colmeta), inherits(colmeta, "tbl_df"))
  colmeta %<>% dplyr::ungroup()    # safety; previously a 'grouped_df'
  L <- vapply(colmeta, length, FUN.VALUE = 1L, USE.NAMES = FALSE)

  if ( !(diff(range(L)) < .Machine$double.eps^0.5) ) {
    warning("Unequal lengths in column meta data", call. = FALSE)
    max <- max(L)
    colmeta %<>% purrr::map_if(L < max, ~ c(.x, rep(NA, max - length(.x))))
  }

  # Ensure `AptName` can be used in the ADAT it comes from
  # AptName is the key index that links AnalyteInfo -> ADAT
  tbl <- tibble::tibble(AptName = getAnalytes(adat),
                        SeqId   = getSeqId(AptName, TRUE))
  if ( nrow(tbl) != nrow(colmeta) ) {
    warning(
      "Features inconsistent between `AptName` vs `SeqId` in `getAnalyteInfo()`.\n",
      "Merging annotations based on analyte features of `soma_adat`.", call. = FALSE
    )
  }
  dplyr::left_join(tbl, colmeta, by = "SeqId")
}
