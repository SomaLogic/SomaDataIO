#' SomaLogic ADAT parser
#'
#' Parses the header section of an ADAT file.
#'
#' @family IO
#' @param file Character. The elaborated path and file name of the
#'   `*.adat` file to be loaded into an R workspace environment.
#' @return A list of relevant file information required by [read_adat()]
#'   in order to complete loading the ADAT file, including:
#' \item{Header.Meta}{list of notes and other information about the adat}
#' \item{Col.Meta}{list of vectors that contain the column meta
#'   data about individual analytes, includes information about the target
#'   name and calibration and QC ratios}
#' \item{file_specs}{list of values of the file parsing specifications}
#' \item{row_meta}{character vector of the clinical variables; assay
#'   information that is included in the adat output along with the RFU data}
#' @author Stu Field
#' @examples
#' f <- system.file("extdata", "example_data10.adat",
#'                  package = "SomaDataIO", mustWork = TRUE)
#' header <- parseHeader(f)
#' header
#' @importFrom stats setNames
#' @importFrom tibble enframe
#' @export
parseHeader <- function(file) {

  nms <- c("Header.Meta", "Col.Meta", "file_specs")
  ret <- setNames(replicate(length(nms), list()), nms)
  all_data <- .getHeaderLines(file)

  line <- 0L
  repeat {
    line <- line + 1L
    row_data <- all_data[line]

    # if end of file reached before feature data = empty adat
    # modified based on length of the all_data rather then content of row_data
    if ( ret$file_specs$empty_adat <- line > length(all_data) ) {
      break
    }

    row_data <- .trimRunawayTabs(row_data)  # trim runaway tabs in anchor lines

    if ( grepl("Checksum", row_data) ) {
      # for old ADATs with checksums
      ret$Header.Meta$Checksum <- strsplit(row_data, "\t", fixed = TRUE)[[1L]][2L]
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
      ret$file_specs$table_begin    <- line
      ret$file_specs$col_meta_start <- line + 1
      shift <- regexpr("[[:alnum:]]", all_data[line + 1])
      ret$file_specs$col_meta_shift <- as.integer(shift) # strip attr
      next
    } else if ( grepl("^\\^[A-Z]", row_data) ) {
      section    <- "Free.Form"
      free_field <- strsplit(row_data, "\t", fixed = TRUE)[[1L]][1L]
      free_field <- gsub("^[^A-Za-z]+", "", free_field)
      next
    }
    #print(section)  # nolint: commented_code_linter, comment_nospace_linter.

    # leading tab-space means within Col.Meta block
    leading_tab <- grepl("^\t", row_data)

    # trim leading/trailing empty strings in header block
    # trap case: "key\tvalue\t\t\t\t\t\t\t" -> "key\tvalue"
    side <- switch(section, Col.Meta = "left", "right")
    row_data <- trimws(row_data, which = side, whitespace = "[\t]")

    # If in Col.Meta but no longer leading tab-space, break out Col.Meta
    # This only happens once, when Col.Meta section has been completed
    if ( section == "Col.Meta" && !leading_tab ) {
      section <- "EXIT"
    }

    tokens <- strsplit(row_data, "\t", fixed = TRUE)[[1L]]
    # pad trailing match; strsplit() does not pad empty string with trailing match
    if ( grepl("\t$", row_data) ) tokens <- c(tokens, "")
    #print(tokens)  # nolint: commented_code_linter, comment_nospace_linter.

    if ( section == "HEADER" && all(tokens == "") ) {
      warning(
        "Blank row detected in `Header` section ... it will be skipped.",
        call. = FALSE
      )
      next
    }

    # zap (!) for names
    cur_name <- gsub("^[^A-Za-z\t]+", "", tokens[1L])

    if ( section == "HEADER" ) {
      ret$Header.Meta[[section]][[cur_name]] <- list()
      ret$Header.Meta[[section]][[cur_name]] <- .setAttr(tokens[-1L], tokens[1L])
    } else if ( section == "COL_DATA" || section == "ROW_DATA" ) {
      ret$Header.Meta[[section]][[cur_name]] <- .setAttr(tokens[-1L], tokens[1L])
    } else if ( section == "Free.Form" ) {
      ret$Header.Meta[[free_field]][[cur_name]] <- list()
      ret$Header.Meta[[free_field]][[cur_name]] <- .setAttr(tokens[-1L], tokens[1L])
    } else if ( section == "Col.Meta" ) {
      ret[[section]][[tokens[1L]]]  <- tokens[-1L]
    } else if ( section == "EXIT" ) {
      # if at end of Col.Meta section, break loop & stop parsing
      # 1st check that all lengths Col.Meta are equal (or as_tibble() will fail)
      if ( diff(range(lengths(ret$Col.Meta))) != 0L ) {
        if ( interactive() ) {
          print(enframe(lengths(ret$Col.Meta), name = "Field", value = "\t"))
        }
        stop(
          "Col.Meta lengths unequal! The Col.Meta block in not square.\n",
          "There may be trailing tabs in the Col.Meta section.", call. = FALSE
        )
      }
      ret$file_specs$data_begin   <- line
      tokens <- trimws(tokens)    # ensure spaces in header row -> ""
      ret$row_meta                <- tokens[tokens != ""] # rm empty elements
      ret$Header.Meta$TABLE_BEGIN <- basename(file)  # append file name to header & break
      break
    }
  }

  # TRUE if old adat version
  ret$file_specs$old_adat <- getAdatVersion(ret$Header.Meta) < "1.0.0"
  ret
}


# helper to set attributes
.setAttr <- function(obj, value, attr = "raw_key") {
  attr(obj, attr) <- value
  obj
}


# Bite off chunks of the ADAT header 'x' (20) at a time
#   until the RFU block is reached
# Should be faster than reading *all* lines _every_ time,
#   especially for large files with many samples
# @param n initial starting n lines to ingest.
# @param chunks number of additional new lines to ingest at each iteration.
.getHeaderLines <- function(file, n = 20L, chunks = 20L) {
  repeat {
    lines <- readLines(file, n = n, encoding = "UTF-8")
    if ( length(lines) < n ) break    # exit if overshot file length
    lastline   <- trimws(rev(lines)[1L], which = "right")  # only trailing \t
    tab_start  <- grepl("^\t", lastline) # line starts with \t
    tab_digits <- gregexpr("\t[0-9]+[.][0-9]+\t", lastline)[[1L]] # tabs w only digits
    # exit if:
    #   last line doesn't start with tab (not in Col.Meta block)
    #   last line has > 250 tabs containing only digits (RFU data block)
    if ( !tab_start && length(tab_digits) > 250L ) {
      break
    } else {
      n <- n + chunks    # bite off chunks of lines
    }
  }
  lines
}

# Runaway \t catch:
#   anchor (^) lines need right-side trimming to determine 'section' correctly
# @param x A single line of text from readLines().
.trimRunawayTabs <- function(x) {
  anchors <- c("^HEADER", "^ROW_META", "^COL_META", "^TABLE_BEGIN")
  pattern <- paste0("\\", anchors, "[\t]+$")
  pattern <- paste(pattern, collapse = "|")
  if ( grepl(pattern, x) ) {
    warning("Trailing tabs filling out header block in one of: ",
            .value(anchors), "\nTrailing tabs will be trimmed.", call. = FALSE)
    trimws(x, "right", whitespace = "[\t]")
  } else {
    x
  }
}
