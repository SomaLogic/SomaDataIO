
#' S3 Print
#'
#' S3 [print()] method returns summary information parsed from the object
#' attributes, if present, followed by a dispatch to the [tibble()] print method.
#' Rownames are printed as the first column in the print method only.
#'
#' @rdname soma_adat
#' @order 2
#' @param show_header Logical. Should all the `Header Data` information
#' be displayed instead of the data frame (`tibble`) object?
#' @examples
#' my_adat <- system.file("example", "example_data.adat",
#'                        package = "SomaDataIO", mustWork = TRUE) %>% read_adat()
#' # S3 print method
#' my_adat
#'
#' @export
print.soma_adat <- function(x, show_header = FALSE, ...) {

  writeLines(cli_rule(cr_bold("SomaScan Data"), line = 2, line_col = "blue"))
  attsTRUE    <- is.intact.attributes(x, verbose = FALSE)
  col_f       <- if ( attsTRUE ) cr_green else cr_red       # nolint
  atts_symbol <- if ( attsTRUE ) symb_tick else symb_cross  # nolint
  meta   <- getMeta(x)
  n_apts <- getAnalytes(x, n = TRUE)
  pad    <- strrep(" ", 5)
  dim_vars <- .pad(c("Attributes intact", "Rows", "Columns",
                     "Clinical Data", "Features"), 20) %>%
    paste0(pad, .)
  dim_vals <- c(col_f(atts_symbol), nrow(x), ncol(x), length(meta), n_apts) %>%
    as.character() %>%
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
      notempty <- function(x) length(x) != 0
      A <- Filter(notempty, (x %@@% "Header.Meta")$HEADER)
      print(tibble::enframe(unlist(A), name = "Key", value = "Value"), n = 15)
    }

  } else {
    writeLines(cli_rule(cr_bold("Header Data"), line_col = "magenta"))
    paste(paste0(pad, .pad("No Header.Meta", 20)),
          cr_yellow(symb_warn),
          cr_red("ADAT columns were probably modified"),
          cr_yellow(symb_warn)
      ) %>%
      writeLines()
  }

  if ( !show_header ) {
    # this is the default behavior
    writeLines(cli_rule(cr_bold("Tibble"), line_col = "magenta"))
    print(
      tibble::as_tibble(x, rownames = ifelse(has_rn(x), "row_names", NA)),
      n_extra = 15            # soft deprecated
#     max_extra_cols   = 10,  # next version of tibble
#     max_footer_lines = 10   # next version of tibble
    )
  }

  writeLines(cli_rule(line = 2, line_col = "green"))
  invisible(x)
}
