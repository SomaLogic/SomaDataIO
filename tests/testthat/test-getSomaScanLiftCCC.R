test_that("`getSomaScanLiftCCC()` returns expected output for plasma", {
  plasma <- getSomaScanLiftCCC("plasma")
  expect_s3_class(plasma, "tbl_df")
  expect_equal(dim(plasma), c(11083, 4))
  expect_equal(names(plasma), c("SeqId", "plasma_11k_to_5k_ccc",
                                "plasma_11k_to_7k_ccc", "plasma_7k_to_5k_ccc"))
})

test_that("`getSomaScanLiftCCC()` returns expected output for serum", {
  serum <- getSomaScanLiftCCC("serum")
  expect_s3_class(serum, "tbl_df")
  expect_equal(dim(serum), c(11083, 4))
  expect_equal(names(serum), c("SeqId", "serum_11k_to_5k_ccc",
                               "serum_11k_to_7k_ccc", "serum_7k_to_5k_ccc"))
})

test_that("`getSomaScanLiftCCC()` errors given invalid matrix type", {
  expect_error(getSomaScanLiftCCC("citrate"), "should be one of")
})
