#' Helpers to Extract Information from an ADAT
#'
#' Retrieves elements of the `HEADER` attributes of the object:\cr\cr
#' [getAdatVersion()] determines the the ADAT version
#'   number from a parsed ADAT header.\cr\cr
#' [getSomaScanVersion()] determines the original SomaScan assay version
#'   that generated RFU measurements within a `soma_adat` object.
#' [checkSomaScanVersion()] determines if the version of
#'   is a recognized version of SomaScan.\cr
#' \cr
#' Table of SomaScan Assay versions:
#' \tabular{lll}{
#'   **Version**  \tab **Commercial Name** \tab **Size** \cr
#'   `V4`         \tab 5k                  \tab 5284     \cr
#'   `v4.1`       \tab 7k                  \tab 7596     \cr
#'   `v5.0`       \tab 11k                 \tab 11083    \cr
#' }
#' \cr
#' [getSignalSpace()] determines the current signal space of
#' the RFU values, which may differ from the original SomaScan
#' signal space if the data have been lifted. See [lift_adat()].
#'
#' @name adat-helpers
#' @param atts The *attributes* of a `soma_adat` object.
#' @return
#'   \item{[getAdatVersion()]}{The key-value of the `Version` as a string.}
#' @author Stu Field
#' @examples
#' atts <- attributes(example_data)
#' getAdatVersion(atts)
#'
#' atts$Header.Meta$HEADER$Version <- "99.0"
#' getAdatVersion(atts)
#' @export
getAdatVersion <- function(atts) {

  x <- atts$Header.Meta$HEADER
  vidx <- grep("^Version$|^AdatVersion$", names(x))

  if ( length(vidx) == 0L ) {
    stop(
      "Unable to identify ADAT Version from Header information. ",
      "Please check 'Header.Meta'.", call. = FALSE
    )
  }

  version <- as.character(x[[vidx]])

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


#' Gets the SomaScan version
#'
#' @rdname adat-helpers
#' @inheritParams params
#' @examples
#'
#' ver <- getSomaScanVersion(example_data)
#' ver
#' @return
#'   \item{[getSomaScanVersion()]}{The key-value of the `AssayVersion` as a string.}
#' @export
getSomaScanVersion <- function(adat) {
  as.character(attr(adat, "Header.Meta")$HEADER$AssayVersion)
}


#' Gets the SomaScan Signal Space
#'
#' @rdname adat-helpers
#' @inheritParams params
#' @examples
#'
#' rfu_space <- getSignalSpace(example_data)
#' rfu_space
#' @return
#'   \item{[getSignalSpace()]}{The key-value of the `SignalSpace` as a string.}
#' @export
getSignalSpace <- function(adat) {
  attr(adat, "Header.Meta")$HEADER$SignalSpace %||% getSomaScanVersion(adat)
}


#' Checks the SomaScan version
#'
#' @rdname adat-helpers
#' @param ver `character(1)`. The SomaScan version as a string.
#'   **Note:** the `"v"`-prefix is case *in*sensitive.
#' @examples
#'
#' is.null(checkSomaScanVersion(ver))
#' @return
#'   \item{[checkSomaScanVersion()]}{Returns `NULL` (invisibly) if checks pass.}
#' @export
checkSomaScanVersion <- function(ver) {
  allowed <- c("v4", "v4.0", "v4.1", "v5", "v5.0")
  if ( !tolower(ver) %in% allowed ) {
    stop("Unsupported assay version: ", .value(ver),
         ". Supported versions: ", .value(allowed), call. = FALSE)
  }
  invisible(NULL)
}
