
file <- test_path("testdata", "test-anno.xlsx")

test_that("`ver_dict` is updated and correct", {
  expect_length(ver_dict, 6L)
  expect_named(ver_dict,
               c("SL-99999999-rev99-1999-01",
                 "SL-12345678-rev0-2021-01",
                 "SL-00000571-rev2-2021-06",
                 "SL-00000246-rev5-2021-06",
                 "SL-906-rev3-2024-02",
                 "SL-00000571-rev7-2024-02"))
})

test_that("`getAnnoVer()` parses the version correctly", {
  expect_equal(getAnnoVer(file), "SL-12345678-rev0-2021-01")
})

test_that("`read_annotations()` parses the annotations file correctly", {
  tbl <- read_annotations(file)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(dim(tbl), c(1L, 43L))
  ver <- attr(tbl, "version")
  expect_equal(ver, "SL-12345678-rev0-2021-01")
  expect_true(ver_dict[[ver]]$col_serum == names(tbl)[ver_dict[[ver]]$which_serum])
  expect_true(ver_dict[[ver]]$col_plasma == names(tbl)[ver_dict[[ver]]$which_plasma])
})
