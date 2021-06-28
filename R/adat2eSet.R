#' Convert ADAT to ExpressionSet Object
#'
#' Utility to convert a SomaLogic `soma_adat` object to an
#' `ExpressionSet` object via the \pkg{Biobase} package
#' (download from `"Bioconductor"`).
#'
#' The \pkg{Biobase} package is required and must be installed from
#' `Bioconductor` via the following at the R console:
#' ```
#' if (!requireNamespace("BiocManager", quietly = TRUE)) {
#'   install.packages("BiocManager")
#' }
#' BiocManager::install("Biobase", version = "3.13")
#' ```
#'
#' @param adat A `soma_adat` class object as read into the R
#' environment using [read_adat()].
#' @return A Bioconductor object of class `ExpressionSet`.
#' @author Stu Field
#' @seealso [pivotExpressionSet()]
#' @references \url{https://bioconductor.org/install/}
#' @examples
#' eSet <- adat2eSet(example_data)
#' class(eSet)
#' eSet
#'
#' ft <- Biobase::exprs(eSet)
#' head(ft[, 1:10], 10)
#' @importFrom usethis ui_stop
#' @importFrom methods validObject new
#' @export
adat2eSet <- function(adat) {

  if ( !requireNamespace("Biobase", quietly = TRUE) ) {
    usethis::ui_stop(
      "The `Biobase` package is required to use this function.
      See ?adat2eSet for installation instructions."
    )
  }

  stopifnot(is.intact.attributes(adat))
  atts        <- attributes(adat)
  apts        <- getAnalytes(adat)
  lst         <- list()
  lst$fdata   <- data.frame(getAnalyteInfo(adat)) %>% col2rn("AptName")
  class(adat) <- "data.frame"
  lst$pdata   <- adat[, setdiff(names(adat), apts), drop = FALSE]
  lst$header  <- atts$Header.Meta$HEADER
  lst$exprs   <- adat[, apts, drop = FALSE]

  f_df  <- data.frame(labelDescription = gsub("\\.", " ", names(lst$fdata)),
                      row.names = names(lst$fdata),  stringsAsFactors = FALSE)
  # partial match wraning from inside `new()`; along -> along.with
  fdata <- new("AnnotatedDataFrame", data = lst$fdata, varMetadata = f_df)
  p_df  <- data.frame(labelDescription = gsub("\\.", " ", names(lst$pdata)),
                      row.names = names(lst$pdata), stringsAsFactors = FALSE)
  pdata <- new("AnnotatedDataFrame", data = lst$pdata, varMetadata = p_df)
  m_df  <- data.frame(labelDescription = gsub("_", " ", colnames(pdata)))
  eset  <- t(lst$exprs) %>%
    Biobase::ExpressionSet(varMetadata = m_df,
                           featureData = fdata,
                           phenoData   = pdata)

  experimentData       <- Biobase::experimentData(eset)
  experimentData@name  <- if ("AssayType" %in% names(lst$header)) lst$header$AssayType else ""
  experimentData@lab   <- "SomaLogic, Inc."
  experimentData@contact <- "2945 Wilderness Place, Boulder, Colorado, 80301."
  experimentData@title <- if ("Title" %in% names(lst$header)) lst$header$Title else ""
  experimentData@url   <- "www.somalogic.com"
  experimentData@other <- c(list(R.version  = R.version$version.string,
                                 R.platform = R.version$platform,
                                 R.arch     = R.version$arch),
                            lst$header,
                            list(processingDateTime = as.character(Sys.time()))
                            )
  Biobase::experimentData(eset) <- experimentData

  if ( !validObject(eset) ) {
    usethis::ui_stop(
      "The `ExpressionSet` object was created but is invalid."
    )
  }

  eset
}
