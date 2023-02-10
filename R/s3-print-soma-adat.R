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
  n_apts <- getAnalytes(x, n = TRUE)
  pad    <- strrep(" ", 5)
  dim_vars <- paste0(pad, .pad(c("Attributes intact", "Rows", "Columns",
                                 "Clinical Data", "Features"), 20))
  dim_vals <- c(col_f(atts_symbol), nrow(x), ncol(x), length(meta), n_apts) |>
    as.character() |>
    cr_cyan()
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
