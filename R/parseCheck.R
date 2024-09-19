#' ADAT Parse Checker
#'
#' A pre-processing diagnostic to check the ADAT format
#' prior to loading via [read_adat()]. This check is triggered
#' when the `debug = TRUE` param is set during [read_adat()].
#'
#' @param all.tokens The tokens from the original adat, loaded using
#'   [readLines()]. Internally, this is passed directly from [read_adat()],
#'   but can be created on the fly from the file itself (see example).
#' @return `NULL`. With diagnostic file information printed to console:
#'   \item{Table Begin:}{Numeric value (line number) of the "^TABLE_BEGIN" row.}
#'   \item{Col.Meta Start:}{Numeric value (line number) of the row in which the
#'     Col Meta block starts.}
#'   \item{Col.Meta Shift:}{Numeric value of the shift for the Col Meta block
#'     of data (right shift).}
#'   \item{Header Row:}{Numeric value of the header row containing data,
#'     i.e. no column or header data.}
#'   \item{Rows of the Col Meta:}{Numeric values of the adat rows containing
#'     Column Meta data.}
#'   \item{Col Meta:}{Character string of the column meta data.}
#'   \item{Row Meta:}{Character string of the row meta data.}
#' @author Stu Field
#' @examples
#' f <- system.file("extdata", "example_data10.adat",
#'             package = "SomaDataIO", mustWork = TRUE)
#' lines <- .getHeaderLines(f) |> strsplit("\t", fixed = TRUE)
#' parseCheck(lines)
#'
#' # You can call parseCheck() indirectly via `read_adat(..., debug = TRUE)`
#' read_adat(f, debug = TRUE)
#' @importFrom utils head tail
#' @noRd
parseCheck <- function(all.tokens) {

  if ( inherits(all.tokens, "character") && length(all.tokens) == 1L ) {
    stop(
      "Format is wrong for the `all.tokens` argument. ",
      "Are you sure you are passing a list of TOKENS and *not* a filename?",
      call. = FALSE
    )
  }

  # ----------------------- #
  # check if necessary pieces of header present
  # ----------------------- #
  firsts     <- vapply(all.tokens, `[`, i = 1L, "")
  chk_string <- c("^HEADER", "^ROW_DATA", "^COL_DATA", "^TABLE_BEGIN")
  if ( any(!chk_string %in% firsts) ) {
    stop(
      "The following *anchor* token(s) is/are absent from ",
      "the ADAT header: ", .value(setdiff(chk_string, firsts)),
      call. = FALSE
    )
  }

  # trailing tabs
  tab_test <- all.tokens[[ which(firsts == "^HEADER") ]]
  if ( length(tab_test) > 100L ) {
    # catch for runaway tabs
    writeLines(cli_rule(cr_bold("Head"), line_col = "blue"))
    print(head(tab_test, 10L))
    writeLines(cli_rule(cr_bold("Tail"), line_col = "blue"))
    print(tail(tab_test, 10L))
    cat("\n")
    .oops(
      "This does not appear to be a valid ADAT
      One possibility is that there are empty tabs filling \\
      out the entire header block.
      Are there empty strings indicated above?"
    )
    cat("\n")
  }

  which_table_begin    <- which(firsts == "^TABLE_BEGIN")
  which_col_meta_start <- which_table_begin + 1L
  col_meta_shift       <- which(all.tokens[[which_col_meta_start]] != "")[1L]

  row_meta <- all.tokens[[ which(firsts == "^ROW_DATA") + 1L ]]
  col_meta <- all.tokens[[ which(firsts == "^COL_DATA") + 1L ]]
  col_meta <- grep("[[:alnum:]]", col_meta, value = TRUE)[-1L]
  row_meta <- grep("[[:alnum:]]", row_meta, value = TRUE)[-1L]

  if ( col_meta_shift != length(row_meta) + 1L ) {
    stop(
      "The Col.Meta shift ", .value(col_meta_shift), " does not match the ",
      "length stated in ^ROW_DATA row ", .value(length(row_meta) + 1L),
      " -- visually inspect ADAT.", call. = FALSE
    )
  }

  which_header_row    <- which_table_begin + length(col_meta) + 1L
  which_col_meta_rows <- seq.int(which_col_meta_start,
                                 which_col_meta_start + length(col_meta) - 1L)

  writeLines(cli_rule(cr_bold("Parsing Specs"), line = 2, line_col = "blue"))
  c1 <- c(
    "Table Begin",
    "Col.Meta Start",
    "Col.Meta Shift",
    "Header Row",
    "Rows of the Col Meta") |> .pad(25)
  c2 <- list(
    which_table_begin,
    which_col_meta_start,
    col_meta_shift,
    which_header_row,
    which_col_meta_rows
  )
  for ( .i in seq_along(c1) ) {
    cat(cr_red("\u2022 "), c1[.i], " ", .value(c2[[.i]]), "\n", sep = "")
  }


  # Col Meta ----
  writeLines(
    cli_rule(
      cr_bold("Col Meta"), line_col = "magenta", right = length(col_meta)
    )
  )
  nms <- paste(col_meta, collapse = ", ")
  str <- strwrap(nms, width = getOption("width"),
                 prefix = paste0(cr_cyan(symb_info), " "))
  writeLines(str)

  # Row Meta ----
  writeLines(
    cli_rule(
      cr_bold("Row Meta"), line_col = "magenta", right = length(row_meta)
    )
  )
  nms <- paste(row_meta, collapse = ", ")
  str <- strwrap(nms, width = getOption("width"),
                 prefix = paste0(cr_cyan(symb_info), " "))
  writeLines(str)

  if ( which_header_row >= length(all.tokens) ) {
    .oops("No feature/RFU data ... Col.Meta only ADAT")
    writeLines(cli_rule("Done", line = 2, line_col = "green"))
    return(invisible(NULL))
  }

  # col meta names from Col.Meta block
  # Not from Heater.Meta block
  col_meta2 <- vapply(all.tokens[which_col_meta_rows], `[`, i = col_meta_shift, "")
  #print(col_meta2)  # nolint: commented_code_linter, comment_nospace_linter.

  if ( any(duplicated(col_meta2)) ) {
    writeLines(
      cli_rule(
        cr_bold("Duplicated Col.Meta names"),
        line_col = "blue", right = cr_red("!")
      )
    )
    .oops("Duplicated Col.Meta names in col meta block")
    .oops("Potential over-write scenario for entry: \\
          {.value(col_meta2[duplicated(col_meta2))]}")
  }

  # check col meta match
  if ( !isTRUE(setequal(col_meta, col_meta2)) ) {
    .oops("Mismatch between `^COL_DATA` in header and `Col.Meta` block:")
    .todo("  In Header:   {.val {col_meta}}")
    .todo("  In Col.Meta: {.val {col_meta2}}")
    stop("Stopping check early.", call. = FALSE)
  }

  # check row meta match
  string_in_table <- all.tokens[[which_header_row]]
  string_in_table <- string_in_table[string_in_table != ""]
  if ( !isTRUE(setequal(row_meta, string_in_table)) ) {
    writeLines(
      vapply(seq_along(row_meta),
             function(.x) paste(symb_cross, row_meta[.x], "<->", string_in_table[.x]),
             "")
    )
    stop(
      "Meta data mismatch between `Header Meta` vs `meta data` ",
      "in table. See ADAT file line: ", .value(which_header_row), "\n",
      call. = FALSE
    )
  }

  # ------------------------------------------------ #
  # check lengths of each row
  # look for trailing tabs & non-square data block
  # header row can be off by 1 so remove (checked below)
  # ------------------------------------------------ #
  # remove empty header row between feature data and col meta
  token_lengths <- lengths(all.tokens[-which_header_row])
  # lengths of data block only
  data_lengths <- token_lengths[which_col_meta_start:length(token_lengths)]

  # check if entire data block is of same length
  # if tabs are wrong it won't be
  if ( diff(range(data_lengths)) != 0L ) {
    writeLines(
      cli_rule(
        cr_bold("Possible Tabs Problem"),
        line_col = "blue", right = cr_red("!")
      )
    )
    .todo("All Token lengths:")
    print(token_lengths)
    .todo("Data Block Token lengths:")
    print(data_lengths)
    tab <- table(data_lengths)
    names(dimnames(tab)) <- "Table of Lengths:"
    print(tab)
    warning(
      "Token length is inconsistent for data matrix block.\n",
      "Check for trailing/missing tabs in the main block of the Adat.\n",
      "One (or more) of the above is different from the rest.",
      call. = FALSE
    )
  }

  # check header row separately
  # compare to first row of feature data
  # do they differ by more than 10?
  # tab error in header row (java issue)
  table_width   <- length(all.tokens[[which_header_row + 1L]])
  header_length <- length(all.tokens[[which_header_row]])
  if ( (table_width - header_length) > 10L ) {
    writeLines(
      cli_rule(
        cr_bold("Problem with tabs in Header (blank) row"),
        line_col = "blue", right = cr_red("!")
      )
    )
    .todo("Should be:    {.val {table_width}}")
    .todo("Currently is: {.val {header_length}}")
    # print(all.tokens[[ which_header_row ]])   # nolint: commented_code_linter.
    .oops("Length of the header row is incorrect")
    .oops("Does not match the width of the data table")
    .oops("Likely a tabs problem ...")
  }

  # check for empty strings in entire Col.Meta block
  # may remove one day; non-essential check
  has_gaps <- vapply(all.tokens[which_col_meta_rows],
                     function(.x) any(tail(.x, -col_meta_shift) == ""), NA)

  if ( any(has_gaps) ) {
    writeLines(
      cli_rule(
        cr_bold("Empty Strings Detected in Col.Meta"),
        line_col = "blue", right = cr_red("!"))
    )
    gap_chr <- col_meta2[has_gaps]
    .todo(
      paste("Visually inspect the following Col.Meta rows: {.val {gap_chr}}")
    )
    if ( identical(Sys.getenv("TESTTHAT"), "true") ||
         isTRUE(getOption("knitr.in.progress")) ) {
      .symb <- symb_info
    } else {
      .symb <- paste0("\033[36m", symb_info, "\033[39m")
    }
    cat(.symb, "They may be missing in: ")
    print(.value(c("Spuriomers", "HybControls")))
    .todo("This is non-critical in ADATs with new {.val {'seq.1234.56'}} format.")
  }
  writeLines(cli_rule("Parse Diagnostic Complete", line = 2, line_col = "green"))
}
