# Print ----

#' @describeIn read_adat
#' The S3 generic print method (`print`) returns summary information
#' parsed from the object attributes, if possible (see examples), followed
#' by a dispatch to the `tibble` print method.
#'
#' @param x A `soma_adat` class object to [print()].
#' @param show_header Logical. Should all the `Header Data` information
#' be displayed instead of the data frame (`tibble`) object?
#' @export
print.soma_adat <- function(x, show_header = FALSE, ...) {

  attsTRUE    <- is.intact.attributes(x)
  col_f       <- if ( attsTRUE ) cr_green else cr_red       # nolint
  atts_symbol <- if ( attsTRUE ) symb_tick else symb_cross  # nolint
  writeLines(cli_rule(cr_bold("Attributes"), line_col = "blue"))
  writeLines(
    paste("    ", .pad("Intact", 20), col_f(atts_symbol))
  )
  apts <- getAnalytes(x)
  meta <- setdiff(names(x), apts)

  writeLines(cli_rule(cr_bold("Dimensions"), line_col = "blue"))
  n_pad <- 5
  pad   <- strrep(" ", n_pad)
  dim_vars <- .pad(c("Rows", "Columns", "Clinical Data", "Features"), 20) %>%
    paste0(pad, .)
  dim_vals <- c(nrow(x), ncol(x), length(meta), length(apts)) %>%
    as.character() %>%
    cr_blue()
  writeLines(paste(dim_vars, dim_vals))

  if ( !attsTRUE ) {
    writeLines(cli_rule(cr_bold("Header Data"), line_col = "blue"))
    paste(pad, "No Header.Meta        ",
          cr_yellow(symb_warn),
          cr_red("ADAT columns were probably modified"),
          cr_yellow(symb_warn)
      ) %>%
      writeLines()
  } else {

    # Column Meta Data
    writeLines(cli_rule(cr_bold("Column Meta"), line_col = "blue"))
    B <- names(attributes(x)$Col.Meta)

    # control how many columns of Col.Meta to print
    n_column <- 5
    # add padding for Col Meta between cols
    colpad   <- strrep(" ", 3)

    if ( (L <- length(B)) %% n_column != 0 ) {
      B <- c(B, rep("", n_column - L %% n_column))
    }

    if ( L <= n_column ) {
      B <- format(B)
      writeLines(paste0(colpad, B, collapse = colpad))
    } else {
      B <- B %>%
        split(rep(1:n_column, each = length(B) / n_column)) %>%
        lapply(format)

      # Test: this will fail if not all same length
      data.frame(B)

      B. <- purrr::transpose(B) %>% lapply(unlist, use.names = FALSE)
      lapply(B., paste, collapse = cr_cyan("   |   ")) %>%
        paste(pad, .) %>%
        lapply(writeLines) %>% invisible()
    }

    # show header data only
    if ( show_header ) {
      # Header Meta Data
      writeLines(cli_rule(cr_bold("Header Data"), line_col = "blue"))
      notempty <- function(x) length(x) != 0
      A <- Filter(notempty, attributes(x)$Header.Meta$HEADER)
      padmax <- max(vapply(names(A), nchar, double(1)))
      col1   <- .pad(names(A), padmax) %>% paste0(pad, ., pad)
      col2   <- unlist(A, use.names = FALSE) %>% paste0(pad, ., pad)
      paste0(col1, cr_green(symb_point), col2) %>% writeLines()
     }
  }

  if ( !show_header ) {
    # this is the default behavior
    writeLines(cli_rule(cr_bold("Tibble"), line_col = "blue"))
    print(tibble::as_tibble(x, rownames = ifelse(has_rn(x), "row_names", NA)))
  }

  writeLines(cli_rule(line = 2, line_col = "green"))
  invisible(x)
}
