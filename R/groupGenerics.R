#' Group Generics for `soma_adat` Class Objects
#'
#' S3 group generic methods to apply group specific prototype functions
#' to the RFU data __only__ of `soma_adat` objects.
#' The clinical meta data are *not* transformed and remain unmodified in
#' the returned object ([Math()] and [Ops()]) or are ignored for the
#' [Summary()] group. See [groupGeneric()].
#'
#' @section Math:
#' Group members:
#' ```{r math, echo = FALSE}
#' options(width = 80)
#' withr::with_collate("en_US.UTF-8", sort(getGroupMembers("Math")))
#' ```
#' Commonly used generics of this group include:
#'   * `log()`, `log10()`, `log2()`, `antilog()`,
#'     `abs()`, `sign()`, `floor()`, `sqrt()`, `exp()`
#'
#' @section Ops:
#' Group members:
#' ```{r ops, echo = FALSE}
#' options(width = 80)
#' c(getGroupMembers("Arith"), getGroupMembers("Compare"))
#' ```
#' Note that for the \verb{`==`} method if the RHS is also a `soma_adat`,
#' [diffAdats()] is invoked which compares LHS vs. RHS.
#' Commonly used generics of this group include:
#'   * `+`, `-`, `*`, `/`, `^`, `==`, `>`, `<`
#'
#' @section Summary:
#' Group members:
#' ```{r summary, echo = FALSE}
#' options(width = 80)
#' withr::with_collate("en_US.UTF-8", sort(getGroupMembers("Summary")))
#' ```
#' Commonly used generics of this group include:
#'   * `max()`, `min()`, `range()`, `sum()`, `any()`
#'
#' @name groupGenerics
#' @param x The `soma_adat` class object to perform the transformation.
#' @param e1,e2 Objects.
#' @param na.rm Logical. Should missing values be removed?
#' @param base A positive or complex number: the base with respect to
#'   which logarithms are computed.
#' @param ... Additional arguments passed to the various group generics
#'   as appropriate.
#' @return A `soma_adat` object with the same dimensions of the input
#'   object with the feature columns transformed by the specified generic.
#' @author Stu Field
#' @seealso [groupGeneric()], [getGroupMembers()], [getGroup()]
#' @examples
#' # subset `example_data` for speed
#' # all SeqIds from 2000 -> 2999
#' seqs <- grep("^seq\\.2[0-9]{3}", names(example_data), value = TRUE)
#' ex_data_small <- head(example_data[, c(getMeta(example_data), seqs)], 10L)
#' dim(ex_data_small)
#'
#' ex_data_small$seq.2991.9
#'
#' # Math Generics:
#' # -------------
#' # log-transformation
#' a <- log(ex_data_small)
#' a$seq.2991.9
#'
#' b <- log10(ex_data_small)
#' b$seq.2991.9
#' isTRUE(all.equal(b, log(ex_data_small, base = 10)))
#'
#' # floor
#' c <- floor(ex_data_small)
#' c$seq.2991.9
#'
#' # square-root
#' d <- sqrt(ex_data_small)
#' d$seq.2991.9
#'
#' # rounding
#' e <- round(ex_data_small)
#' e$seq.2991.9
#'
#' # inverse log
#' antilog(1:4)
#'
#' alog <- antilog(b)
#' all.equal(ex_data_small, alog)    # return `b` -> linear space
#'
#' # Ops Generics:
#' # -------------
#' plus1 <- ex_data_small + 1
#' times2 <- ex_data_small * 2
#'
#' sq <- ex_data_small^2
#' all.equal(sqrt(sq), ex_data_small)
#'
#' gt100k <- ex_data_small > 100000
#' gt100k
#'
#' ex_data_small == ex_data_small   # invokes diffAdats()
#'
#' # Summary Generics:
#' # -------------
#' sum(ex_data_small)
#'
#' any(ex_data_small < 100)  # low RFU analytes
#'
#' sum(ex_data_small < 100)  # how many
#'
#' min(ex_data_small)
#'
#' min(ex_data_small, 0)
#'
#' max(ex_data_small)
#'
#' max(ex_data_small, 1e+7)
#'
#' range(ex_data_small)
#' @export
Math.soma_adat <- function(x, ...) {
  .apts   <- getAnalytes(x)
  class   <- class(x)
  mode_ok <- vapply(x[, .apts], function(.x) is.numeric(.x) || is.complex(.x), NA)
  if ( all(mode_ok) ) {
    x[, .apts] <- lapply(X = x[, .apts], FUN = .Generic, ...)
  } else {
    stop(
      "Non-numeric variable(s) in `soma_adat` object ",
      "where RFU values should be: ",
      .value(names(x[, .apts])[!mode_ok]), ".", call. = FALSE
    )
  }
  structure(x, class = class)
}

#' @describeIn groupGenerics
#'   performs the inverse or anti-log transform for a numeric vector of
#'   `soma_adat` object. **note:** default is `base = 10`, which differs from
#'   the [log()] default base *e*.
#' @importFrom methods setGeneric
#' @export
setGeneric(
  name  = "antilog",
  def   = function(x, base = 10) exp(x * log(base)),
  group = "Math"
)

#' @describeIn groupGenerics
#'   performs binary mathematical operations on class `soma_adat`. See [Ops()].
#' @export
Ops.soma_adat <- function(e1, e2 = NULL) {
  if ( is.soma_adat(e2) ) {
    stop(
      "The RHS (", .value(deparse(substitute(e2))), ") of `",
      .Generic, "` cannot be a `soma_adat` class.",
      call. = FALSE)
  }
  .apts <- getAnalytes(e1)
  e1[, .apts] <- do.call(.Generic, list(e1 = data.frame(e1[, .apts]), e2 = e2))
  e1
}

#' @describeIn groupGenerics
#'   performs summary calculations on class `soma_adat`. See [Summary()].
#' @export
Summary.soma_adat <- function(..., na.rm = FALSE) {
  args <- lapply(list(...), function(x) {
    if ( is.soma_adat(x) ) {
      data.matrix(x[, getAnalytes(x)])
      .apts <- getAnalytes(x)
      rfu <- x[, .apts]
      mode_ok <- vapply(rfu, function(.x) {
        is.numeric(.x) || is.complex(.x) || is.logical(.x)
      }, NA)
      if ( !all(mode_ok) ) {
        warning(
          "Non-numeric variable(s) detected in `soma_adat` object ",
          "where RFU values should be. Removing: ",
          .value(names(rfu[, .apts])[!mode_ok]), ".", call. = FALSE
        )
      }
      data.matrix(rfu[, mode_ok])
    } else if ( !is.numeric(x) && !is.logical(x) && !is.complex(x) ) {
      stop("`", .Generic, "()`",
         " is only defined on a `soma_adat` with all numeric-alike variables.",
         call. = FALSE
      )
    } else {
      x
    }
  })
  do.call(.Generic, c(args, na.rm = na.rm))
}

#' @describeIn groupGenerics
#'   compares left- and right-hand sides of the operator *unless* the RHS
#'   is also a `soma_adat`, in which case [diffAdats()] is invoked.
#' @export
`==.soma_adat` <- function(e1, e2) {  # nolint: bad name
  if ( is.soma_adat(e2) ) {
    diffAdats(e1, e2)
  } else {
    .apts <- getAnalytes(e1)
    e1[, .apts] <- do.call(.Generic, list(e1 = data.frame(e1[, .apts]), e2 = e2))
    e1
  }
}

#' @importFrom lifecycle deprecate_stop
#' @method Math soma.adat
#' @export
Math.soma.adat <- function(x, ...) {
  .msg <- paste(
    "The", .value("soma.adat"), "class is now", .value("soma_adat"), ".\n",
    "Please either:\n",
    "  1) Re-class with x <- addClass(x, 'soma_adat')\n",
    "  2) Re-call 'x <- read_adat(file)' to pick up the new 'soma_adat' class.\n"
  )
  cat(.msg)
  deprecate_stop("(2019-01-31)", "SomaDataIO::Math.soma.adat()")
}
