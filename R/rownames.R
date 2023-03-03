#' Helpers for Working With Row Names
#'
#' Easily move row names to a column and vice-versa without the unwanted
#' side-effects to object class and attributes. Drop-in replacement for
#' `tibble::rownames_to_column()` and `tibble::column_to_rownames()` which
#' can have undesired side-effects to complex object attributes.
#' Does not import any external packages, modify the environment, or change
#' the object (other than the desired column). When using [col2rn()], if
#' explicit row names exist, they are overwritten with a warning. [add_rowid()]
#' does *not* affect row names, which differs from `tibble::rowid_to_column()`.
#'
#' @name rownames
#' @param data An object that inherits from class `data.frame`. Typically
#'   a `soma_adat` class object.
#' @param name Character. The name of the column to move.
#' @param value Character. The new set of names for the data frame.
#'   If duplicates exist they are modified on-the-fly via [make.unique()].
#' @return All functions attempt to return an object of the same class as
#'   the input with fully intact and unmodified attributes (aside from those
#'   required by the desired action). [has_rn()] returns a scalar logical.
#' @examples
#' df <- data.frame(a = 1:5, b = rnorm(5), row.names = LETTERS[1:5])
#' df
#' rn2col(df)              # default name is `.rn`
#' rn2col(df, "AptName")   # pass `name =`
#'
#' # moving columns
#' df$mtcars <- sample(names(mtcars), 5)
#' col2rn(df, "mtcars")   # with a warning
#'
#' # Move back and forth easily
#' # Leaves original object un-modified
#' identical(df, col2rn(rn2col(df)))
#'
#' # add "id" column
#' add_rowid(mtcars)
#'
#' # remove row names
#' has_rn(mtcars)
#' mtcars2 <- rm_rn(mtcars)
#' has_rn(mtcars2)
NULL


#' @describeIn rownames
#'   moves the row names of `data` to an explicit column
#'   whether they are explicit or implicit.
#' @export
rn2col <- function(data, name = ".rn") {
  stopifnot(is.data.frame(data), length(name) == 1L)
  nc <- ncol(data)
  data[[name]] <- rownames(data)
  data <- data[, c(nc + 1L, seq_len(nc))]
  rm_rn(data)
}

#' @describeIn rownames
#'   is the inverse of [rn2col()]. If row names exist, they
#'   will be overwritten (with warning).
#' @export
col2rn <- function(data, name = ".rn") {
  stopifnot(is.data.frame(data), length(name) == 1L)
  if ( has_rn(data) ) {
    warning(
      "`data` already has assigned row names. They will be over-written.",
      call. = FALSE
    )
  }
  # in case values are duplicated
  rownames(data) <- make.unique(as.character(data[[name]]), "-")
  data[[name]]   <- NULL
  data
}

#' @describeIn rownames
#'   returns a boolean indicating whether the data frame
#'   has explicit row names assigned.
#' @export
has_rn <- function(data) {
  .row_names_info(data, 1L) > 0L && !is.na(.row_names_info(data, 0L)[[1L]])
}

# does the data frame have implicit rownames?
implicit_rn <- function(data) {
  .row_names_info(data, 1L) < 0L
}

#' @describeIn rownames
#'   removes existing row names, leaving only "implicit" row names.
#' @export
rm_rn <- function(data) {
  stopifnot(is.data.frame(data))
  rownames(data) <- NULL
  data
}

#' @describeIn rownames
#'   sets (and overwrites) existing row names for data frames only.
#' @export
set_rn <- function(data, value) {
  stopifnot(is.data.frame(data))
  if ( any(duplicated(value)) ) {
    value <- make.unique(value, sep = "-")
  }
  rownames(data) <- value
  data
}

#' @describeIn rownames
#'   adds a sequential integer row identifier; starting at `1:nrow(data)`.
#'   It does *not* remove existing row names currently, but may in the future
#'   (please code accordingly).
#' @export
add_rowid <- function(data, name = ".rowid") {
  stopifnot(is.data.frame(data), length(name) == 1L)
  nc <- ncol(data)
  data[[name]] <- seq_len(nrow(data))
  data <- data[, c(nc + 1L, seq_len(nc))]
  data
}
