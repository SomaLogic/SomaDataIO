#' The `soma_adat` Class and S3 Methods
#'
#' The `soma_adat` data structure is the primary internal `R` representation
#' of SomaScan data. A `soma_adat` is automatically created via [read_adat()]
#' when loading a `*.adat` text file. It consists of a `data.frame`-like
#' object with leading columns as clinical variables and SomaScan RFU data
#' as the remaining variables. Two main attributes corresponding to analyte
#' and SomaScan run information contained in the `*.adat` file are added:
#' \itemize{
#'   \item `Header.Meta`: information about the SomaScan run, see [parseHeader()]
#'     or `attr(x, "Header.Meta")`
#'   \item `Col.Meta`: annotations information about the SomaScan reagents/analytes,
#'     see [getAnalyteInfo()] or `attr(x, "Col.Meta")`
#'   \item `file_specs`: parsing specifications for the ingested `*.adat` file
#'   \item `row_meta`: the names of the non-RFU fields. See [getMeta()].
#' }
#' See [groupGenerics()] for a details on [Math()], [Ops()], and [Summary()]
#' methods that dispatch on class `soma_adat`.
#' \cr\cr
#' See [reexports()] for a details on re-exported S3 generics from other
#' packages (mostly `dplyr` and `tidyr`) to enable S3 methods to be
#' dispatched on class `soma_adat`.
#' \cr\cr
#' Below is a list of *all* currently available S3 methods that dispatch on
#' the `soma_adat` class:
#' ```{r methods, echo = FALSE}
#' options(width = 70)
#' withr::with_collate("en_US.UTF-8", methods(class = "soma_adat"))
#' ```
#'
#' @family IO
#' @name soma_adat
#' @order 1
#' @param x,object A `soma_adat` class object.
#' @return The set of S3 methods above return the `soma_adat` object with
#'   the corresponding S3 method applied.
#' @seealso [groupGenerics()]
NULL


# Extraction ----

#' S3 extract method for class `soma_adat`.
#'
#' The S3 [Extract()] method is used for sub-setting a `soma_adat`
#' object and relies heavily on the `[` method that maintains the `soma_adat`
#' attributes intact *and* subsets the `Col.Meta` so that it is consistent
#' with the newly created object.
#'
#' @rdname soma_adat
#' @param i,j Row and column indices respectively. If `j` is omitted,
#'   `i` is used as the column index.
#' @param ... Ignored.
#' @param drop Coerce to a vector if fetching one column via `tbl[, j]`.
#'   Default `FALSE`, ignored when accessing a column via `tbl[j]`.
#' @export
`[.soma_adat` <- function(x, i, j, drop = TRUE, ...) {

  if ( missing(j) ) {
    # not sub-setting columns
    return(NextMethod())
  } else if ( is_intact_attr(x) ) {
    # sub-setting columns & attributes to worry about
    if ( length(j) == 1L && j > 0 ) {
      # if extracting a single column
      # this behavior may change one day to match `tibbles`
      # where you output is what you input, i.e. `drop = FALSE` by default
      return(NextMethod(drop = drop))
    } else {
      atts <- attributes(x)
    }
  } else {
    # if attributes already broken
    return(NextMethod())
  }

  apts <- getAnalytes(x)

  if ( is.character(j) ) {
    # Character case
    k <- match(j[j %in% apts], apts)
  } else if ( is.numeric(j) || is.logical(j) ) {
    # Integer/Logical case
    # this is tricky
    # must figure out which numeric indices are feature data; which meta data
    k <- getAnalytes(names(x)[j]) |> match(apts)
  }

  # Update the attributes -> Col.Meta information
  atts$Col.Meta <- atts$Col.Meta[k, ]
  .data <- addAttributes(NextMethod(), atts)
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  .data
}


#' S3 extract with `$`
#'
#' S3 extraction via `$` is fully supported, however,
#' as opposed to the `data.frame` method, partial matching
#' is *not* allowed for class `soma_adat`.
#'
#' @rdname soma_adat
#' @param name A [name] or a string.
#' @export
`$.soma_adat` <- function(x, name) {
  if ( is.character(name) ) {
    ret <- .subset2(x, name)
    if ( is.null(ret) ) {
      warning(
        "Unknown or uninitialised column: '", name, "'", call. = FALSE
      )
    }
    return(ret)
  }
  .subset2(x, name)
}


#' S3 extract with `[[`
#'
#' S3 extraction via `[[` is supported, however, we restrict
#' the usage of `[[` for `soma_adat`. Use only a numeric index (e.g. `1L`)
#' or a character identifying the column (e.g. `"SampleID"`).
#' Do not use `[[i,j]]` syntax with `[[`, use `[` instead.
#' As with `$`, partial matching is *not* allowed.
#'
#' @rdname soma_adat
#' @param exact Ignored with a [warning()].
#' @export
`[[.soma_adat` <- function(x, i, j, ..., exact = TRUE) {
  if ( !exact ) {
    warning("`exact=` is ignored in `[[`.", call. = FALSE)
  }
  if ( !missing(j) ) {
    stop(
      "Passing jth column index not supported via `[[` for `soma_adat`.\n",
      "Please use `x[", deparse(substitute(i)), ", ", deparse(substitute(j)),
      "]` instead.", call. = FALSE
    )
  }
  return(`$.soma_adat`(x, i))
}


# Assignment ----

#' S3 assignment with `[`
#'
#' S3 assignment via `[` is supported for class `soma_adat`.
#'
#' @rdname soma_adat
#' @param value A value to store in a row, column, range or cell.
#' @export
`[<-.soma_adat` <- function(x, i, j, ..., value) {
  anames <- names(attributes(x))
  .data  <- NextMethod()
  attributes(.data) <- attributes(.data)[anames]   # re-order back to original
  .data
}

#' S3 assignment with `$`
#'
#' S3 assignment via `$` is fully supported for class `soma_adat`.
#'
#' @rdname soma_adat
#' @export
`$<-.soma_adat` <- `[<-.soma_adat`


#' S3 assignment with `[[`
#'
#' S3 assignment via `[[` is supported for class `soma_adat`.
#'
#' @rdname soma_adat
#' @export
`[[<-.soma_adat` <- `[<-.soma_adat`


#' S3 `median` method
#'
#' S3 [median()] is *not* currently supported for the `soma_adat` class,
#' however a dispatch is in place to direct users to alternatives.
#'
#' @rdname soma_adat
#' @importFrom stats median
#' @inheritParams stats::median
#' @export
median.soma_adat <- function(x, na.rm = FALSE, ...) {
  warning(
    "As with the `data.frame` class, numeric data is required for `stats::median()`.\n",
    "Please use either:\n\n   ",
    .code("median(data.matrix(x[, getAnalytes(x)]))"),
    "\nOR\n   ",
    .code("apply(x[, getAnalytes(x)] 2, median)"), call. = FALSE
  )
  invisible()
}
