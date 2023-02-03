#' Import a SomaLogic Annotations File
#'
#' @param file A path to an annotations file location.
#'   This is a sanctioned, versioned file provided by
#'   SomaLogic Operating Co., Inc. and should be an unmodified
#'   `*.xlsx` file.
#' @return A `tibble` containing analyte-specific annotations and
#'   related information (e.g. lift/scale information), keyed on SomaLogic
#'   `"SeqId"` which is a unique analyte identifier.
#' @examples
#' \dontrun{
#' anno <- read_annotations("~/Desktop/SomaScan_V4.1_7K_Annotated_Content_20210616.xlsx")
#' }
#' @export
read_annotations <- function(file) {

  ext <- gsub("(.*)[.]([^.]+)$", "\\2", file)
  stopifnot(ext %in% c("xlsx", "json"))

  ver <- getAnnoVer(file)

  if ( !grepl("^SL-[0-9]+-rev[0-9]+", ver) ) {
    stop(
      "Unable to determine annotations file version: ", .value(ver),
      ".\nA valid annotations file version is required to proceed.",
      call. = FALSE
    )
  }

  if ( !ver %in% names(ver_dict) ) {
    stop(
      "Unknown version of the annotations file: ", .value(ver), ".",
      call. = FALSE
    )
  }

  skip <- ver_dict[[ver]]$skip
  tbl  <- readxl::read_xlsx(file, sheet = "Annotations", skip = skip)

  # map these fields to match those in ADATs
  map <- c(Target           = "Target Name",
           TargetFullName   = "Target Full Name",
           UniProt          = "UniProt ID",
           EntrezGeneID     = "Entrez Gene ID",
           EntrezGeneSymbol = "Entrez Gene Name")
  tbl <- dplyr::rename(tbl, !!!map)
  stopifnot(
    all(c("SeqId", "SomaId", "Target", "Type", "TargetFullName",
          "Organism", "UniProt", "Dilution", "EntrezGeneID",
          "EntrezGeneSymbol") %in% names(tbl)
       )
  )
  structure(tbl, version = ver)
}

# assumes line7 contains the version info
getAnnoVer <- function(file) {
  rev <- readxl::read_xlsx(file, sheet = "Annotations", skip = 6L, n_max = 1L,
                           col_names = c("text", "doc", "version", "date"),
                           col_types = "text")
  ver <- paste(toupper(rev$text), rev$doc, tolower(rev$version), rev$date, sep = "-")
  gsub(" +", "", ver)
}

# version dictionary of key-value pairs
# for file characteristics
ver_dict <- list(
  # dummy version; v4.0 -> v4.1
  "SL-99999999-rev99-1999-01" = list(col_serum  = "Serum Scalar v4.0 to v4.1",
                                     col_plasma = "Plasma Scalar v4.0 to v4.1"),
  # test-anno.xlsx file; v4.1 -> v4.0
  "SL-12345678-rev0-2021-01" = list(sha = "8a345fa621377d0bac40fc8c47f5579d",
                                    col_serum  = "Serum Scalar v4.1 to v4.0",
                                    col_plasma = "Plasma Scalar v4.1 to v4.0",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 1,
                                    cols = 43),
  # v4.1 -> v4.0
  "SL-00000571-rev2-2021-06" = list(sha = "5fa46834ed826eb1e8dba88698cf7a76",
                                    col_serum  = "Serum Scalar v4.1 to v4.0",
                                    col_plasma = "Plasma Scalar v4.1 to v4.0",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 7596,
                                    cols = 43),
  # v4.0 -> v4.1
  "SL-00000246-rev5-2021-06" = list(sha = "7d92666369d4e33364b11804f2d1f8ce",
                                    col_serum  = "Serum Scalar v4.0 to v4.1",
                                    col_plasma = "Plasma Scalar v4.0 to v4.1",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 5284,
                                    cols = 43)
)
