
file <- test_path("testdata", "test-anno.xlsx")

test_that("getAnnoVer() parses the version correctly", {
  expect_equal(getAnnoVer(file), "SL-12345678-rev0-2021-01")
})

test_that("read_annotations() parses the annotations file correctly", {
  tbl <- read_annotations(file)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(dim(tbl), c(1L, 43L))
  ver <- attr(tbl, "version")
  expect_equal(ver, "SL-12345678-rev0-2021-01")
  expect_true(ver_dict[[ver]]$col_serum == names(tbl)[ver_dict[[ver]]$which_serum])
  expect_true(ver_dict[[ver]]$col_plasma == names(tbl)[ver_dict[[ver]]$which_plasma])
})
