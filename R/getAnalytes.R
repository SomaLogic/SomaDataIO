#' Get Analytes
#'
#' Return the feature names (i.e. the column names for
#' SOMAmer reagent analytes) from a `soma_adat`.
#' S3 methods also exist for these classes:
#' ```{r method-classes, echo = FALSE}
#' options(width = 80)
#' methods("getAnalytes")
#' ```
#'
#' @param x Typically a `soma_adat` class object created using [read_adat()].
#' @param n Logical. Return an integer corresponding to the *length*
#'   of the features?
#' @param rm.controls Logical. Should all control and non-human analytes
#'   (e.g. `HybControls`, `Non-Human`, `Non-Biotin`, `Spuriomer`) be removed
#'   from the returned value?
#' @return [getAnalytes()]: a character vector of ADAT feature ("analyte") names.
#' @author Stu Field
#' @seealso [is.apt()]
#' @examples
#' # RFU feature variables
#' apts <- getAnalytes(example_data)
#' head(apts)
#' getAnalytes(example_data, n = TRUE)
#'
#' # vector string
#' bb <- getAnalytes(names(example_data))
#' all.equal(apts, bb)
#'
#' # create some control sequences
#' # ~~~~~~~~~ Spuriomer ~~~ HybControl ~~~
#' apts2 <- c("seq.2053.2", "seq.2171.12", head(apts))
#' apts2
#' no_crtl <- getAnalytes(apts2, rm.controls = TRUE)
#' no_crtl
#' setdiff(apts2, no_crtl)
#' @export
getAnalytes <- function(x, n = FALSE, rm.controls = FALSE) UseMethod("getAnalytes")

#' @noRd
#' @export
getAnalytes.default <- function(x, n, rm.controls) {
  stop(
    "Couldn't find a S3 method for this class object: ", .value(class(x)),
    call. = FALSE
  )
}

#' @noRd
#' @export
getAnalytes.data.frame <- function(x, n = FALSE, rm.controls = FALSE) {
  getAnalytes(names(x), n = n, rm.controls = rm.controls)
}

#' @noRd
#' @export
getAnalytes.soma_adat <- getAnalytes.data.frame

#' @noRd
#' @export
getAnalytes.recipe <- function(x, n = FALSE, rm.controls = FALSE) {
  getAnalytes(x$var_info$variable, n = n, rm.controls = rm.controls)
}

#' @noRd
#' @export
getAnalytes.list <- getAnalytes.data.frame

#' @noRd
#' @export
getAnalytes.matrix <- function(x, n = FALSE, rm.controls = FALSE) {
  getAnalytes(colnames(x), n = n, rm.controls = rm.controls)
}

#' S3 getAnalytes method for character
#' @noRd
#' @export
getAnalytes.character <- function(x, n = FALSE, rm.controls = FALSE) {
  lgl <- is.apt(x)
  if ( rm.controls ) {
    lgl <- lgl & !x %in% .getControls()
  }
  if ( n ) {
    sum(lgl)
  } else {
    x[lgl]
  }
}


#' Get Control Analytes (internal)
#'
#' @keywords internal
#' @noRd
.getControls <- function() {
  seqid2apt(
    c(seq_NonBiotin, seq_NonHuman, seq_Spuriomer, seq_HybControlElution)
  )
}


# Standard SeqIds for Control Analytes
seq_HybControlElution <- c(
  "2171-12", "2178-55", "2194-91",
  "2229-54", "2249-25", "2273-34",
  "2288-7", "2305-52", "2312-13",
  "2359-65", "2430-52", "2513-7"
)
seq_Spuriomer <- c(
  "2052-1", "2053-2", "2054-3", "2055-4",
  "2056-5", "2057-6", "2058-7", "2060-9",
  "2061-10", "4666-193", "4666-194", "4666-195",
  "4666-199", "4666-200", "4666-202", "4666-205",
  "4666-206", "4666-212", "4666-213", "4666-214"
)
seq_NonBiotin <- c(
  "3525-1", "3525-2", "3525-3",
  "3525-4", "4666-218", "4666-219",
  "4666-220", "4666-222", "4666-223", "4666-224")
seq_NonHuman <- c(
  "16535-61", "3507-1", "3512-72", "3650-8", "3717-23",
  "3721-5", "3724-64", "3742-78", "3849-56", "4584-5",
  "8443-9", "8444-3", "8444-46", "8445-184", "8445-54",
  "8449-103", "8449-124", "8471-53", "8481-26", "8481-44",
  "8482-39", "8483-5")
seq_NonCleavable <- c("4666-225", "4666-230", "4666-232", "4666-236")
