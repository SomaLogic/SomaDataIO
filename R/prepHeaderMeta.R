#' Clean up Header Meta Data
#'
#' Make the header meta conform to current spec and format
#' in preparation for writing to an external text file.
#' This function an internal to `write_adat()`.
#'
#' @param x A `soma_adat` to be written.
#' @return The adat attributes after `Header.Meta` and `Col.Meta` clean up.
#' @author Stu Field
#' @importFrom dplyr select mutate_if
#' @importFrom tidyselect any_of
#' @importFrom purrr map_chr
#' @importFrom usethis ui_done ui_value ui_oops ui_code_block ui_stop
#' @keywords internal
#' @noRd
prepHeaderMeta <- function(data) {

  if ( is.intact.attributes(data) ) {
    x <- attributes(data)
    x$Col.Meta %<>% dplyr::select(-any_of("Dilution2"))  # rm Dilution2
  } else {
    # THIS IS A BIT OF A KLUGE :(
    usethis::ui_oops("Please fix ADAT attributes prior to `write()` call" )
    usethis::ui_oops("Calling `is.intact.attributes(data)` should be TRUE")
    usethis::ui_oops("Fix attributes using `SomaPlyr::createChildAttributes()`")
    usethis::ui_code_block("Example:", copy = FALSE)
    usethis::ui_code_block("  data %<>% createChildAttributes(., parent)")
    usethis::ui_stop("Stopping while you fix the attributes of `data`.")
  }

  # Sync COL_DATA NAME & Type vectors
  map <- as.list(x$Header.Meta$COL_DATA$Type)
  names(map) <- x$Header.Meta$COL_DATA$Name
  x$Header.Meta$COL_DATA$Name <- names(x$Col.Meta)
  x$Header.Meta$COL_DATA$Type <- unname(unlist(map[names(x$Col.Meta)]))

  # Update the ROW_DATA -> Name & Type vectors
  data <- data %>% dplyr::select(getMeta(.))
  x$Header.Meta$ROW_DATA$Name <- names(data)
  x$Header.Meta$ROW_DATA$Type <- purrr::map_chr(data, typeof)

  # zap commas with semicolons
  x$Col.Meta %<>% dplyr::mutate_if(is.character, ~ stringr::str_replace_all(.x, ",", ";"))

  if ( "CreatedByHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedByHistory <-
      paste0(x$Header.Meta$HEADER$CreatedBy,
             "|",
             x$Header.Meta$HEADER$CreatedByHistory)
  } else {
    x$Header.Meta$HEADER$CreatedByHistory <- x$Header.Meta$HEADER$CreatedBy
  }

  if ( "CreatedDateHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedDateHistory <-
      paste0(x$Header.Meta$HEADER$CreatedDate,
             "|",
             x$Header.Meta$HEADER$CreatedDateHistory)
  } else {
    x$Header.Meta$HEADER$CreatedDateHistory <- x$Header.Meta$HEADER$CreatedDate
  }

  # version number stuff
  if ( !("Version" %in% names(x$Header.Meta$HEADER) &&
         x$Header.Meta$HEADER$Version == "1.2") ) {
    x$Header.Meta$HEADER$Version <- "1.2"
    usethis::ui_done("Updating ADAT version to: {ui_value('1.2')}")
  }

  x$Header.Meta$HEADER$CreatedDate <- format(Sys.time(), "%Y-%m-%d")
  user     <- ifelse(grepl("linux|darwin", R.version$platform),
                     Sys.getenv("USER"),
                     Sys.getenv("USERNAME"))
  pkg     <- utils::packageName()
  pkg_ver <- utils::packageVersion(pkg) %>% as.character()   # nolint

  x$Header.Meta$HEADER$CreatedBy <-
    sprintf("User: %s; Package: %s_%s; using %s; Platform: %s",
            user, pkg, pkg_ver,
            R.version$version.string, R.version$system)
  x
}
