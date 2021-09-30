#' Scale Transform `soma_adat` Columns/Rows
#'
#' Scale the *i-th* row or column of a `soma_adat` object by the *i-th*
#' element of a vector. Designed to transform the SomaLogic `soma_adat` objects
#' and thus only transforms the analyte/RFU entries of the data matrix.
#' If scaling the analytes (columns), `v` *must* have
#' `getAnalytes(adat, n = TRUE)` elements; if scaling the rows,
#' `v` *must* have `nrow(adat)` elements.
#'
#' Performs the following operations (quickly):
#'
#' Columns:
#' \deqn{
#'   M_{nxp} = A_{nxp} * diag(v)_{pxp}
#' }
#' Rows:
#' \deqn{
#'   M_{nxp} = diag(v)_{nxn} * A_{nxp}
#' }
#'
#' @name transform
#' @param _data A `soma_adat` object.
#' @param v A numeric vector of the appropriate length corresponding to `dim`.
#' @param dim Integer. The dimension to apply elements of `v` to.
#' `1` = rows; `2` = columns (default).
#' @param ... Currently not used but required by the S3 generic.
#' @note This method in intentionally naive, and assumes the user has
#' ordered `v` to match the columns/rows of `_data` appropriately.
#' This must be done upstream.
#' @seealso [apply()], [sweep()]
#' @examples
#' # simplified example of underlying operations
#' M <- matrix(1:12, ncol = 4)
#' M
#'
#' v <- 1:4
#' M %*% diag(v)    # transform columns
#'
#' v <- 1:3
#' diag(v) %*% M    # transform rows
#'
#' # dummy ADAT example:
#' v    <- c(2, 0.5)     # double seq1; half seq2
#' adat <- data.frame(sample      = paste0("sample_", 1:3),
#'                    seq.1234.56 = c(1, 2, 3),
#'                    seq.9999.88 = c(4, 5, 6) * 10)
#' adat
#'
#' # `soma_adat` to invoke S3 method dispatch
#' class(adat) <- c("soma_adat", "data.frame")
#' trans <- transform(adat, v)
#' data.frame(trans)
#' @export
transform.soma_adat <- function(`_data`, v, dim = 2, ...) {
  x <- `_data`
  .apts <- getAnalytes(x)
  fx <- function(.x) .x * v
  if ( dim == 2 ) {
    stopifnot(length(v) == length(.apts))   # check cols
    x[, .apts] <- t(apply(x[, .apts], 1, fx))
  } else {
    stopifnot(length(v) == nrow(x))         # check rows
    x[, .apts] <- apply(x[, .apts], 2, fx)
  }
  x
}
