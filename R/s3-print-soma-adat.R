# Print ----

#' @describeIn read_adat
#' The S3 generic print method (`print`) returns summary information
#' parsed from the object attributes, if possible (see examples), followed
#' by a dispatch to the `tibble` print method.
#'
#' @param x A `soma_adat` class object to [print()].
#' @param show_header Logical. Should all the `Header Data` information
#' be displayed instead of the data frame (`tibble`) object?
#' @importFrom purrr map_chr compact flatten_chr transpose
#' @export
print.soma_adat <- function(x, show_header = FALSE, ...) {

  attsTRUE    <- is.intact.attributes(x)
  col_f       <- if ( attsTRUE ) crayon::green else crayon::red  # nolint
  atts_symbol <- if ( attsTRUE ) symb_tick else symb_cross       # nolint
  writeLines(rule(crayon::bold("Attributes"), line_col = "blue"))
  writeLines(
    paste("    ", .pad("Intact", 20), col_f(atts_symbol))
  )
  apts <- getAnalytes(x)
  meta <- setdiff(names(x), apts)

  writeLines(rule(crayon::bold("Dimensions"), line_col = "blue"))
  n_pad <- 5
  pad   <- strrep(" ", n_pad)
  dim_vars <- .pad(c("Rows", "Columns", "Clinical Data", "Features"), 20) %>%
    paste0(pad, .)
  dim_vals <- c(nrow(x), ncol(x), length(meta), length(apts)) %>%
    as.character() %>%
    crayon::blue()
  writeLines(paste(dim_vars, dim_vals))

  if ( !attsTRUE ) {
    writeLines(rule(crayon::bold("Header Data"), line_col = "blue"))
    paste(pad, "No Header.Meta        ",
           crayon::yellow(symb_warn),
           crayon::red("ADAT columns were probably modified"),
           crayon::yellow(symb_warn)
           ) %>%
      writeLines()
  } else {

    # Column Meta Data
    writeLines(rule(crayon::bold("Column Meta"), line_col = "blue"))
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
        purrr::map(format)

      # Test: this will fail if not all same length
      data.frame(B)

      B. <- purrr::transpose(B) %>% purrr::map(purrr::flatten_chr)
      purrr::map(B., paste, collapse = crayon::cyan("   |   ")) %>%
        paste(pad, .) %>%
        purrr::walk(writeLines)
    }

    # show header data only
    if ( show_header ) {
      # Header Meta Data
      writeLines(rule(crayon::bold("Header Data"), line_col = "blue"))
      A <- attributes(x) %>%
        purrr::pluck("Header.Meta", "HEADER") %>%
        purrr::compact()
      padmax <- purrr::map_dbl(names(A), nchar) %>% max()
      col1   <- .pad(names(A), padmax) %>% paste0(pad, ., pad)
      col2   <- purrr::flatten_chr(A) %>% paste0(pad, ., pad)
      paste0(col1,  crayon::green(symb_point), col2) %>%
        writeLines()
     }
  }

  if ( !show_header ) {
    # this is the default behavior
    writeLines(rule(crayon::bold("Tibble"), line_col = "blue"))
    print(tibble::as_tibble(x, rownames = ifelse(has_rn(x), "row_names", NA)))
  }

  writeLines(rule(line = 2, line_col = "green"))
  invisible(x)
}
