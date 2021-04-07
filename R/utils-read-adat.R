# Auxiliary internals to `read_adat()`

#' @keywords internal
#' @importFrom usethis ui_stop ui_done
#' @noRd
checkHeader <- function(header, verbose) {

  if ( !"Header.Meta" %in% names(header) ) {
    usethis::ui_stop("Could not find `Header.Meta`.")
  }

  if ( !"Col.Meta" %in% names(header) ) {
    usethis::ui_stop("No `Col.Meta` data found in adat.")
  }

  if ( !"file.specs" %in% names(header) ) {
    usethis::ui_stop(
      "No `file.specs` entry found in header ... \\
      should be added during file parsing."
    )
  }

  catchHeaderMeta(header$Header.Meta)
  catchColMeta(header$Col.Meta)
  catchFile(header$file.specs)

  if ( verbose ) {
    usethis::ui_done("Header passed checks and traps")
  }
  invisible(NULL)
}


#' @param x The Header.Meta entry of `soma_adat` attributes.
#' @keywords internal
#' @importFrom usethis ui_stop ui_warn
#' @noRd
catchHeaderMeta <- function(x) {
  if ( "ROW_DATA" %in% names(x) ) {
    if ( !"Name" %in% names(x$ROW_DATA) ) {
      usethis::ui_stop(
        "Could not find `Name` entry in `ROW_DATA` of `Header.Meta`."
      )
    }
    if ( any(duplicated(x$ROW_DATA$Name)) ) {
      usethis::ui_stop(
        "Duplicate row (clinical) meta data fields \\
        defined in header `ROW_DATA`."
      )
    }
  } else {
    usethis::ui_warn("`ROW_DATA` is mising from `Header.Meta`.")
  }
  invisible(NULL)
}


#' @param x The Col.Meta entry of `soma_adat` attributes.
#' @keywords internal
#' @importFrom usethis ui_warn
#' @noRd
catchColMeta <- function(x) {
  if ( !"SeqId" %in% names(x) ) {
    usethis::ui_warn(
      "No `SeqId` row found in Column Meta Data:
      SeqIds will be absent from adat Column Meta AND \\
      `SomaPlyr::getAptamers()` will not function properly."
    )
  }
  invisible(NULL)
}


#' @param x The `file.specs` entry of `soma_adat` attributes.
#' @keywords internal
#' @importFrom usethis ui_stop
#' @noRd
catchFile <- function(x) {
  stopifnot("EmptyAdat" %in% names(x),
            "table.begin" %in% names(x),
            "old.adat" %in% names(x))

  if ( !is.logical(x$EmptyAdat) ) {
    usethis::ui_stop(
      "The `EmptyAdat` entry of `file.specs` should be \\
      class logical: {class(x$EmptyAdat)}."
    )
  }

  if ( !is.numeric(x$table.begin) || length(x$table.begin) != 1 ) {
    usethis::ui_stop(
      "The `table.begin` entry of `file.specs` should be \\
      class numeric AND length 1: {x$table.begin}."
    )
  }

  if ( !is.logical(x$old.adat) ) {
    usethis::ui_stop(
      "The `old.adat` entry of `file.specs` should be \\
      class logical: {class(x$old.adat)}."
    )
  }

  if ( !x$EmptyAdat ) {
    stopifnot("col.meta.start" %in% names(x),
              "col.meta.shift" %in% names(x),
              "data.begin" %in% names(x))

    if ( !is.numeric(x$col.meta.start) || length(x$col.meta.start) != 1 ) {
      usethis::ui_stop(
        "The `col.meta.start` entry of `file.specs` should \\
        be class numeric AND length 1: {x$col.meta.start}"
      )
    }

    if ( !is.numeric(x$col.meta.shift) || length(x$col.meta.shift) != 1 ) {
      usethis::ui_stop(
        "The `col.meta.shift` entry of `file.specs` should \\
        be class numeric AND length 1: {x$col.meta.shift}"
      )
    }

    if ( !is.numeric(x$data.begin) || length(x$data.begin) != 1 ) {
      usethis::ui_stop(
        "The `data.begin` entry of `file.specs` should \\
        be class numeric AND length 1: {x$data.begin}"
      )
    }
  }
  invisible(NULL)
}


#' Catch for dimension mismatch prior to renaming a `soma_adat` with
#' @param x The RFU + meta data matrix. The actual data.
#' @param y The expected number of columns that `x` should have.
#' @keywords internal
#' @importFrom usethis ui_stop
#' @noRd
catchDims <- function(x, y) {
  if ( ncol(x) != y ) {
    usethis::ui_stop(
      "Number of columns in `rfu_dat` not equal to (meta + aptamers) length.
      Possible: trailing tabs OR the old/new adat version is incorrect.
      Check `1.0` vs. `1.0.0` version in the ADAT.
      This could *SERIOUSLY* affect your data.
      Please try `read_adat(x debug = TRUE)`."
    )
  }
  invisible(NULL)
}


#' Helper for the `verbose =` argument.
#' @param rfu The RFU + meta data matrix. The actual data.
#' @param header The header info from `parseHeader()`.
#' @keywords internal
#' @importFrom purrr walk
#' @importFrom utils head
#' @importFrom usethis ui_done
#' @importFrom tibble as_tibble
#' @importFrom crayon bold green red blue magenta
#' @importFrom stringr str_pad
#' @noRd
.verbosity <- function(rfu, header) {
  cli::rule(crayon::bold("Parsing Diagnostics"), line_col = crayon::blue,
            line = 2) %>%
    writeLines()
  c1 <- c(
    "Skip calculated as",
    "Adat version",
    "Table Begin",
    "Col.Meta Start",
    "Col.Meta Shift",
    "Header Row",
    "Old Adat version",
    "Length sample meta (clin)",
    "Length features (apts)",
    "Dim data matrix",
    "Dim Col Meta"
  ) %>% stringr::str_pad(25, "right")
  c2 <- c(
    header$file.specs$data.begin,
    header$Header.Meta$HEADER$Version,
    header$file.specs$table.begin,
    header$file.specs$col.meta.start,
    header$file.specs$col.meta.shift,
    header$file.specs$data.begin,
    header$file.specs$old.adat,
    getMeta(rfu, n = TRUE),
    getFeatures(rfu, n = TRUE),
    paste(dim(rfu), collapse = " x "),
    paste(dim(data.frame(header$Col.Meta)), collapse = " x ")
  ) %>% crayon::red()
  purrr::walk(paste(c1, crayon::blue(cli::symbol$pointer), c2), usethis::ui_done)
  cli::rule(crayon::bold("Head Col Meta"), line_col = crayon::magenta) %>%
    writeLines()
  print(head(tibble::as_tibble(header$Col.Meta)))
  cli::rule(crayon::bold("Head Feature Data (final 2 cols)"),
            line_col = crayon::magenta) %>%
    writeLines()
  nc <- ncol(rfu)
  print(utils::head(dplyr::select(rfu, (nc - 1):nc)))
  writeLines(cli::rule(line_col = crayon::green, line = 2))
  invisible(NULL)
}
