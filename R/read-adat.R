#' Read (Load) SomaLogic ADATs
#'
#' The parse and load a `*.adat` file as a `data.frame`-like object into
#' an R workspace environment. The class of the returned object is
#' a `soma_adat` object.
#'
#' @family IO
#' @order 1
#' @param file Character. The elaborated path and file name of the `*.adat`
#' file to be loaded into an R workspace.
#' @param debug Logical. Used for debugging and development of an ADAT that
#' fails to load, particularly out-of-spec, poorly modified, or legacy ADATs.
#' @param verbose Logical. Should the function call be run in *verbose*
#' mode, printing relevant diagnostic call information to the console. Defaults
#' to the global variable defined in [getOption()].
#' @param ... Additional arguments passed ultimately to
#' [read_delim()], or  additional arguments passed to either
#' other S3 print or summary methods as required by those generics.
#' @return A `data.frame`-like object of class `soma_adat`
#' consisting of SomaLogic RFU (feature) data and clinical meta data as
#' columns, and samples as rows. Row names are labeled with the unique ID
#' "SlideId_Subarray" concatenation. The sections of the ADAT header (e.g.,
#' "Header.Meta", "Col.Meta", ...) are stored as attributes (e.g.
#' `attributes(x)$Header.Meta`).
#' @author Stu Field
#' @seealso [read_delim()]
#' @examples
#' f <- system.file("example", "example_data.adat", package = "SomaDataIO",
#'                  mustWork = TRUE)
#' my_adat <- read_adat(f)
#' is.soma_adat(my_adat)
#'
#' # S3 print method
#' my_adat                             # redirect uses `tibble` method
#' print(my_adat, show_header = TRUE)  # show the header info; no RFU data
#'
#' # S3 write method
#' fout <- tempfile(fileext = ".adat")
#' write_adat(my_adat, file = fout)
#'
#' # read same file back in as check
#' read_adat(fout)
#'
#' @importFrom utils head
#' @importFrom usethis ui_warn ui_done
#' @importFrom stringr str_split str_replace str_trim
#' @importFrom readr read_delim read_lines cols
#' @export read_adat
read_adat <- function(file, debug = FALSE, verbose = getOption("verbose"), ...) {

  stopifnot(file.exists(path.expand(file)))

  # Debugger mode ----
  # nocov start
  if ( debug ) {
    parse_out <- file %>%
      readr::read_lines(n_max = 200) %>%
      stringr::str_split("\t") %>%
      parseCheck()
      return(parse_out)
  }
  # nocov end

  # Parse Header ----
  header_data <- parseHeader(file)

  # Checks & Traps ----
  checkHeader(header_data, verbose = verbose)

  # nocov start
  if ( header_data$file.specs$EmptyAdat ) {
    usethis::ui_warn(
      "No RFU feature data in ADAT. Returning a `tibble` object with \\
      Column Meta data only."
    )
    apt_table <- convertColMeta(header_data$Col.Meta) %>%
      addAttributes(header_data$Header.Meta)
    return(apt_table)
  }
  # nocov end

  row_meta <- header_data$row.meta

  # catch for old adats with SeqIds in mystery row
  if ( length(row_meta) > header_data$file.specs$col.meta.shift ) {
    row_meta %<>% utils::head(header_data$file.specs$col.meta.shift - 1)   # nocov
  }

  # zap trailing spaces, double/leading dots, non-alphanum
  row_meta %<>% stringr::str_trim()

  if ( !header_data$file.specs$old.adat ) {
    row_meta <- c(row_meta, "blank_col")  # Add empty column name in >= v1.0: sgf
  }

  apt_names <- header_data$Col.Meta$SeqId %>%
    getSeqId(trim.version = TRUE) %>%   # old adats may have a version #
    stringr::str_replace("-", ".") %>%  # convert "-"  -> "."
    paste0("seq.", .)                   # combine to form AptName

  ncols <- length(row_meta) + length(apt_names)

  # Data ingest ----
  # Read in the raw data as tab delimited
  rfu_dat <- readr::read_delim(
    file, delim    = "\t",
    col_types      = readr::cols(), # no col spec msg
    progress       = FALSE,         # suppress progress bar
    # escape_double = FALSE,
    skip           = header_data$file.specs$data.begin,
    col_names      = FALSE,
    ...
  )

  # Catch dimension issues ----
  catchDims(rfu_dat, ncols)

  # Select and add names
  rfu_dat <- rfu_dat %>%
    dplyr::select(1:ncols) %>%  # trim possible trailing tabs in rfu_dat table
    purrr::set_names(c(row_meta, apt_names))

  # remove ghost column if NOT old adat
  if ( "blank_col" %in% names(rfu_dat) ) {
    rfu_dat %<>% dplyr::select(which(names(.) != "blank_col"))
  }

  if ( verbose ) {
    .verbosity(rfu_dat, header_data)
  }

  # reorder atts here to keep with default data.frame class order
  attributes(rfu_dat) <- attributes(rfu_dat)[c("names", "class",
                                               "row.names", "spec")]
  # Create `soma_adat` ----
  structure(rfu_dat,
            row.names   = genRowNames(rfu_dat),
            Header.Meta = header_data$Header.Meta,
            Col.Meta    = convertColMeta(header_data$Col.Meta),
            file.specs  = header_data$file.specs,
            row.meta    = header_data$row.meta,
            class       = c("soma_adat", "data.frame")
            )   # one day a tibble?
}


#' Test for Object type "soma_adat"
#'
#' [is.soma_adat()] checks whether an object is of class `soma_adat`.
#' See [inherits()].
#' @rdname read_adat
#' @order 2
#' @return A logical indicating whether `x` inherits from class `soma_adat`.
#' @export is.soma_adat
is.soma_adat <- function(x) inherits(x, "soma_adat")
