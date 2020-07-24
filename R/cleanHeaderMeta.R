#' Clean up Header Meta Data
#'
#' Make the header meta conform to current spec and format
#' in preparation for writing to an external text file.
#' This function an internal to `prepWriteADAT()`.
#'
#' @param x A `soma_adat` list of attributes.
#' @return The adat attributes after `Header.Meta` clean up.
#' @author Stu Field
#' @importFrom purrr map_chr
#' @importFrom usethis ui_done ui_value
#' @importFrom devtools session_info
#' @keywords internal
#' @noRd
cleanHeaderMeta <- function(x) {

  # Sync COL_DATA NAME & Type vectors
  x$Header.Meta$COL_DATA$Name <- names(x$Col.Meta)
  x$Header.Meta$COL_DATA$Type <- names(x$Col.Meta) %>%
    purrr::map_chr(function(type) {
      which(x$Header.Meta$COL_DATA$Name == type) %>%
        x$Header.Meta$COL_DATA$Type[ . ]
    })

  # Sync ROW_DATA NAME & Type vectors:
  # Sync'ing the Type vector is done outside

  if ( "CreateDateHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreateDateHistory <-
      paste0(x$Header.Meta$HEADER$CreatedDate,
             "|",
             x$Header.Meta$HEADER$CreateDateHistory)
  } else {
    x$Header.Meta$HEADER$CreateDateHistory <- x$Header.Meta$HEADER$CreatedDate
  }

  if ( "CreateByHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreateByHistory <-
      paste0(x$Header.Meta$HEADER$CreatedBy,
             "|",
             x$Header.Meta$HEADER$CreateByHistory)
  } else {
    x$Header.Meta$HEADER$CreateByHistory <- x$Header.Meta$HEADER$CreatedBy
  }

  # version number stuff
  if ( !("Version" %in% names(x$Header.Meta$HEADER) &&
         x$Header.Meta$HEADER$Version == "1.2") ) {
    x$Header.Meta$HEADER$Version <- "1.2"
    usethis::ui_done("Updating ADAT version to: {ui_value('1.2')}")
  }

  x$Header.Meta$HEADER$CreatedDate <- format(Sys.time(), "%Y-%m-%d")
  sessInfo <- devtools::session_info()
  user     <- ifelse(grepl("linux|darwin", sessInfo$platform$system),
                     Sys.getenv("USER"),
                     Sys.getenv("USERNAME"))
  pkg     <- utils::packageName()
  pkg_ver <- utils::packageVersion(pkg) %>% as.character()   # nolint

  x$Header.Meta$HEADER$CreatedBy <-
    sprintf("User: %s; Package: %s_%s; using %s; Platform: %s",
            user, pkg, pkg_ver,
            sessInfo$platform$version, sessInfo$platform$system)

  return(x)

}
