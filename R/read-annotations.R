#' Import a SomaLogic Annotations File
#'
#' @param file A path to an annotations file location.
#'   This should be a SomaLogic annotations file in
#'   `*.xlsx` format.
#' @return A `tibble` containing analyte-specific annotations and
#'   related (e.g. lift/bridging) information, keyed on SomaLogic
#'   [SeqId], the unique SomaScan analyte identifier.
#' @examples
#' \dontrun{
#'   # for example
#'   file <- "~/Downloads/SomaScan_11K_v5.0_Plasma_Serum_Annotated_Menu.xlsx"
#'   anno_tbl <- read_annotations(file)
#' }
#' @importFrom readxl read_xlsx
#' @export
read_annotations <- function(file) {

  if ( !grepl("\\.xlsx$", file, ignore.case = TRUE) ) {
    stop("Annotations file must be in `*.xlsx` format.", call. = FALSE)
  }

  # Read the annotations file with standard skip value = 8L
  tbl  <- readxl::read_xlsx(file, sheet = "Annotations", skip = 8L)

  # map these fields to match those in ADATs
  map <- c(Target           = "Target Name",
           TargetFullName   = "Target Full Name",
           UniProt          = "UniProt ID",
           EntrezGeneID     = "Entrez Gene ID",
           EntrezGeneSymbol = "Entrez Gene Name")
  tbl <- dplyr::rename(tbl, !!!map)

  # check for expected fields in annotations file
  required_cols <- c("SeqId", "SomaId", "Target", "Type", "TargetFullName",
                     "Organism", "UniProt", "EntrezGeneID", "EntrezGeneSymbol")
  missing_cols <- setdiff(required_cols, names(tbl))

  if ( length(missing_cols) > 0 ) {
    stop("Missing required columns in annotations file: ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  tbl
}

