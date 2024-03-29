# ------------------
# check versions of:
#   1)  package required version ('version' -> DESCRIPTION)
#   2)  current installed version ('installed_version' -> system)
#   3)  latest available version ('latest_available' -> CRAN/BioC)
#
# * 'needs_update' if 'installed_version' < 'version'
# ------------------
# Usage:
#   Rscript --vanilla inst/check-pkg-versions.R
# ------------------
# Author:
#   Stu Field
# ------------------

get_deps <- function(path = ".") {
  dcf <- read.dcf(file = file.path(path, "DESCRIPTION"))
  if ( nrow(dcf) < 1L) {
    stop("DESCRIPTION file of package is corrupt.", call. = FALSE)
  }
  desc <- as.list(dcf[1L, ])[c("Depends", "Imports", "Suggests")]
  lapply(desc, parse_deps) |>
    dplyr::bind_rows(.id = "type")
}

parse_deps <- function(deps) {
  deps <- trimws(strsplit(deps, ",")[[1L]])
  deps <- lapply(strsplit(deps, "\\("), trimws)
  deps <- lapply(deps, sub, pattern = "\\)$", replacement = "")
  res <- data.frame(stringsAsFactors = FALSE,
    package = vapply(deps, "[", "", 1L),
    version = vapply(deps, "[", "", 2L)
  )
  res$version <- gsub("\\s+", " ", res$version)
  res$version[is.na(res$version)] <- "*"
  res
}

tbl <- get_deps(".")

tbl$installed_version <- sapply(tbl$package, function(.x) {
  if (.x == "R")
    paste(R.Version()[c("major", "minor")], collapse = ".")
  else
    utils::packageDescription(.x, fields = "Version")
}, USE.NAMES = FALSE)
tbl$installed_version <- package_version(tbl$installed_version)

ver <- gsub("^[^0-9]+", "", tbl$version)
ver[ver == ""] <- "0.0.0.0000"    # set to '0' version if no specified version
# if installed version less than DESCRIPTION (required) version -> must update
tbl$needs_update <- tbl$installed_version < package_version(ver)

latest_r <- readLines("https://cran.rstudio.com/bin/windows/base/release.html")
latest_r <- grep("R-[0-9.]+.+-win\\.exe", latest_r, value = TRUE)
latest_r <- strsplit(latest_r, "-")[[1L]]
latest_r <- grep("[0-9][.][0-9][.][0-9]", latest_r, value = TRUE)

cran <- utils::available.packages(repos = "https://cloud.r-project.org/")
bioc <- utils::available.packages(repos = BiocManager::repositories(version = remotes::bioc_version())[1L])

cran_ver <- sapply(tbl$package, function(.x) {
  if (.x %in% rownames(cran)) {
    cran[.x, "Version"]
  } else if (.x %in% c("R", "methods")) {
    latest_r
  } else if (.x == "Biobase") {
    bioc["Biobase", "Version"]
  }
}, USE.NAMES = FALSE)
tbl$latest_available <- package_version(cran_ver)
tbl <- tibble::as_tibble(tbl)
tbl
