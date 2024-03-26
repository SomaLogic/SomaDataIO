# ------
# functions to create a release checklist issue on GitHub
# ------

.bullets <- function(stage = c("prepare", "submit", "wait")) {
  stage <- match.arg(stage)
  if ( stage == "prepare" ) {
    c(
      "Merge final branch(es) to `main`",
      "Sync forks and `git pull --rebase`",
      "Create release candidate branch: `git checkout -b rc-{version}`",
      "Review [extrachecks](https://github.com/DavisVaughan/extrachecks)",
      "Check if any deprecation processes should be advanced:",
      "  [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)",
      "[Polish NEWS.md](https://style.tidyverse.org/news.html#news-release)",
      "  `cat(usethis:::news_latest(readLines('NEWS.md')))`",
      "`devtools::spell_check()`",
      "`urlchecker::url_check()`",
      "Build `README`:",
      "  `make readme`",
      "  `devtools::build_readme()`",
      "Update roxygen docs: `make docs`",
      "Run local checks: `make check`",
      "Check revdeps on CRAN",
      "Remote checks:",
      "  `devtools::check(remote = TRUE, manual = TRUE)`",
      "  `rhub::check(platform = 'ubuntu-rchk')`",
      "  `devtools::check_win_devel()`",
      "  `rhub::check_with_sanitizers()`",
      "  `rhub::check_for_cran()`",
      "Update `cran-comments.md` accordingly",
      "PR and merge `rc-{version}`"
    )
  } else if ( stage == "submit" ) {
    c(
      "Create a submission branch: `git checkout -b submit-cran-{version}`",
      "Bump version: `usethis::use_version('{version_type}')`",
      "Check `NEWS.md` file was updated and is correct",
      "Update `cran-comments.md` as necessary",
      "`devtools::submit_cran()`",
      "Approve :email:"
    )
  } else if ( stage == "wait" ) {
    c(
      "Accepted :tada:",
      "`git push public/main` :pushpin:",
      "Check that `pkgdown` was deployed to website via GitHub Action",
      "Tag release commit with new tag:",
      "  `git tag tag -a v{version} -m 'Release of v{version}'`",
      "  `git push public v{version}`",
      "Add [Release](https://github.com/SomaLogic/SomaDataIO/releases) from `NEWS.md`",
      "Bump version to dev: `usethis::use_dev_version(push = FALSE)`",
      "Done! :partying_face:"
    )
  }
}

.ver_type <- function(ver) {
  x <- unlist(package_version(ver))
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

.taskbox <- function(.x) {
  sub("^([[:space:]]*)(.*)$", "\\1- [ ] \\2", .x)
}

.create_checklist <- function(ver = NULL) {
  stopifnot(!is.null(ver))
  gsub(pattern = "{version}", replacement = ver, perl = TRUE,
    c("## Prepare for release :hot_face:",
      "",
      .taskbox(.bullets()),
      "",
      "## Submit to CRAN :crossed_fingers:",
      "",
      .taskbox(.bullets("submit")),
      "",
      "## Wait for CRAN ... :sleeping:",
      "",
      .taskbox(.bullets("wait"))
    )
  ) |>
    gsub(pattern = "{version_type}", replacement = .ver_type(ver), perl = TRUE)
}

# Replaces: `usethis::use_release_issue`
# Create a "release issue checklist" in the
# SomaDataIO public repository ...
create_release_issue <- function(ver = NULL) {
  stopifnot("Must pass a version to `create_release_issue()`." = !is.null(ver))
  # projfile <- dir(pattern = "[.]Rproj$")
  # project  <- gsub("\\.Rproj$", "", projfile)
  .gh <- utils::getFromNamespace("gh", "gh") # avoid the R CMD import warning
  issue <- .gh(
    endpoint = "POST /repos/{owner}/{repo}/issues",
    owner    = "SomaLogic",
    repo     = "SomaDataIO",
    .api_url = "https://api.github.com",
    title    = sprintf("Release SomaDataIO %s", ver),
    body     = paste0(.create_checklist(ver), "\n", collapse = "")
  )
  if ( interactive() ) {
    Sys.sleep(1)
    utils::browseURL(issue$html_url)
  }
}
