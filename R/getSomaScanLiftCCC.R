#' @rdname adat-helpers
#'
#' @description
#' [getSomaScanLiftCCC()] accesses the lifting Concordance Correlation
#'   Coefficients between various SomaScan versions. For more about
#'   CCC metrics see [lift_adat()].
#'
#' @inheritParams params
#' @references Lin, Lawrence I-Kuei. 1989. A Concordance Correlation
#'   Coefficient to Evaluate Reproducibility. __Biometrics__. 45:255-268.
#' @return
#'   \item{[getSomaScanLiftCCC()]}{Returns a tibble of either the
#'   `serum` or `plasma` CCC between various versions of the SomaScan assay.}
#' @examples
#'
#' # plasma (default)
#' getSomaScanLiftCCC()
#'
#' # serum
#' getSomaScanLiftCCC("serum")
#' @export
getSomaScanLiftCCC <- function(matrix = c("plasma", "serum")) {
  matrix <- match.arg(matrix)
  dplyr::select(lift_master, SeqId,
                dplyr::starts_with(matrix) & dplyr::ends_with("ccc"))
}
