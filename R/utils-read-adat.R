# Auxiliary internals to `read_adat()`

# certain "standard" variables are known to be a specific class
# otherwise allow read.delim() to guess type
.metaTypes <- function(x) {
  base_type <- rep_len(NA_character_, length(x))
  known_chr <- c("PlateId", "SampleId", "SampleType", "Subject_ID", "SampleMatrix")
  known_dbl <- c("SlideId", "Subarray", "HybControlNormScale")
  chr_idx   <- which(x %in% known_chr)
  dbl_idx   <- which(x %in% known_dbl)
  if ( length(chr_idx) ) base_type[chr_idx] <- "character"
  if ( length(dbl_idx) ) base_type[dbl_idx] <- "numeric"
  stopifnot(
    length(x) == length(base_type),
    is.character(base_type)
  )
  base_type
}

checkHeader <- function(header, verbose) {

  if ( !"Header.Meta" %in% names(header) ) {
    stop("Could not find `Header.Meta`.", call. = FALSE)
  }

  if ( !"Col.Meta" %in% names(header) ) {
    stop("No `Col.Meta` data found in adat.", call. = FALSE)
  }

  if ( !"file.specs" %in% names(header) ) {
    stop(
      "No `file.specs` entry found in header ... ",
      "should be added during file parsing.", call. = FALSE
    )
  }

  catchHeaderMeta(header$Header.Meta)
  catchColMeta(header$Col.Meta)
  catchFile(header$file.specs)

  if ( verbose ) {
    .done("Header passed checks and traps")
  }
  invisible(NULL)
}


#' @param x The Header.Meta entry of `soma_adat` attributes.
#' @keywords internal
#' @noRd
catchHeaderMeta <- function(x) {
  if ( "ROW_DATA" %in% names(x) ) {
    if ( !"Name" %in% names(x$ROW_DATA) ) {
      stop(
        "Could not find `Name` entry in `ROW_DATA` of `Header.Meta`.",
        call. = FALSE
      )
    }
    if ( any(duplicated(x$ROW_DATA$Name)) ) {
      stop(
        "Duplicate row (clinical) meta data fields ",
        "defined in header `ROW_DATA`.", call. = FALSE
      )
    }
  } else {
    warning("`ROW_DATA` is mising from `Header.Meta`.", call. = FALSE)
  }
  invisible(NULL)
}


#' @param x The Col.Meta entry of `soma_adat` attributes.
#' @keywords internal
#' @noRd
catchColMeta <- function(x) {
  if ( !"SeqId" %in% names(x) ) {
    warning(
      "No `SeqId` row found in Column Meta Data:\n",
      "SeqIds will be absent from adat Column Meta AND ",
      "`getAnalytes()` cannot function properly.",
      call. = FALSE
    )
  }
  invisible(NULL)
}


#' @param x The `file.specs` entry of `soma_adat` attributes.
#' @keywords internal
#' @noRd
catchFile <- function(x) {
  stopifnot(
    "EmptyAdat" %in% names(x),
    "table.begin" %in% names(x),
    "old.adat" %in% names(x)
  )

  if ( !is.logical(x$EmptyAdat) ) {
    stop(
      "The `EmptyAdat` entry of `file.specs` should be ",
      "class logical: ", .value(class(x$EmptyAdat)), ".",
      call. = FALSE
    )
  }

  if ( !is.numeric(x$table.begin) || length(x$table.begin) != 1 ) {
    stop(
      "The `table.begin` entry of `file.specs` should be ",
      "class numeric AND length 1: ", .value(x$table.begin), ".",
      call. = FALSE
    )
  }

  if ( !is.logical(x$old.adat) ) {
    stop(
      "The `old.adat` entry of `file.specs` should be ",
      "class logical: ", .value(class(x$old.adat)), ".",
      call. = FALSE
    )
  }

  if ( !x$EmptyAdat ) {
    stopifnot("col.meta.start" %in% names(x),
              "col.meta.shift" %in% names(x),
              "data.begin" %in% names(x))

    if ( !is.numeric(x$col.meta.start) || length(x$col.meta.start) != 1 ) {
      stop(
        "The `col.meta.start` entry of `file.specs` should ",
        "be class numeric AND length 1: ", .value(x$col.meta.start),
        call. = FALSE
      )
    }

    if ( !is.numeric(x$col.meta.shift) || length(x$col.meta.shift) != 1 ) {
      stop(
        "The `col.meta.shift` entry of `file.specs` should ",
        "be class numeric AND length 1: ", .value(x$col.meta.shift),
        call. = FALSE
      )
    }

    if ( !is.numeric(x$data.begin) || length(x$data.begin) != 1 ) {
      stop(
        "The `data.begin` entry of `file.specs` should ",
        "be class numeric AND length 1: ", .value(x$data.begin),
        call. = FALSE
      )
    }
  }
  invisible(NULL)
}


#' Catch for dimension mismatch prior to renaming a `soma_adat` with
#' @param x The RFU + meta data matrix. The actual data.
#' @param y The expected number of columns that `x` should have.
#' @keywords internal
#' @noRd
catchDims <- function(x, y) {
  if ( ncol(x) != y ) {
    stop(
      "Number of columns in `rfu_dat` not equal to (meta + aptamers) length.\n",
      "Possible: trailing tabs OR the old/new adat version is incorrect.\n",
      "Check `1.0` vs. `1.0.0` version in the ADAT.\n",
      "This could *SERIOUSLY* affect your data.\n",
      "Please try `read_adat(x debug = TRUE)`.",
      call. = FALSE
    )
  }
  invisible(NULL)
}


#' Helper for the 'verbose =' argument.
#' @param rfu The RFU + meta data matrix. The actual data.
#' @param header The header info from parseHeader().
#' @importFrom utils head
#' @keywords internal
#' @noRd
.verbosity <- function(rfu, header) {
  writeLines(
    cli_rule(cr_bold("Parsing Diagnostics"), line_col = "blue", line = 2)
  )
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
  ) %>% .pad(25)
  c2 <- c(
    header$file.specs$data.begin,
    header$Header.Meta$HEADER$Version,
    header$file.specs$table.begin,
    header$file.specs$col.meta.start,
    header$file.specs$col.meta.shift,
    header$file.specs$data.begin,
    header$file.specs$old.adat,
    getMeta(rfu, n = TRUE),
    getAnalytes(rfu, n = TRUE),
    paste(dim(rfu), collapse = " x "),
    paste(dim(data.frame(header$Col.Meta)), collapse = " x ")
  ) %>% cr_red()
  lapply(paste(c1, cr_blue(symb_point), c2), .done)
  writeLines(
    cli_rule(cr_bold("Head Col Meta"), line_col = "magenta")
  )
  print(head(tibble::as_tibble(header$Col.Meta)))
  writeLines(
    cli_rule(cr_bold("Head Feature Data (final 2 cols)"), line_col = "magenta")
  )
  nc <- ncol(rfu)
  print(head(dplyr::select(rfu, (nc - 1):nc)))
  writeLines(cli_rule(line_col = "green", line = 2))
  invisible(NULL)
}
