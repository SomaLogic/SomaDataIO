#' Read (Load) SomaLogic ADATs
#'
#' The parse and load a `*.adat` file as a `data.frame`-like object into
#' an R workspace environment. The class of the returned object is
#' a `soma_adat` object.
#'
#' @family IO
#' @param file Character. The elaborated path and file name of the `*.adat`
#'   file to be loaded into an R workspace.
#' @param debug Logical. Used for debugging and development of an ADAT that
#'   fails to load, particularly out-of-spec, poorly modified, or legacy ADATs.
#' @param verbose Logical. Should the function call be run in *verbose*
#'   mode, printing relevant diagnostic call information to the console.
#' @param ... Additional arguments passed ultimately to
#'   [read.delim()], or additional arguments passed to either
#'   other S3 print or summary methods as required by those generics.
#' @return A `data.frame`-like object of class `soma_adat`
#'   consisting of SomaLogic RFU (feature) data and clinical meta data as
#'   columns, and samples as rows. Row names are labeled with the unique ID
#'   "SlideId_Subarray" concatenation. The sections of the ADAT header (e.g.,
#'   "Header.Meta", "Col.Meta", ...) are stored as attributes (e.g.
#'   `attributes(x)$Header.Meta`).
#' @author Stu Field
#' @seealso [read.delim()]
#' @examples
#' f <- system.file("extdata", "example_data10.adat",
#'                  package = "SomaDataIO", mustWork = TRUE)
#' my_adat <- read_adat(f)
#'
#' is.soma_adat(my_adat)
#' @importFrom stats setNames
#' @importFrom utils read.delim
#' @export
read_adat <- function(file, debug = FALSE, verbose = getOption("verbose"), ...) {

  stopifnot(file.exists(path.expand(file)))

  # Debugger mode ----
  # nocov start
  if ( debug ) {
    res <- .getHeaderLines(file) |>
      strsplit("\t", fixed = TRUE) |>
      parseCheck()
    return(invisible(res))
  }
  # nocov end

  # Parse Header ----
  header_data <- parseHeader(file)

  # Checks & Traps ----
  checkHeader(header_data, verbose = verbose)

  if ( header_data$file_specs$empty_adat ) {
    warning(
      "No RFU feature data in ADAT. Returning a `tibble` object ",
      "with Column Meta data only.", call. = FALSE
    )
    anno_table <- convertColMeta(header_data$Col.Meta) |>
      addAttributes(header_data$Header.Meta)
    return(anno_table)
  }

  row_meta <- header_data$row_meta

  # catch for old adats with SeqIds in mystery row
  if ( length(row_meta) > header_data$file_specs$col_meta_shift ) {
    row_meta <- head(row_meta, header_data$file_specs$col_meta_shift - 1) # nocov
  }

  # zap leading/trailing whitespace
  row_meta <- trimws(row_meta)

  if ( !header_data$file_specs$old_adat ) {
    row_meta <- c(row_meta, "blank_col")  # Add empty column name in >= v1.0
  }

  apt_names <- getSeqId(header_data$Col.Meta$SeqId, trim.version = TRUE) |>
    seqid2apt()

  ncols <- length(row_meta) + length(apt_names)

  # Data ingest type spec ----
  # specify RFU data as type numeric
  # certain 'row_meta' types are specified; allow guessing (NA) on rest
  types_meta <- .metaTypes(row_meta)                  # spec type for meta
  types_rfu  <- rep_len("numeric", length(apt_names)) # spec column type

  rfu_dat <- read.delim(
    file, sep = "\t",
    header = FALSE, row.names = NULL,         # no header or rnms (set below)
    skip = header_data$file_specs$data_begin, # skip header
    colClasses = c(types_meta, types_rfu),    # spec column types
    na.strings = c("", ".", "NA"),  # these values will be NAs
    comment.char = "",              # ignore possible comments in file
    check.names = FALSE,            # don't fix tbl names (set below)
    as.is = TRUE,                   # do not convert chr -> fct
    encoding = "UTF-8", ...         # assume UTF-8 encoding
  )

  # Catch dimension issues ----
  catchDims(rfu_dat, ncols)

  # trim possible trailing tabs in rfu_dat table & rename
  rfu_dat <- setNames(rfu_dat[, 1:ncols], c(row_meta, apt_names))

  # remove ghost column if NOT old adat
  if ( "blank_col" %in% names(rfu_dat) ) {
    rfu_dat <- rfu_dat[, which(names(rfu_dat) != "blank_col")]
  }

  if ( verbose ) {
    .verbosity(rfu_dat, header_data)
  }

  # Create `soma_adat` ----
  structure(rfu_dat,
            row.names   = genRowNames(rfu_dat),
            Header.Meta = header_data$Header.Meta,
            Col.Meta    = convertColMeta(header_data$Col.Meta),
            file_specs  = header_data$file_specs,
            row_meta    = header_data$row_meta,
            class       = c("soma_adat", "data.frame")
            )   # one day a tibble?
}

#' Alias to `read.adat`
#'
#' [read.adat()] is a convenient backward compatibility alias for
#' [read_adat()] to enable use of older versions of `SomaDataIO`. It will likely
#' never go away completely, but you strongly encouraged to shift your code
#' to use [read_adat()].
#'
#' @rdname read_adat
#' @importFrom lifecycle deprecate_soft
#' @export
read.adat <- function(file, debug = FALSE, verbose = getOption("verbose"), ...) {
  deprecate_soft("6.0.0", "SomaDataIO::read.adat()", "SomaDataIO::read_adat()")
  read_adat(file, debug, verbose, ...)
}

#' Test for Object type "soma_adat"
#'
#' [is.soma_adat()] checks whether an object is of class `soma_adat`.
#' See [inherits()].
#'
#' @rdname read_adat
#' @param x An `R` object to test.
#' @return Logical. Whether `x` inherits from class `soma_adat`.
#' @export
is.soma_adat <- function(x) inherits(x, "soma_adat")
