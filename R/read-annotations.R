#' Import a SomaLogic Annotations File
#'
#' @param file A path to an annotations file location. This is a sanctioned,
#' versioned file provided by SomaLogic, Inc. and should be an unmodified
#' `*.xlsx` file.
#' @return A `tibble` containing analyte-specific annotations and
#' related information (e.g. lift/scale information), keyed on SomaLogic
#' `"SeqId"` which is a unique analyte identifier.
#' @examples
#' \dontrun{
#' anno <- read_annotations("~/Desktop/SomaScan_V4.1_7K_Annotated_Content_20210616.xlsx")
#' }
#' @export
read_annotations <- function(file) {

  ext <- gsub("(.*)[.]([^.]+)$", "\\2", file)
  stopifnot(ext %in% c("xlsx", "json"))

  sha <- unname(tools::md5sum(file))
  ver <- getAnnoVer(file)

  if ( !grepl("^SL-[0-9]+-rev[0-9]+", ver) ) {
    stop(
      "Unable to determine annotations file version: ", value(ver),
      ".\nA valid annotations file version is required to proceed.",
      call. = FALSE
    )
  }

  if ( !ver %in% names(ver_dict) ) {
    stop(
      "Unknown version of the annotations file: ", value(ver), ".",
      call. = FALSE
    )
  }

  if ( sha != ver_dict[[ver]]$sha ) {
    usethis::ui_warn(
      "The md5 checksum for {value(file)} does not match its expected value.
      File version: {value(ver)}
      File md5:     {value(sha)}
      Expected md5: {value(ver_dict[[ver]]$sha)}
      It is possible the file has been modified."
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
  structure(tbl, version = ver, md5sha = sha)
}

# assumes line7 contains the version info
getAnnoVer <- function(file) {
  rev <- readxl::read_xlsx(file, sheet = "Annotations", skip = 6L, n_max = 1L,
                           col_names = c("text", "doc", "version", "date"),
                           col_types = "text")
  ver <- paste(toupper(rev$text), rev$doc, tolower(rev$version), rev$date, sep = "-")
  gsub(" +", "", ver)
}

# version dictionary of md5-sha key-value pairs
# 'correct' md5 checksums, skip, etc.
ver_dict <- list(
  # test-anno.xlsx file
  "SL-12345678-rev0-2021-01" = list(sha  = "8a345fa621377d0bac40fc8c47f5579d",
                                    skip = 8L,
                                    rows = 1,
                                    cols = 43),
  "SL-00000571-rev2-2021-06" = list(sha  = "5fa46834ed826eb1e8dba88698cf7a76",
                                    skip = 8L,
                                    rows = 7596,
                                    cols = 43)
)
