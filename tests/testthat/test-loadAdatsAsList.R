
# Setup ----
# this ensures the list.files() call sorts the same across test() and check()
# must set the local collation order
# use 'C', the default during check(); 'en_US.UTF-8' common in SLIDE
withr::local_collate("C")

test_that("the default collation order has been set properly", {
  expect_equal(Sys.getlocale("LC_COLLATE"), "C")
})

files <- system.file("extdata", package = "SomaDataIO", mustWork = TRUE) |>
  list.files(pattern = "[.]adat$", full.names = TRUE)
files <- c(files, test_path("testdata", "single_sample.adat"))
files <- normalizePath(files)
adats <- loadAdatsAsList(files)
foo   <- collapseAdats(adats)
atts  <- attributes(foo)

# Testing ----
test_that("adats list is named properly and has proper dimensions", {
  expect_named(adats, cleanNames(basename(files)))
  expect_snapshot(lapply(adats, dim))
})

# loadAdatsAsList() -----
test_that("throws warning when failure to load adat", {
  expect_snapshot(
    bad <- loadAdatsAsList(c(files, "fail.adat"))
  )
  # failed file names are not returned
  expect_equal(bad, adats)

  # two invalid files
  expect_snapshot(
    bad2 <- loadAdatsAsList(c("a.adat", "b.adat"))
  )
  expect_named(bad2, character(0))
  expect_length(bad2, 0L)
})

test_that("`collapse=` argument works same as `collapseAdats(x)`", {
  foo2 <- loadAdatsAsList(files, collapse = TRUE)
  expect_equal(foo2, foo)
})

test_that("collapsed ADATs dimensions are correct", {
  expect_s3_class(foo, "soma_adat")
  expect_equal(
    dim(foo),
    c(sum(vapply(adats, nrow, 1L)),
      length(Reduce(intersect, lapply(adats, names)))
    )
  )
})

test_that("collapsed ADATs attributes (HEADER) are correctly merged", {
  expect_type(atts, "list")
  expect_named(atts, c("names", "class", "row.names", "Header.Meta",
                       "Col.Meta", "file_specs", "row_meta"))
  expect_named(atts$Header.Meta, c("HEADER", "COL_DATA", "ROW_DATA", "TABLE_BEGIN"))
  expect_snapshot( atts$Header.Meta$HEADER )
})
