
file <- test_path("testdata", "test-anno.xlsx")

test_that("getAnnoVer() parses the version correctly", {
  expect_equal(getAnnoVer(file), "SL-12345678-rev0-2021-01")
})

test_that("readAnnotations() parses the annotations file correctly", {
  tbl <- readAnnotations(file)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(dim(tbl), c(1, 43))
  expect_equal(attr(tbl, "md5sha"), "8a345fa621377d0bac40fc8c47f5579d")
  expect_equal(attr(tbl, "version"), "SL-12345678-rev0-2021-01")
})
