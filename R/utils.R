
# internal helpers similar to `usethis` functions
.value <- function(x) {
  if ( identical(Sys.getenv("TESTTHAT"), "true") ) {
    paste(encodeString(x, quote = "'"), collapse = ", ")
  } else {
    cli::cli_text("{.val {x}}")
  }
}

.strip_raw_key <- function(x) {
  attr(x, "raw_key") <- NULL
  x
}

.code <- function(x) {
  paste0("\033[90m", encodeString(x, quote = "`"), "\033[39m")
}

# borrow from cli for internal use
# without explicitly importing the package in NAMESPACE file
# avoid R CMD check NOTE:
#   "Namespace in Imports field not imported from: 'pkg'"
.todo <- cli::cli_alert
.done <- cli::cli_alert_success
.oops <- cli::cli_alert_danger
# -------------------------- #
cli_rule  <- cli::rule
# -------------------------- #
cr_bold   <- cli::style_bold
cr_green  <- cli::col_green
cr_cyan   <- cli::col_cyan
cr_red    <- cli::col_red
cr_blue   <- cli::col_blue
cr_yellow <- cli::col_yellow


# wrapper around padding; default to right side padding
.pad <- function(x, width, side = c("right", "left")) {
  side <- match.arg(side)
  just <- switch(side, right = "left", left = "right")
  encodeString(x, width = width, justify = just)
}

# friendly version of ifelse
`%||%` <- function(x, y) {
  if ( is.null(x) || length(x) <= 0L ) {
    y
  } else {
    x
  }
}

# kinder version of identical
`%==%` <- function(x, y) {
  isTRUE(all.equal(x, y))
}

# easily test inequality of R objects
`%!=%` <- function(x, y) {
  !isTRUE(all.equal(x, y))
}

# A friendly version of `attr(x, y)`. `y` can be unquoted.
`%@@%` <- function(x, y) {
  name <- as.character(substitute(y))
  attr(x, which = name, exact = TRUE)
}
