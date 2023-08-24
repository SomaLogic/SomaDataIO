#' Clean Up Character String
#'
#' Often the names, particularly within `soma_adat` objects,
#' are messy due to varying inputs, this function attempts to remedy this by
#' removing the following:
#'   \itemize{
#'     \item trailing/leading/internal whitespace
#'     \item non-alphanumeric strings (except underscores)
#'     \item duplicated internal dots (`..`), (`...`), etc.
#'     \item SomaScan normalization scale factor format
#'   }
#'
#' @param x Character. String to clean up.
#' @return A cleaned up character string.
#' @seealso [trimws()], [gsub()], [sub()]
#' @author Stu Field
#' @examples
#' cleanNames("    sdkfj...sdlkfj.sdfii4994### ")
#'
#' cleanNames("Hyb..Scale")
#' @export
cleanNames <- function(x) {
  y <- squish(x)                        # zap leading/trailing/internal whitespace
  y <- gsub("[^A-Za-z0-9_]", ".", y)    # zap non-alphanum (keep '_')
  y <- gsub("\\.+", ".", y)             # zap multiple dots
  y <- gsub("^\\.|\\.$", "", y)         # zap leading/trailing dots
  y <- sub("^Hyb[.]Scale", "HybControlNormScale", y)
  sub("^Med[.]Scale", "NormScale", y)
}

squish <- function(x) {
  # zap leading/trailing whitespace & extra internal whitespace
  gsub("[[:space:]]+", " ", trimws(x))
}
