#' Write an ADAT to File
#'
#' One can write an existing modified internal ADAT
#' (`soma_adat` R object) to an external file.
#' However the ADAT object itself *must* have intact
#' attributes, see [is.intact.attributes()].
#'
#' The ADAT specification *no longer* requires Windows
#' end of line (EOL) characters (\verb{"\r\n"}).
#' The EOL is currently \verb{"\n"} which is commonly used in POSIX systems,
#' like MacOS and Linux.
#' The EOL affects the format of the resulting file, particularly
#' calculating a checksum (if desired). ADATs written via other systems may
#' result in differing EOLs (and thus checksum). EOL encoding for operating
#' systems is below:\cr
#' \tabular{llc}{
#'   Symbol \tab Platform    \tab Character \cr
#'   LF     \tab Linux       \tab \verb{"\n"} \cr
#'   CR     \tab MacOS       \tab \verb{"\r"} \cr
#'   CRLF   \tab DOS/Windows \tab \verb{"\r\n"}
#' }
#'
#' @family IO
#' @param x An object of class `soma_adat`. Both [is.soma_adat()] and
#' [is.intact.attributes()] must be `TRUE`.
#' @param file Character. File path where the object should be written.
#' For example, extensions should be `*.adat`.
#' @author Stu Field
#' @importFrom usethis ui_stop ui_warn ui_done ui_path
#' @importFrom purrr walk
#' @importFrom dplyr mutate select
#' @importFrom readr write_tsv write_lines
#' @importFrom stringr str_detect
#' @seealso [read_adat()], [write_tsv()], [is.intact.attributes()].
#' @export
write_adat <- function(x, file) {

  if ( missing(file) ) {
    usethis::ui_stop("Must provide output file name ...")
  }

  if ( !stringr::str_detect(file, "\\.adat$") ) {
    usethis::ui_warn(
      "File extension is not `*.adat` ('{file}'). \\
      Are you sure this is the correct file extension?"
    )
  }

  data <- prepWriteADAT(x)
  apts <- get_features(names(x))
  atts <- attributes(data)

  # remove FEATURE_EXTRACTION & recalculate Checksum
  header_keep      <- setdiff(names(atts$Header.Meta),
                              c("Checksum", "FEATURE_EXTRACTION"))
  atts$Header.Meta <- atts$Header.Meta[ header_keep ]

  # open connection
  f  <- file(file, open = "wb")
  HM <- atts$Header.Meta      # Header Meta; rename for convenience

  purrr::walk(names(HM), function(i) {
    readr::write_lines(paste0("^", i), path = f, append = TRUE)
    purrr::walk(names(HM[[i]]), function(h)
      paste0("!", h, "\t", paste0(HM[[i]][[h]], collapse = "\t")) %>%
        readr::write_lines(path = f, append = TRUE))
  })

  # write Col Meta
  meta_names  <- setdiff(names(data), apts)  # get meta data names for use below
  length_meta <- length(meta_names)

  purrr::walk(names(atts$Col.Meta), function(.x) {
    paste0(stringr::str_dup("\t", length_meta),    # col shift
           .x, "\t",                               # name
           paste(atts$Col.Meta[[.x]], collapse = "\t")  # Col.Meta
          ) %>%
          readr::write_lines(path = f, append = TRUE)
  })

  # Write out header row
  # Skip rest if Adat is empty
  if ( nrow(data) != 0 ) {

    if ( length_meta < 1 ) {
      usethis::ui_warn("
        You are writing an ADAT without any meta data
        This will likely cause this file ({file}) to \\
        be unreadable using `read_adat()`
        Suggest including at least one column of meta data."
      )
    }

    tabs      <- stringr::str_dup("\t", length(apts) - 1)
    metanames <- paste(meta_names, collapse = "\t")

    readr::write_lines(paste(metanames, "\t\t", tabs), path = f, append = TRUE)

    df <- data %>%
      dplyr::mutate(blank_col = NA_character_) %>%   # add mystery column
      dplyr::select(meta_names, blank_col, dplyr::everything())

    # write meta & feature data to file
    df[, apts] <- apply(df[, apts], 2, function(.x) sprintf("%0.1f", .x))

    # change 4000 -> 4e3 scientific mode; SampleUniqueID
    readr::write_tsv(x = df, path = f, na = "", append = TRUE)
  }

  close(f)
  usethis::ui_done("ADAT written to: {usethis::ui_path(file)}")
  invisible(x)
}

