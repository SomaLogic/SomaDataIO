#' Calculate MAD Outlier Map
#'
#' Calculate the median absolute deviation (statistical) outliers measurements
#' and fold-change criteria from an ADAT. Two values are required for the
#' calculation: median absolute deviation (MAD) and fold-change (FC). Outliers
#' are determined based on the result of _both_ `6*MAD` and `x*FC` , where `x`
#' is the number of fold changes defined.
#'
#' For the S3 plotting method, see [plot.Map()].
#'
#' @family Calc Map
#' @param data A `soma_adat` object containing RFU feature data.
#' @param anno_tbl An annotations table produced via [getAnalyteInfo()].
#'   Used to calculate analyte dilutions for the matrix column ordering.
#'   If `NULL`, a table is generated internally from `data` (if possible), and
#'   the analytes are plotted in dilution order.
#' @param apt.order Character. How should the columns/features be ordered?
#'   Options include: by dilution mix ("dilution"), by median overall signal
#'   ("signal"), or as-is in `data` (default).
#' @param sample.order Either a character string indicating the column name
#'   with entries to be used to order the data frame rows, or a numeric vector
#'   representing the order of the data frame rows. The
#'   default (`NULL`) leaves the row ordering as it is in `data`.
#' @param fc.crit Integer. The fold change criterion to evaluate. Defaults to 5x.
#' @return A list of class `c("outlier_map", "Map")` containing:
#'   \item{matrix}{A boolean matrix of `TRUE/FALSE` whether each sample is an
#'     outlier according the the stated criteria.}
#'   \item{x.lab}{A character string containing the plot x-axis label.}
#'   \item{title}{A character string containing the plot title.}
#'   \item{rows.by.freq}{A logical indicating if the samples are ordered
#'     by outlier frequency.}
#'   \item{class.tab}{A table containing the frequencies of each class if input
#'     `sample.order` is defined as a categorical variable.}
#'   \item{sample.order}{A numeric vector representing the order of the data
#'     frame rows.}
#'   \item{legend.sub}{A character string containing the plot legend subtitle.}
#' @author Stu Field
#' @examples
#' dat <- example_data |> dplyr::filter(SampleType == "Sample")
#' om <- calcOutlierMap(dat)
#' class(om)
#'
#' # S3 print method
#' om
#'
#' # `sample.order = "frequency"` orders samples by outlier frequency
#' om <- calcOutlierMap(dat, sample.order = "frequency")
#' om$rows.by.freq
#' om$sample.order
#'
#' # order samples field in Adat
#' om <- calcOutlierMap(dat, sample.order = "Sex")
#' om$sample.order
#' @importFrom stats median
#' @export
calcOutlierMap <- function(data, anno_tbl = NULL,
                           apt.order = c(NA, "dilution", "signal"),
                           sample.order = NULL, fc.crit = 5) {

  apt.order  <- match.arg(apt.order)
  data       <- .refactorData(data)
  sampleL    <- length(sample.order)
  freq       <- sampleL == 1L && tolower(sample.order) %in% "frequency"
  class_tab  <- NA
  ord        <- seq_len(nrow(data))
  ret        <- list(matrix = matrix(0)) # placeholder: reserve position 1

  if ( is.null(anno_tbl) ) {
    anno_tbl <- getAnalyteInfo(data)
  }

  # Order of the rows in the Map
  if ( !is.null(sample.order) && !freq ) {
    if ( sampleL > 1L && is.numeric(sample.order) ) {
      if ( sampleL != nrow(data) ) {
        stop(
          "Incorrect number of row indices: ", value(nrow(data)),
          "rows vs. ", value(sampleL), " indices.", call. = FALSE
        )
      } else {
        data      <- data[sample.order, ]
        ord       <- sample.order
        ret$y.lab <- "Samples (User Specified Order)"
      }
    } else if ( sampleL == 1L && is.character(sample.order) ) {
      stopifnot(sample.order %in% names(data))
      ord       <- order(data[[sample.order]])
      data      <- data[ord, ]
      class_tab <- table(data[[sample.order]])
      ret$y.lab <- sprintf("Samples (by %s)", sample.order)
    } else {
      stop(
        "Something wrong with `sample.order =` argument: ",
        value(sample.order), call. = FALSE
      )
    }
  }

  data_mat <- data.matrix(data[, getAnalytes(data)])

  # calc statistical outliers matrix (boolean matrix of TRUE/FALSE)
  mat <- apply(data_mat, 2, function(.apt) {
    seq_along(.apt) %in% .getOutliers(.apt, fc.crit)
  })
  rownames(mat) <- rownames(data_mat)   # rownames stripped by apply()

  if ( sum(mat) == 0 ) {
    warning("No outliers detected in outlier map!", call. = FALSE)
  }

  if ( freq ) {
    mat       <- mat[ names(sort(rowSums(mat))), ]
    ret$y.lab <- "Samples Ordered by Outlier Frequency"
  }

  if ( is.na(apt.order) ) {

    ret$x.lab <- "Proteins Ordered in Adat"

  } else if ( apt.order == "dilution" ) {

    apt.dils      <- .getDilList(anno_tbl)
    mat           <- mat[, unlist(apt.dils)]
    ret$dil.nums  <- lengths(apt.dils)
    ret$col.order <- "dilution"
    ret$x.lab     <- sprintf("Dilution Ordered Proteins (%s)",
                             paste(names(apt.dils), collapse = " | "))

  } else if ( apt.order == "signal" ) {

    signal.order  <- sort(apply(data_mat, 2, stats::median))
    mat           <- mat[, names(signal.order)]
    ret$col.order <- "signal"
    ret$x.lab     <- "Proteins by Median Signal"

  } else {
    stop("Problem with `apt.order =` argument: ",
         value(apt.order), call. = FALSE)
  }

  ret$title <- paste0(
    "Outlier Map: | x - median(x) | > 6 * mad(x) & FC > ", fc.crit, "x"
  )
  ret$rows.by.freq <- freq
  ret$class.tab    <- class_tab
  ret$sample.order <- ord
  ret$matrix       <- mat
  ret$legend.sub   <- "Proteins"
  invisible(
    structure(
      ret,
      class = c("outlier_map", "Map", "list")
    )
  )
}


#' @describeIn calcOutlierMap
#' There is a S3 print method for class `"outlier_map"`.
#' @param x An object of class `"outlier_map"`.
#' @param ... Arguments for S3 print methods.
#' @export
print.outlier_map <- function(x, ...) {
  writeLines(
    cli_rule("SomaLogic Outlier Map", line = "double", line_col = "magenta")
  )
  key <- c(
    "Outlier Map dimensions",
    "Title",
    "Class Table",
    "Rows by Frequency",
    "Sample Order",
    "x-label",
    "Legend Sub-title") |> .pad(25)
  value <- c(
    .value(paste(dim(x$matrix), collapse = " x ")),
    .value(x$title),
    c(x$class.tab),
    x$rows.by.freq,
    .value(x$x.lab),
    .value(x$sample.order),
    .value(x$legend.sub)
  )
  writeLines(paste(" ", key, value))
  writeLines(cli_rule(line = "double", line_col = "green"))
  invisible(x)
}


#' S3 plot methods for class outlier_map
#' @noRd
#' @export
plot.outlier_map <- function(x, ...) {
  NextMethod("plot", type = "outlier")
}
