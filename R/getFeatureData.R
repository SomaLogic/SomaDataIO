#' Get Feature Data (tibble)
#'
#' Uses the Column Meta data (meta data that appears above the protein
#' measurements in the adat file) from the intact attributes of an ADAT and
#' compiles them into a `tibble` ([tibble()]) object for simple 
#' manipulation and indexing. The Feature names of the ADAT become the 
#' first column named `AptName`.
#'
#' @param adat An ADAT with intact attributes (i.e. has not been modified thus
#' stripping original attributes), typically created using [read_adat()].
#' @return A [tibble()] with columns corresponding to the column meta
#' data entries in the ADAT. The tibble has a designated column "AptName"
#' corresponding to the features in the ADAT, which can be retrieved using
#' [getFeatures()]. This column can be use for indexing desired analytes.
#' @author Stu Field
#' @seealso [getFeatures()]
#' @examples
#' # Attribute check
#' is.intact.attributes(sample.adat)   # must be TRUE
#'
#' # Get feature table
#' tbl <- getFeatureData(sample.adat)
#' head(tbl)                    # First few rows of the data.frame
#' table(tbl$Dilution)          # Print number of features in each dilution.
#' choose5 <- sample(1:nrow(tbl), 5)  # Get 5 random rows (features)
#' tbl[ choose5, ]              # Print feature data for these 5
#' @importFrom usethis ui_stop
#' @importFrom tibble as_tibble
#' @export getFeatureData
getFeatureData <- function(adat) {
  stopifnot(is.intact.attributes(adat))
  apt_data <- attributes(adat)$Col.Meta %>% tibble::as_tibble()
  names(apt_data) %<>% cleanNames()
  if ( "Dilution" %in% names(apt_data) ) {
    apt_data %<>%
      dplyr::mutate(Dilution2 = stringr::str_remove_all(Dilution, 
                                                 "%$|Mix ") %>% as.numeric / 100)
  }
  apt_data %<>%
    dplyr::mutate(AptName = getAptamers(adat)) %>%
    dplyr::select(AptName, dplyr::everything())
  if ( !isTRUE(all.equal(apt_data$AptName %>% getSeqId(TRUE), 
                         apt_data$SeqId %>% getSeqId(TRUE))))
    usethis::ui_stop(
      "Feature ordering inconsistent in `AptName` vs \\
      `SeqId` during `getFeatureData()` call."
    )
  apt_data %<>% makeNumeric()
  apt_data$Dilution %<>% as.character()
  apt_data
}
