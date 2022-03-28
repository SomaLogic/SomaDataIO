# ------------------
# check versions of:
#   1)  current required version (DESCRIPTION)
#   2)  current installed version (system)
#   3)  current available version (CRAN)
# update requierd if installed < required
# ------------------
# Stu Field
# ------------------

tbl <- desc::desc("DESCRIPTION")$get_deps()

tbl$installed_version <- sapply(tbl$package, function(.x) {
  x <- if (.x == "R") getRversion() else packageVersion(.x)
  as.character(x)
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
bioc <- utils::available.packages(repos = BiocManager::repositories()[1L])

cran_ver <- sapply(tbl$package, function(.x) {
  if (.x %in% rownames(cran)) {
    cran[.x, "Version"]
  } else if (.x %in% c("R", "methods")) {
    latest_r
  } else if (.x == "Biobase") {
    bioc["Biobase", "Version"]
  }
}, USE.NAMES = FALSE)
tbl$cran_version <- package_version(cran_ver)
tbl <- tibble::as_tibble(tbl)
tbl
