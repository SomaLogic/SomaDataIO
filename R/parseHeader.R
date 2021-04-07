#' SomaLogic ADAT parser
#'
#' Parses the header section of an ADAT file.
#'
#' @family IO
#' @param file Character. The elaborated path and file name of the
#' `*.adat` file to be loaded into an R workspace environment.
#' @return A list of relevant file information required by [read_adat()]
#' in order to complete loading the ADAT file, including:
#' \item{Header.Meta}{list of notes and other information about the adat}
#' \item{Col.Meta}{list of vectors that contain the column meta
#'   data about individual analytes, includes information about the target
#'   name and calibration and QC ratios}
#' \item{file.specs}{list of vectors containing the file specs}
#' \item{row.meta}{vector of names of the "row.meta" data; assay
#'   information that is included in the adat output along with the RFU data}
#' @author Stu Field
#' @examples
#' f <- system.file("example", "example_data.adat", package = "SomaDataIO",
#'                  mustWork = TRUE)
#' header <- parseHeader(f)
#' header
#' @seealso [read_lines()]
#' @importFrom readr read_lines
#' @importFrom usethis ui_stop ui_warn
#' @importFrom stringr str_remove_all str_split str_which
#' @importFrom purrr map
#' @importFrom rlang set_names
#' @export
parseHeader <- function(file) {

  line <- 0
  ret  <- c("Header.Meta", "Col.Meta", "file.specs") %>%
    rlang::set_names() %>%
    purrr::map(~list())

  repeat {
    row_data <- readr::read_lines(file, n_max = 1L, skip = line)

    # if end of file reached before feature data = empty adat
    if ( ret$file.specs$EmptyAdat <- length(row_data) == 0 ) {
      break
    }

    line <- line + 1
    # print(line)
    catchRunawayTabs(row_data)            # catch for runaway tabs

    if ( grepl("Checksum", row_data) ) {
      ret$Header.Meta$Checksum <- stringr::str_split(row_data,
                                                     pattern = "\t")[[1L]][2L]
      next
    } else if ( row_data == "^HEADER" ) {
      section <- "HEADER"
      next
    } else if ( row_data == "^COL_DATA" ) {
      section <- "COL_DATA"
      next
    } else if ( row_data == "^ROW_DATA" ) {
      section <- "ROW_DATA"
      next
    } else if ( row_data == "^TABLE_BEGIN" ) {
      section <- "Col.Meta"
      ret$file.specs$table.begin    <- line
      ret$file.specs$col.meta.start <- line + 1
      next
    } else if ( grepl("^\\^[A-Z]", row_data) ) {
      section    <- "Free.Form"
      free_field <- stringr::str_split(row_data, pattern = "\t")[[1L]][1L]
      free_field <- substr(free_field, 2, nchar(free_field))
      next
    }
    # print(section)

    tokens <- stringr::str_split(row_data, pattern = "\t")[[1L]]
    # print(tokens)

    if ( section == "HEADER" && length(tokens) == 1 && tokens == "" ) {
      usethis::ui_warn(
        "Blank row(s) detected in `Header` section ... they will be skipped."
      )
      next
    }

    # are 1st 2 entries empty strings? Col.Meta section
    first_alnum <- stringr::str_which(tokens, "[[:alnum:]]")[1L]

    # If first alpha-num is once again at 1 | 2 position, break out of Col.Meta section
    # This only happens once, when Col.Meta section has been completed
    if ( section == "Col.Meta" && first_alnum <= 2 ) {
      section <- "DATA_TABLE"
    }

    # Trim leading/trailing empty strings from vector
    # But treat the Col.Meta section specially
    tokens %<>% trim_empty(ifelse(section == "Col.Meta", "left", "right"))

    # zap (!), non-alphanum, double dots etc.
    tokens[1L] <- stringr::str_remove_all(tokens[1L], "^[^A-Za-z]")
    # print(tokens[1])

    if ( section == "HEADER" ) {
      cur.header <- tokens[1L]
      ret$Header.Meta[[section]][[cur.header]] <- list()
      ret$Header.Meta[[section]][[cur.header]] <- tokens[-1]
    } else if ( section == "COL_DATA" ) {
      ret$Header.Meta[[section]][[tokens[1L]]]  <- tokens[-1]
    } else if ( section == "ROW_DATA" ) {
      ret$Header.Meta[[section]][[tokens[1L]]]  <- tokens[-1]
    } else if ( section == "Free.Form" ) {
      cur.header <- tokens[1L]
      ret$Header.Meta[[free_field]][[cur.header]] <- list()
      ret$Header.Meta[[free_field]][[cur.header]] <- tokens[-1]
    } else if ( section == "Col.Meta" ) {
      ret[[section]][[tokens[1L]]]  <- tokens[-1]
      ret$file.specs$col.meta.shift <- first_alnum
    } else if ( section == "DATA_TABLE" ) {
      # if at end of Col.Meta section, break loop & stop reading file
      # first check that all lengths Col.Meta are equal (or as_tibble will fail)
      if ( diff(range(purrr::map_dbl(ret$Col.Meta, length))) != 0 ) {
        usethis::ui_stop(
          "Col.Meta lengths unequal! The Col.Meta block in not square.
          There may be trailing tabs in the Col.Meta section."
        )
      }
      ret$file.specs$data.begin   <- line
      ret$row.meta                <- tokens
      ret$Header.Meta$TABLE_BEGIN <- basename(file)  # append file name to header & break
      break
    }
  }
  # TRUE if old adat version
  ret$file.specs$old.adat <- getAdatVersion(ret$Header.Meta) < "1.0.0"
  ret
}

#' Runaway Tabs Catch: Internal to parseHeader
#' @param x A read-in line of text
#' @importFrom usethis ui_oops ui_stop
#' @keywords internal
#' @noRd
catchRunawayTabs <- function(x) {
  if ( grepl("^\\^.*[\t]{250,}$", x) ) {
    usethis::ui_oops("Possible runaway tabs!")
    usethis::ui_stop(
      "Invalid ADAT! Empty tabs filling out the entire header block."
    )
  }
  invisible(NULL)
}
