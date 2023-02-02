
# internal helpers similar to `usethis::ui_*()` functions
.value <- function(x) {
  if ( identical(Sys.getenv("TESTTHAT"), "true") ) {
    paste(encodeString(x, quote = "'"), collapse = ", ")
  } else {
    usethis::ui_value(x)
  }
}

.strip_raw_key <- function(x) {
  attr(x, "raw_key") <- NULL
  x
}

.code <- function(x) {
  paste0("\033[90m", encodeString(x, quote = "`"), "\033[39m")
}

# borrow from usethis, cli, and crayon for internal use
# without explicitly importing the package in NAMESPACE file
# avoid R CMD check NOTE:
#   "Namespace in Imports field not imported from: 'pkg'"
.todo <- usethis::ui_todo
.done <- usethis::ui_done
.oops <- usethis::ui_oops
# -------------------------- #
cli_rule  <- cli::rule
# -------------------------- #
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

# attr assignment. `attr(x, y) <- value`. `y` can be unquoted.
`%@@%<-` <- function(x, y, value) {
  name <- as.character(substitute(y))
  attr(x, which = name) <- value
  x
}

# for use with `usethis::use_release_issue`
release_bullets <- function() {
  c(
    "Merge final branch to `master`",
    "Pull auto-generated `README.md` from remote `git pull --rebase`",
    "Re-run checks locally",
    "Bump version number in DESCRIPTION",
    "Update 'NEWS.md'",
    "Submit PR to `release` branch",
    "Merge PR via 'Rebase and merge'",
    "Add next release version tag and follow #37",
    "Add release to public repo 'Releases' via GitHub GUI",
    "Done! :partying_face:",
    ":tada:"
  )
}

checklist <- function() {
  c("Prepare for release:",
    "",
    paste("- [ ]", release_bullets())
  )
}

# Replaces: `usethis::use_release_issue`
# Create a "release issue checklist" in the
# internal SomaLogic repository ...
# will not be seen in the public repo
create_release_issue <- function(ver = NULL) {
  stopifnot(!is.null(ver))
  projfile <- dir(pattern = "[.]Rproj$")
  project  <- gsub("\\.Rproj$", "", projfile)
  .gh <- utils::getFromNamespace("gh", "gh") # avoid the R CMD import warning
  issue <- .gh(
    endpoint = "POST /repos/{owner}/{repo}/issues",
    owner    = "SomaLogic",
    repo     = "SomaDataIO-internal",
    .api_url = "https://api.github.com",
    title    = sprintf("Release %s %s", project, ver),
    body     = paste0(checklist(), "\n", collapse = "")
  )
  if ( interactive() ) {
    Sys.sleep(1)
    utils::browseURL(issue$html_url)
  }
}
