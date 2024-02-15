#' S3 Print
#'
#' The S3 [print()] method returns summary information parsed from the object
#' attributes, if present, followed by a dispatch to the [tibble()] print method.
#' Rownames are printed as the first column in the print method only.
#'
#' @rdname soma_adat
#' @order 2
#' @param show_header Logical. Should all the `Header Data` information
#'   be displayed instead of the data frame (`tibble`) object?
#' @examples
#' # S3 print method
#' example_data
#'
#' # show the header info (no RFU data)
#' print(example_data, show_header = TRUE)
#'
#' @export
print.soma_adat <- function(x, show_header = FALSE, ...) {

  writeLines(cli_rule(cr_bold("SomaScan Data"), line = 2, line_col = "blue"))
  attsTRUE    <- is_intact_attr(x, verbose = FALSE)
  col_f       <- if ( attsTRUE ) cr_green else cr_red
  atts_symbol <- if ( attsTRUE ) symb_tick else symb_cross
  meta   <- getMeta(x)
  ver    <- getSomaScanVersion(x) %||% "unknown"
  ver    <- sprintf("%s (%s)", ver, slug_version(ver))
  signal <- slug_version(getSignalSpace(x))
  n_apts <- getAnalytes(x, n = TRUE)
  pad    <- strrep(" ", 5L)
  dim_vars <- c("SomaScan version", "Signal Space", "Attributes intact", "Rows",
                "Columns", "Clinical Data", "Features")
  dim_vals <- c(ver, signal, col_f(atts_symbol), nrow(x), ncol(x),
                length(meta), n_apts)
  if ( inherits(x, "grouped_df") && !is.null(attr(x, "groups")) ) {
    dim_vars <- c(dim_vars, "Groups")
    group_data <- attr(x, "groups")
    dim_vals <- c(dim_vals,
                  sprintf("%s [%s]",
                          paste0(setdiff(names(group_data), ".rows"),
                                 collapse = ", "),
                          nrow(group_data)
                  ))
  }
  dim_vars <- paste0(pad, .pad(dim_vars, 20L))
  dim_vals <- cr_cyan(dim_vals)
  writeLines(paste(dim_vars, dim_vals))

  if ( attsTRUE ) {
    # Column Meta Data
    writeLines(cli_rule(cr_bold("Column Meta"), line_col = "magenta"))
    nms <- names(x %@@% "Col.Meta")
    nms <- paste(nms, collapse = ", ")
    str <- strwrap(nms, width = getOption("width"),
                   prefix = paste0(cr_cyan(symb_info), " "))
    writeLines(str)

    # show header data only
    if ( show_header ) {
      # Header Meta Data
      writeLines(cli_rule(cr_bold("Header Data"), line_col = "magenta"))
      notempty <- function(x) length(x) != 0L
      filtered <- Filter(notempty, (x %@@% "Header.Meta")$HEADER)
      print(tibble::enframe(unlist(filtered), name = "Key", value = "Value"), n = 15)
    }

  } else {
    writeLines(cli_rule(cr_bold("Header Data"), line_col = "magenta"))
    paste(paste0(pad, .pad("No Header.Meta", 20)),
          cr_yellow(symb_warn),
          cr_red("ADAT columns were probably modified"),
          cr_yellow(symb_warn)
      ) |>
      writeLines()
  }

  if ( !show_header ) {
    # this is the default behavior
    writeLines(cli_rule(cr_bold("Tibble"), line_col = "magenta"))
    print(
      tibble::as_tibble(x, rownames = ifelse(has_rn(x), "row_names", NA)),
      max_extra_cols   = 10,
      max_footer_lines = 6
    )
  }

  writeLines(cli_rule(line = 2, line_col = "green"))
  invisible(x)
}

# map internal version to
# external commercial name
slug_version <- function(x) {
  ver <- x %||% "unknown"
  map_ver2k[tolower(ver)]
}
