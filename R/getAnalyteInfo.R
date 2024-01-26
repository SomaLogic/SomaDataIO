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
#' @inheritParams params
#' @return A `tibble` object with columns corresponding
#'   to the column meta data entries in the `soma_adat`. One row per analyte.
#' @author Stu Field
#' @seealso [getAnalytes()], [is_intact_attr()], [read_adat()]
#' @examples
#' # Get Aptamer table
#' anno_tbl <- getAnalyteInfo(example_data)
#' anno_tbl
#'
#' # Use `dplyr::group_by()`
#' dplyr::tally(dplyr::group_by(anno_tbl, Dilution))  # print summary by dilution
#'
#' # Columns containing "Target"
#' anno_tbl |>
#'   dplyr::select(dplyr::contains("Target"))
#'
#' # Rows of "Target" starting with MMP
#' anno_tbl |>
#'   dplyr::filter(grepl("^MMP", Target))
#' @importFrom tibble tibble
#' @export
getAnalyteInfo <- function(adat) {

  colmeta <- attr(adat, "Col.Meta")
  stopifnot(
    "`Col.Meta` is absent from ADAT." = !is.null(colmeta),
    "`Col.Meta` must be a `tbl_df`."  = inherits(colmeta, "tbl_df")
  )
  colmeta <- dplyr::ungroup(colmeta)  # for safety (previously a 'grouped_df')
  # AptName is the key index that links AnalyteInfo -> ADAT
  tbl <- tibble(AptName = getAnalytes(adat), SeqId = getSeqId(AptName, TRUE))

  if ( nrow(tbl) != nrow(colmeta) ) {
    warning(
      "Features inconsistent between `AptName` vs `SeqId` in `getAnalyteInfo()`.\n",
      "Merging annotations based on analyte features of `soma_adat`.", call. = FALSE
    )
  }
  dplyr::left_join(tbl, colmeta, by = "SeqId")
}
