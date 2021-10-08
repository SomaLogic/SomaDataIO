
# borrow from usethis, cli, and crayon for internal use
# without explicitly importing the package in NAMESPACE file
# avoid R CMD check NOTE:
#   "Namespace in Imports field not imported from: 'pkg'"
.value    <- function(x) usethis::ui_value(x)
.todo     <- usethis::ui_todo
.done     <- usethis::ui_done
.oops     <- usethis::ui_oops
.info     <- usethis::ui_info
.code     <- usethis::ui_code
cli_rule  <- cli::rule
cr_bold   <- crayon::bold
cr_green  <- crayon::green
cr_cyan   <- crayon::cyan
cr_red    <- crayon::red
cr_blue   <- crayon::blue
cr_yellow <- crayon::yellow


# wrapper around padding; default to right side padding
.pad <- function(x, width, side = c("right", "left")) {
  side <- match.arg(side)
  just <- switch(side, right = "left", left = "right")
  encodeString(x, width = width, justify = just)
}

# trim leading/trailing empty strings in header block
# trap case: "key\tvalue\t\t\t\t\t\t\t" -> "key\tvalue"
trim_empty <- function(x, side) {
  x <- paste(x, collapse = "\t")    # collapse key-value row to single string
  trim <- trimws(x, which = side)   # trim tabs/whitespace; Col.Meta trim left
  strsplit(trim, "\t", fixed = TRUE)[[1L]] # now a single key-value pair
}

# kinder version of identical
`%equals%` <- function(x, y) {
  isTRUE(all.equal(x, y))
}
