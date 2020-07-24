# Print ----

#' @describeIn read_adat
#' The S3 generic print method (`print`) returns summary information
#' parsed from the object attributes, if possible (see examples), followed
#' by a dispatch to the `tibble` print method.
#'
#' @param x Object of class `soma_adat` used in the
#' S3 generic \code{\link{print}}.
#' @param show_header Logical. Should all the `Header Data` information
#' be displayed instead of the data frame (`tibble`) object?
#' @importFrom cli symbol rule
#' @importFrom tibble as_tibble
#' @importFrom stringr str_dup str_pad str_glue
#' @importFrom purrr map_chr compact flatten_chr transpose
#' @importFrom crayon green red blue cyan bold col_align col_nchar yellow
#' @export
print.soma_adat <- function(x, show_header = FALSE, ...) {

  attsTRUE    <- is.intact.attributes(x)
  col_f       <- if ( attsTRUE ) crayon::green else crayon::red    # nolint
  atts_symbol <- if ( attsTRUE ) cli::symbol$tick else cli::symbol$cross   # nolint
  writeLines(cli::rule(crayon::bold("Attributes"), line_col = crayon::blue))
  stringr::str_glue("     {x} {col_f(atts_symbol)}",
                    x = stringr::str_pad("Intact", 20, "right")) %>%
    writeLines()
  apts <- get_features(names(x))
  meta <- setdiff(names(x), apts)

  writeLines(cli::rule(crayon::bold("Dimensions"), line_col = crayon::blue))
  n_pad    <- 5
  pad <- stringr::str_dup(" ", n_pad)
  dim_vars <- stringr::str_pad(c("Rows", "Columns", "Clinical Data", "Features"),
                               width = 20, "right") %>% paste0(pad, .)
  dim_vals <- c(nrow(x), ncol(x), length(meta), length(apts)) %>%
    as.character() %>%
    crayon::blue()
  writeLines(paste(dim_vars, dim_vals))

  if ( !attsTRUE ) {
    writeLines(cli::rule(crayon::bold("Header Data"), line_col = crayon::blue))
    paste(pad, "No Header.Meta        ",
           crayon::yellow(cli::symbol$warning),
           crayon::red("ADAT columns were probably modified"),
           crayon::yellow(cli::symbol$warning)
           ) %>%
      writeLines()
  } else {

    # Column Meta Data
    writeLines(cli::rule(crayon::bold("Column Meta"), line_col = crayon::blue))
    B <- names(attributes(x)$Col.Meta)

    # control how many columns of Col.Meta to print
    n_column <- 5
    # add padding for Col Meta between cols
    colpad   <- stringr::str_dup(" ", 3)

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
      cli::rule(crayon::bold("Header Data"), line_col = crayon::blue) %>%
        writeLines()
      A <- attributes(x) %>%
        purrr::pluck("Header.Meta", "HEADER") %>%
        purrr::compact()
      padmax <- purrr::map_dbl(names(A), nchar) %>% max()
      col1   <- stringr::str_pad(names(A), padmax, "right") %>%
        paste0(pad, ., pad)
      col2   <- purrr::flatten_chr(A) %>% paste0(pad, ., pad)
      paste0(col1,  crayon::green(cli::symbol$pointer), col2) %>%
        writeLines()
     }
  }

  if ( !show_header ) {
    # this is the default behavior
    cli::rule(crayon::bold("Tibble"), line_col = crayon::blue) %>%
      writeLines()
    rnms <- ifelse(is.na(.row_names_info(x, type = 0L)[1L]), NA, "row_names")
    print(tibble::as_tibble(x, rownames = rnms))
  }

  writeLines(cli::rule(line = 2, line_col = crayon::green))
  invisible(x)
}

