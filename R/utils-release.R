# ------
# functions to create a release checklist issue on GitHub
# ------

# could be used with `usethis::use_release_issue()`
release_bullets <- function(stage = c("prepare", "submit", "wait")) {
  stage <- match.arg(stage)
  if ( stage == "prepare" ) {
    c(
      "Merge all final branch(es) to `main`",
      "Sync forks and `git pull`",
      "Create release candidate branch: `git checkout -b rc-{version}`",
      "Review <https://github.com/DavisVaughan/extrachecks>",
      "Check if any deprecation processes should be advanced, as described in [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)",
      "[Polish NEWS](https://style.tidyverse.org/news.html#news-release) with `cat(usethis:::news_latest(readLines('NEWS.md')))`",
      "`devtools::spell_check()`",
      "`urlchecker::url_check()`",
      "Build README: `make readme`",
      "Update all docs: `make docs`",
      "Re-run checks locally: `make all`",
      "Check revdeps on CRAN",
      "`devtools::check(remote = TRUE, manual = TRUE)`",
      "`rhub::check(platform = 'ubuntu-rchk')`",
      "`devtools::check_win_devel()`",
      "`rhub::check_with_sanitizers()`",
      "`rhub::check_for_cran()`",
      "Update `cran-comments.md`",
      "PR and merge `rc-{version}`"
    )
  } else if ( stage == "submit" ) {
    c(
      "Create a branch: `git checkout -b submit-cran-{version}`",
      "`usethis::use_version('{version_type}')`",
      "Check `NEWS.md` file with update",
      "Update `cran-comments.md` as necessary",
      "`devtools::submit_cran()`",
      "Approve e-mail"
    )
  } else if ( stage == "wait" ) {
    c(
      "Accepted :tada:",
      "`git push public`",
      "Check that `pkgdown` GHA deployed to website",
      "Tag release commit with new tag",
      "`git tag tag -a v{version} -m 'Release of v{version} (CRAN)'`",
      "`git push public v{version}`",
      "Add [Release](https://github.com/SomaLogic/SomaDataIO/releases) via `NEWS.md`",
      "`usethis::use_dev_version(push = FALSE)`",
      "Done! :partying_face:"
    )
  }
}

.ver_type <- function(version) {
  x <- unlist(package_version(version))
  n <- length(x)
  if ( n >= 4 && x[[4L]] != 0L ) {
    "dev"
  } else if ( n >= 3 && x[[3L]] != 0L ) {
    "patch"
  } else if ( n >= 2 && x[[2L]] != 0L ) {
    "minor"
  } else {
    "major"
  }
}

.create_checklist <- function(ver = NULL) {
  stopifnot(!is.null(ver))
  add_bullets <- function(x) paste("- [ ]", x)
  gsub(pattern = "{version}", replacement = ver, perl = TRUE,
    c("## Prepare for release:",
      "",
      add_bullets(release_bullets()),
      "",
      "## Submit to CRAN:",
      "",
      add_bullets(release_bullets("submit")),
      "",
      "## Wait for CRAN ...",
      "",
      add_bullets(release_bullets("wait"))
    )
  ) |>
    gsub(pattern = "{version_type}", replacement = .ver_type(ver), perl = TRUE)
}

# Replaces: `usethis::use_release_issue`
# Create a "release issue checklist" in the
# SomaDataIO public repository ...
create_release_issue <- function(ver = NULL) {
  stopifnot(!is.null(ver))
  projfile <- dir(pattern = "[.]Rproj$")
  # project  <- gsub("\\.Rproj$", "", projfile)
  .gh <- utils::getFromNamespace("gh", "gh") # avoid the R CMD import warning
  issue <- .gh(
    endpoint = "POST /repos/{owner}/{repo}/issues",
    owner    = "SomaLogic",
    repo     = "SomaDataIO",
    .api_url = "https://api.github.com",
    title    = sprintf("Release %s CRAN", ver),
    body     = paste0(.create_checklist(ver), "\n", collapse = "")
  )
  if ( interactive() ) {
    Sys.sleep(1)
    utils::browseURL(issue$html_url)
  }
}
