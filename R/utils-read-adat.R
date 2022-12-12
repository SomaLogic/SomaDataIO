# Auxiliary internals to `read_adat()`

# certain "standard" variables are known to be a specific class
# otherwise allow read.delim() to guess type
.metaTypes <- function(x) {
  base_type <- rep_len(NA_character_, length(x))
  known_chr <- c("PlateId", "SampleId", "SampleType", "Subject_ID",
                 "SampleMatrix", "Barcode2d")
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

  if ( !"file_specs" %in% names(header) ) {
    stop(
      "No `file_specs` entry found in header ... ",
      "should be added during file parsing.", call. = FALSE
    )
  }

  catchHeaderMeta(header$Header.Meta)
  catchColMeta(header$Col.Meta)
  catchFile(header$file_specs)

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


#' @param x The `file_specs` entry of `soma_adat` attributes.
#' @keywords internal
#' @noRd
catchFile <- function(x) {
  stopifnot(
    "empty_adat" %in% names(x),
    "table_begin" %in% names(x),
    "old_adat" %in% names(x)
  )

  if ( !is.logical(x$empty_adat) ) {
    stop(
      "The `empty_adat` entry of `file_specs` should be ",
      "class logical: ", .value(class(x$empty_adat)), ".",
      call. = FALSE
    )
  }

  if ( !is.numeric(x$table_begin) || length(x$table_begin) != 1L ) {
    stop(
      "The `table_begin` entry of `file_specs` should be ",
      "class numeric AND length 1: ", .value(x$table_begin), ".",
      call. = FALSE
    )
  }

  if ( !is.logical(x$old_adat) ) {
    stop(
      "The `old_adat` entry of `file_specs` should be ",
      "class logical: ", .value(class(x$old_adat)), ".",
      call. = FALSE
    )
  }

  if ( !x$empty_adat ) {
    stopifnot("col_meta_start" %in% names(x),
              "col_meta_shift" %in% names(x),
              "data_begin" %in% names(x))

    if ( !is.numeric(x$col_meta_start) || length(x$col_meta_start) != 1L ) {
      stop(
        "The `col_meta_start` entry of `file_specs` should ",
        "be class numeric AND length 1: ", .value(x$col_meta_start),
        call. = FALSE
      )
    }

    if ( !is.numeric(x$col_meta_shift) || length(x$col_meta_shift) != 1L ) {
      stop(
        "The `col_meta_shift` entry of `file_specs` should ",
        "be class numeric AND length 1: ", .value(x$col_meta_shift),
        call. = FALSE
      )
    }

    if ( !is.numeric(x$data_begin) || length(x$data_begin) != 1L ) {
      stop(
        "The `data_begin` entry of `file_specs` should ",
        "be class numeric AND length 1: ", .value(x$data_begin),
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
#' @param header The header info from [parseHeader()].
#' @importFrom utils head
#' @importFrom tibble as_tibble
#' @keywords internal
#' @noRd
.verbosity <- function(rfu, header) {
  writeLines(
    cli_rule(cr_bold("Parsing Diagnostics"), line_col = "blue", line = 2)
  )
  c1 <- c(
    "ADAT version",
    "Header skip",
    "Table begin",
    "Col.Meta start",
    "Col.Meta shift",
    "Is old ADAT",
    "no. clinical variables",
    "no. RFU variables",
    "Dim data matrix",
    "Dim Col.Meta (annot.)"
  ) |> .pad(25)
  c2 <- c(
    header$Header.Meta$HEADER$Version,
    header$file_specs$data_begin,
    header$file_specs$table_begin,
    header$file_specs$col_meta_start,
    header$file_specs$col_meta_shift,
    header$file_specs$old_adat,
    getMeta(rfu, n = TRUE),
    getAnalytes(rfu, n = TRUE),
    paste(dim(rfu), collapse = " x "),
    paste(dim(data.frame(header$Col.Meta)), collapse = " x ")
  ) |> cr_red()
  lapply(paste(c1, cr_blue(symb_point), c2), .done)
  writeLines(
    cli_rule(cr_bold("Head Col Meta"), line_col = "magenta")
  )
  print(head(as_tibble(header$Col.Meta)))
  writeLines(
    cli_rule(cr_bold("Trailing 2 RFU features"), line_col = "magenta")
  )
  nc <- ncol(rfu)
  print(rfu[1:6, (nc - 1):nc])
  writeLines(cli_rule(line_col = "green", line = 2))
  invisible(NULL)
}
