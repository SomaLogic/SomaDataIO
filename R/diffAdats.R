#' Diff Two ADAT Objects
#'
#' Diff tool for the differences between two `soma_adat` objects.
#' When diffs of the table *values* are interrogated, **only**
#' the intersect of the column meta data or feature data is considered
#'
#' @param adat1 First `soma_adat` object.
#' @param adat2 Second `soma_adat` object.
#' @param tolerance Tolerance for the difference between
#' numeric vectors (i.e. SOMAmer/feature data). Passed
#' eventually to [are_equal()].
#' @note Diffs of the column *intersect* names are considered.
#' @author Stu Field
#' @examples
#' diffAdats(example_data, example_data)
#'
#' # remove random column
#' rm <- withr::with_seed(123, sample(1:ncol(example_data), 1))
#' diffAdats(example_data, example_data[, -rm])
#'
#' # change Subarray randomly
#' diffAdats(example_data, dplyr::mutate(example_data, Subarray = sample(Subarray)))
#'
#' # modify 2 RFUs randomly
#' new <- example_data
#' new[5, c(rm, rm + 1)] <- 999
#' diffAdats(example_data, new)
#' @importFrom stringr str_glue str_pad
#' @importFrom purrr walk
#' @importFrom assertthat are_equal
#' @importFrom usethis ui_stop ui_done ui_value
#' @seealso [are_equal()]
#' @export
diffAdats <- function(adat1, adat2, tolerance = 1e-06) {

  if ( !(inherits(adat1, "data.frame") & inherits(adat2, "data.frame")) ) {
    usethis::ui_stop(
      "Both `adat1` & `adat2` must inherit from class `data.frame`."
    )
  }

  map_mark <- function(.x) {
    ifelse(.x, crayon::green(cli::symbol$tick), crayon::red(cli::symbol$cross))
  }

  pad <- 35
  cli::rule(
    "Checking ADAT attributes & characteristics", line_col = crayon::blue, line = 2
    ) %>% writeLines()

  # Attribute names ----
  mark <- are_equal(names(attributes(adat1)), names(attributes(adat2)))
  msg  <- stringr::str_pad("Attribute names are identical", width = pad, "right") # nolint
  usethis::ui_todo("{msg} {map_mark(mark)}")

  # Attributes ----
  mark <- are_equal(attributes(adat1), attributes(adat2))
  msg  <- stringr::str_pad("Attributes are identical", width = pad, "right")
  usethis::ui_todo("{msg} {map_mark(mark)}")

  # Adat dimensions ----
  mark <- all(dim(adat1) == dim(adat2))
  msg  <- stringr::str_pad("ADAT dimensions are identical", width = pad, "right")
  usethis::ui_todo("{msg} {map_mark(mark)}")

  if ( !mark ) {
    mark <- nrow(adat1) == nrow(adat2)
    msg  <- stringr::str_pad("  ADATs have same # of rows", width = pad, "right")
    usethis::ui_todo("{msg} {map_mark(mark)}")

    mark <- ncol(adat1) == ncol(adat2)
    msg  <- stringr::str_pad("  ADATs have same # of columns", width = pad, "right")
    usethis::ui_todo("{msg} {map_mark(mark)}")

    mark <- are_equal(getFeatures(adat1, n = TRUE), getFeatures(adat2, n = TRUE))
    msg  <- stringr::str_pad("  ADATs have same # of features", width = pad, "right")
    usethis::ui_todo("{msg} {map_mark(mark)}")

    mark <- are_equal(getMeta(adat1, n = TRUE), getMeta(adat2, n = TRUE))
    msg  <- stringr::str_pad("  ADATs have same # of meta data", width = pad, "right")
    usethis::ui_todo("{msg} {map_mark(mark)}")
  }

  # Adat row names ----
  mark <- are_equal(rownames(adat1), rownames(adat2))
  msg  <- stringr::str_pad("ADAT row names are identical", width = pad, "right")
  usethis::ui_todo("{msg} {map_mark(mark)}")

  # Adat feature names ----
  same_ft_names <- are_equal(getFeatures(adat1), getFeatures(adat2))
  msg <- stringr::str_pad("ADATs contain identical Features", width = pad, "right")
  usethis::ui_todo("{msg} {map_mark(same_ft_names)}")

  # Adat meta names ----
  same_meta_names <- are_equal(getMeta(adat1), getMeta(adat2))
  msg <- stringr::str_pad("ADATs contain same Meta Fields", width = pad, "right")
  usethis::ui_todo("{msg} {map_mark(same_meta_names)}")

  if ( !(same_meta_names & same_ft_names) ) {
    ipad    <- 20   # internal padding
    apts1_2 <- setdiff(getFeatures(adat1), getFeatures(adat2))
    apts2_1 <- setdiff(getFeatures(adat2), getFeatures(adat1))
    meta1_2 <- setdiff(getMeta(adat1), getMeta(adat2))
    meta2_1 <- setdiff(getMeta(adat2), getMeta(adat1))

    if ( length(apts1_2) > 0 ) {
      stringr::str_glue(
        "Features in {ui_value(deparse(substitute(adat1)))} but \\
        not {ui_value(deparse(substitute(adat2)))}:"
        ) %>% writeLines()
      purrr::walk(stringr::str_pad(apts1_2, ipad), writeLines)
    }

    if ( length(apts2_1) > 0 ) {
      stringr::str_glue(
        "Features in {ui_value(deparse(substitute(adat2)))} but \\
        not {ui_value(deparse(substitute(adat1)))}:"
        ) %>% writeLines()
      purrr::walk(stringr::str_pad(apts2_1, ipad), writeLines)
    }

    if ( length(meta1_2) > 0 ) {
      stringr::str_glue(
        "Meta data in {ui_value(deparse(substitute(adat1)))} but \\
        not {ui_value(deparse(substitute(adat2)))}:"
        ) %>% writeLines()
      purrr::walk(stringr::str_pad(meta1_2, ipad), writeLines)
    }

    if ( length(meta2_1) > 0 ) {
      stringr::str_glue(
        "Meta data in {ui_value(deparse(substitute(adat2)))} but \\
        not {ui_value(deparse(substitute(adat1)))}:"
        ) %>% writeLines()
      purrr::walk(stringr::str_pad(meta2_1, ipad), writeLines)
    }
    cat("\n")
    usethis::ui_done(
      "Continuing on the {ui_value('*INTERSECT*')} of ADAT columns"
    )
  }

  # up to here, all but content/values identical
  # Next -> check values
  writeLines(cli::rule("Checking the data matrix", line_col = crayon::blue))
  .diffAdatColumns(adat1, adat2, meta = TRUE, tolerance = tolerance)
  .diffAdatColumns(adat1, adat2, meta = FALSE, tolerance = tolerance)
  writeLines(cli::rule(line_col = crayon::green, line = 2))
}


#' Diff Columns of an ADAT
#'
#' This function checks either the feature or meta data
#' of an ADAT object. It diffs the values in each column
#' against each other
#'
#' @note This function is an internal only -> to `diffAdats()`
#'
#' @param x First ADAT to check.
#' @param y Second ADAT to check.
#' @param meta Logical. Whether to check the meta data columns.
#' Otherwise, feature data is checked.
#' @param tolerance Numeric level of tolerance.
#' @importFrom purrr map2_lgl keep
#' @importFrom usethis ui_value ui_todo
#' @importFrom assertthat are_equal
#' @importFrom stringr str_pad
#' @author Stu Field
#' @keywords internal
#' @noRd
.diffAdatColumns <- function(x, y, meta = FALSE, tolerance) {

  type <- ifelse(meta, "Meta", "Feature")
  .fun <- switch(type, Meta = getMeta, Feature = getFeatures)
  cols <- intersect(.fun(x), .fun(y))

  test_lgl <- purrr::map2_lgl(x[, cols], y[, cols], ~ {
     if ( meta ) {
       assertthat::are_equal(.x, .y, check.names = FALSE)
     } else {
       assertthat::are_equal(.x, .y, tolerance = tolerance)
     }
  })

  msg <- stringr::str_pad(sprintf("All %s data is identical", type), 35, "right") # nolint

  # `test_lgl` is a logical vector
  if ( all(test_lgl, na.rm = TRUE) ) {
    usethis::ui_todo("{msg} {crayon::green(cli::symbol$tick)}")
    invisible(NULL)
  } else {
    usethis::ui_todo("{msg} {crayon::red(cli::symbol$cross)}")
    vec <- purrr::keep(test_lgl, !test_lgl) %>% names()
    stringr::str_pad("    No. fields that differ ", 37, "right") %>%
      paste(length(vec)) %>% writeLines()
    cli::rule(sprintf("%s data diffs", type), line_col = crayon::magenta) %>%
      writeLines()
    print(usethis::ui_value(vec))
    invisible(NULL)
  }
}
