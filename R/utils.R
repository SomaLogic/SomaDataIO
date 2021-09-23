
# borrow cli::rule() for internal use
rule <- getFromNamespace("rule", ns = "cli")

# borrow usethis::ui_value() for internal use
value <- getFromNamespace("ui_value", ns = "usethis")

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
