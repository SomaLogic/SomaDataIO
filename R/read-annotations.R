#' Import a SomaLogic Annotations File
#'
#' @param file A path to an annotations file location.
#'   This is a sanctioned, versioned file provided by
#'   Standard BioTools, Inc. and should be an _unmodified_
#'   `*.xlsx` file.
#' @return A `tibble` containing analyte-specific annotations and
#'   related (e.g. lift/bridging) information, keyed on SomaLogic
#'   [SeqId], the unique SomaScan analyte identifier.
#' @examples
#' \dontrun{
#'   # for example
#'   file <- "~/Downloads/SomaScan_11K_Annotated_Content.xlsx"
#'   anno_tbl <- read_annotations(file)
#' }
#' @importFrom readxl read_xlsx
#' @importFrom tools md5sum
#' @export
read_annotations <- function(file) {

  if ( !(endsWith(file, "xlsx") || endsWith(file, "json")) ) {
    stop("Annotations file must be either ", .value("*.xlsx"),
         " or ", .value("*.json"), ".", call. = FALSE)
  }

  ver <- getAnnoVer(file)

  # cannot determine version
  if ( !grepl("^SL-[0-9]+-rev[0-9]+", ver) ) {
    stop(
      "Unable to determine annotations file version: ", .value(ver),
      ".\nA valid annotations file version is required to proceed.",
      call. = FALSE
    )
  }

  # check if recognized version
  if ( ver %in% names(ver_dict) ) {
    md5_file <- strtrim(md5sum(file), 7L) |> unname()
    md5_true <- strtrim(ver_dict[[ver]]$sha, 7L)

    # file modified
    if ( !identical(md5_file, md5_true) ) {
      warning(
        "Checksum mismatch. ", basename(file), " may have been modified.",
        call. = FALSE
      )
    }
    skip <- ver_dict[[ver]]$skip
  } else {
    warning(
      "Unknown version of the annotations file: ", ver, ".",
      call. = FALSE
    )
    skip <- 8L
  }

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
# SHA hashes are calculated with `tools::md5sum()`
ver_dict <- list(
  # The first 2 are for testing
  # dummy version; 5k -> 7k
  "SL-99999999-rev99-1999-01" = list(col_serum  = "Serum Scalar v4.0 to v4.1",
                                     col_plasma = "Plasma Scalar v4.0 to v4.1"),
  # test-anno.xlsx file; 7k -> 5k
  "SL-12345678-rev0-2021-01" = list(sha = "8a345fa621377d0bac40fc8c47f5579d",
                                    col_serum  = "Serum Scalar v4.1 to v4.0",
                                    col_plasma = "Plasma Scalar v4.1 to v4.0",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 1,
                                    cols = 43),
  # 7k -> 5k
  "SL-00000571-rev2-2021-06" = list(sha = "5fa46834ed826eb1e8dba88698cf7a76",
                                    col_serum  = "Serum Scalar v4.1 to v4.0",
                                    col_plasma = "Plasma Scalar v4.1 to v4.0",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 7605,
                                    cols = 43),
  # 5k -> 7k
  "SL-00000246-rev5-2021-06" = list(sha = "7d92666369d4e33364b11804f2d1f8ce",
                                    col_serum  = "Serum Scalar v4.0 to v4.1",
                                    col_plasma = "Plasma Scalar v4.0 to v4.1",
                                    which_serum  = 40,
                                    which_plasma = 42,
                                    skip = 8L,
                                    rows = 5293,
                                    cols = 43),

  # source 7k ----
  #   https://menu.somalogic.com
  #   SomaScan_7K_Annotated_Content.xlsx
  "SL-00000571-rev7-2024-02" = list(sha = "0cf00a6afdc1a5cf1f7b8e16cffedccc",
                                    col_serum  = c("Serum Scalar v4.1 7K to v4.0 5K",
                                                   "Serum Scalar v4.1 7K to v5.0 11K"),
                                    col_plasma = c("Plasma Scalar v4.1 7K to v4.0 5K",
                                                   "Plasma Scalar v4.1 7K to v5.0 11K"),
                                    which_serum  = c(43, 47),
                                    which_plasma = c(45, 49),
                                    skip = 8L,
                                    rows = 7605,
                                    cols = 50),
  # source 11k ----
  #   https://menu.somalogic.com
  #   SomaScan_11K_Annotated_Content.xlsx
  "SL-00000906-rev4-2024-03" = list(sha = "f4f42681780a03d2972215f355748064",
                                    col_serum  = c("Serum Scalar v5.0 11K to v4.1 7K",
                                                   "Serum Scalar v5.0 11K to v4.0 5K"),
                                    col_plasma = c("Plasma Scalar v5.0 11K to v4.1 7K",
                                                   "Plasma Scalar v5.0 11K to v4.0 5K"),
                                    which_serum  = c(43, 47),
                                    which_plasma = c(45, 49),
                                    skip = 8L,
                                    rows = 11092,
                                    cols = 51)
)
