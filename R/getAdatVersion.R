#' Get ADAT Version
#'
#' Get the ADAT version number from a parsed ADAT header.
#'
#' @param x The "Header.Meta" list of an ADAT object attributes.
#' @return Returns the key-value of the ADAT version as a string.
#' @author Stu Field
#' @examples
#' header <- attributes(example_data)$Header.Meta
#' getAdatVersion(header)
#'
#' header$HEADER$Version <- "1.0"
#' getAdatVersion(header)
#' @export
getAdatVersion <- function(x) {

  vidx <- grep("^Version$|^AdatVersion$", names(x$HEADER))

  if ( length(vidx) == 0L ) {
    stop(
      "Unable to identify ADAT Version from Header information. ",
      "Please check 'Header.Meta'.", call. = FALSE
    )
  }

  version <- x$HEADER[[vidx]]

  if ( length(version) > 1L ) {
    warning(
      "Version length > 1 ... there may be empty tabs in ",
      "the header block above the data matrix.", call. = FALSE
    )
    version <- version[1L]
  }

  if ( identical(version, "1.01") ) {
    stop(
      "Invalid Version (", .value("1.01"), "). Please modify to `1.0.1`.",
      call. = FALSE
    )
  }
  version
}
