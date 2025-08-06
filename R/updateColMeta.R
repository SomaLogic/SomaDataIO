#' Update Col.Meta Attribute to Match Annotations Object
#'
#' Utility to update a provided `soma_adat` object's column
#' metadata to match the annotations object.
#'
#' Attempts to update the following column metadata in the adat:
#' - SomaId
#' - Target
#' - TargetFullName
#' - UniProt
#' - Type
#' - Organism
#' - EntrezGeneSymbol
#' - EntrezGeneID
#'
#' @param adat A `soma_adat` data object to update attributes.
#' @param anno A `tibble` containing analyte-specific annotations
#'   from `read_annotations()`
#' @return An identical object to `adat` with `Col.Meta` updated
#'   to match those in `anno`.
#' @author Caleb Scheidel
#' @examples
#' \dontrun{
#'  anno_tbl     <- read_annotations("path/to/annotations.xlsx")
#'  adat         <- read_adat("path/to/adat_file.adat")
#'  updated_adat <- updateColMeta(adat, anno_tbl)
#' }
#' @importFrom dplyr all_of left_join select
#' @export
updateColMeta <- function(adat, anno) {

  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

  # fields to be updated
  cols <- c('SomaId',
            'Target',
            'TargetFullName',
            'UniProt',
            'Type',
            'Organism',
            'EntrezGeneSymbol',
            'EntrezGeneID')

  # update the protein annotations in the ADAT file
  annots <- anno |> dplyr::select(SeqId, all_of(cols))

  orig_meta_names <- names(attributes(adat)$Col.Meta)

  attributes(adat)$Col.Meta <- attributes(adat)$Col.Meta |>
    dplyr::select(dplyr::all_of(setdiff(orig_meta_names, cols))) |>
    dplyr::left_join(annots, by = "SeqId") |>
    dplyr::select(dplyr::all_of(orig_meta_names))

  return(adat)
}
