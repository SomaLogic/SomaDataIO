#' Write an ADAT to File
#'
#' One can write an existing modified internal ADAT
#' (`soma_adat` R object) to an external file.
#' However the ADAT object itself *must* have intact
#' attributes, see [is_intact_attr()].
#'
#' The ADAT specification *no longer* requires Windows
#' end of line (EOL) characters (\verb{"\r\n"}).
#' The current EOL spec is \verb{"\n"} which is commonly used in POSIX systems,
#' like MacOS and Linux.
#' Since the EOL affects the resulting checksum, ADATs written on
#' other systems generate slightly differing files.
#' Standardizing to \verb{"\n"} attempts to solve this issue.
#' For reference, see the EOL encoding for operating systems below:\cr
#' \tabular{llc}{
#'   Symbol \tab Platform    \tab Character \cr
#'   LF     \tab Linux       \tab \verb{"\n"} \cr
#'   CR     \tab MacOS       \tab \verb{"\r"} \cr
#'   CRLF   \tab DOS/Windows \tab \verb{"\r\n"}
#' }
#'
#' @family IO
#' @param x An object of class `soma_adat`.
#'   Both [is.soma_adat()] and [is_intact_attr()] must be `TRUE`.
#' @param file Character. File path where the object should be written.
#'   For example, extensions should be `*.adat`.
#' @return Invisibly returns the input `x`.
#' @author Stu Field
#' @examples
#' # trim to 1 sample for speed
#' adat_out <- head(example_data, 1L)
#'
#' # attributes must(!) be intact to write
#' is_intact_attr(adat_out)
#'
#' write_adat(adat_out, file = tempfile(fileext = ".adat"))
#' @importFrom utils write.table
#' @seealso [read_adat()], [is_intact_attr()]
#' @export
write_adat <- function(x, file) {

  stopifnot(inherits(x, "soma_adat"))

  if ( missing(file) ) {
    stop("Must provide output file name ...", call. = FALSE)
  }

  if ( !grepl("\\.adat$", file) ) {
    warning(
      "File extension is not `*.adat` (", .value(file), "). ",
      "Are you sure this is the correct file extension?",
      call. = FALSE
    )
  }

  apts <- getAnalytes(x)
  atts <- prepHeaderMeta(x)
  attributes(x) <- atts

  # checks and traps
  .checkADAT(x)

  # remove FEATURE_EXTRACTION & Checksum
  header_keep <- grep("Checksum|FEATURE_EXTRACTION",
                      names(atts$Header.Meta), invert = TRUE,
                      ignore.case = TRUE, value = TRUE)
  atts$Header.Meta <- atts$Header.Meta[header_keep]

  # open connection; overwrite in text mode
  f <- file(file, open = "w")
  on.exit(close(f), add = TRUE, after = FALSE)

  .flatten <- function(.x) {
    paste0(names(.x), "\t", vapply(.x, paste, collapse = "\t", ""))
  }

  HM <- atts$Header.Meta

  # write Header.Meta
  writeLines(
    c("^HEADER",
      .flatten(HM$HEADER),
      "^COL_DATA",
      .flatten(HM$COL_DATA),
      "^ROW_DATA",
      .flatten(HM$ROW_DATA),
      "^TABLE_BEGIN"),
    con = f
  )

  # write Col.Meta
  n_meta   <- getMeta(x, n = TRUE)
  tabshift <- strrep("\t", n_meta)  # col shift
  int_v    <- which(vapply(atts$Col.Meta, is.numeric, NA))
  # necessary to maintain signif. digits on conversion to char
  .fix_digits <- function(.x) trimws(format(.x, digits = 10))
  for ( i in int_v ) atts$Col.Meta[[i]] <- .fix_digits(atts$Col.Meta[[i]])
  writeLines(paste0(tabshift, .flatten(atts$Col.Meta)), con = f)

  # Write out header row
  # Skip rest if "Empty ADAT"
  if ( nrow(x) > 0L ) {
    if ( n_meta < 1L ) {
      warning(
        "\nYou are writing an ADAT without any meta data.\n",
        "This may cause this file (", .value(file), ") ",
        "to be unreadable via `read_adat()`.\n",
        "Suggest including at least one column of meta data (e.g. 'sample_id').",
        call. = FALSE
      )
    }

    tabs <- strrep("\t", length(apts))
    meta_names <- getMeta(x)
    metanames  <- paste(meta_names, collapse = "\t")
    writeLines(paste0(metanames, "\t", tabs), con = f)

    # insert blank column
    df <- x
    df$blank_col <- NA_character_
    df <- df[, c(meta_names, "blank_col", apts)]

    # write meta & feature data to file
    df[, apts] <- apply(df[, apts], 2, function(.x) sprintf("%0.1f", .x))

    write.table(x = df, file = f, na = "", sep = "\t", append = TRUE,
                row.names = FALSE, col.names = FALSE, eol = "\n",
                quote = FALSE, fileEncoding = "UTF-8")
  }
  .done("ADAT written to: {.value(file)}")
  invisible(x)
}


# Check ADAT prior to Writing
# @param adat A `soma_adat` class object.
.checkADAT <- function(adat) {
  atts <- attributes(adat)
  apts <- getAnalytes(adat)
  meta <- getMeta(adat)
  idx  <- grep("Name", names(atts$Header.Meta$ROW_DATA), ignore.case = TRUE)
  stopifnot(length(idx) == 1L)
  if ( !isTRUE(all.equal(cleanNames(meta),
                         cleanNames(atts$Header.Meta$ROW_DATA[[idx]]))) ) {
    stop(
      "Meta data mismatch between `Header Meta` and ADAT meta data. ",
      "Check `attributes(ADAT)$Header.Meta$ROW_DATA$Name`.", call. = FALSE
    )
  }
  if ( length(apts) != nrow(atts$Col.Meta) ) {
    stop(
      "Number of RFU features in ADAT does not match No. analytes in Col.Meta!",
      call. = FALSE
    )
  }
  if ( setequal(getSeqId(apts), atts$Col.Meta$SeqId) &&     # set equal
       !identical(getSeqId(apts), atts$Col.Meta$SeqId) ) {  # but not identical
    stop(
      "ADAT features are out of sync with rows in Col.Meta!\n",
      "You may need to run `syncColMeta()` to re-sync the Col.Meta, ",
      "then try again.", call. = FALSE
    )
  }
  if ( nrow(adat) == 0L ) {
    warning(
      "ADAT has no rows! Writing just header and column meta data.",
      call. = FALSE
    )
  }
  .done("ADAT passed all checks and traps.")
  invisible(NULL)
}
