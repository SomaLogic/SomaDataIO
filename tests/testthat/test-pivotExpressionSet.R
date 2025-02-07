
# Setup -----
if ( rlang::is_installed("Biobase") ) {
  sub_adat <- example_data[1:10, c(1:5, 35:37)]
  long     <- pivotExpressionSet(adat2eSet(sub_adat))
}

# Testing ----
test_that("pivotExpressionSet() returns the correct class and dimensions", {
  testthat::skip_if_not_installed("Biobase")
  expect_s3_class(long, "tbl_df")
  expect_equal(dim(long), c(30, 29))
})

test_that("pivotExpressionSet() returns expected metadata columns", {
  testthat::skip_if_not_installed("Biobase")
  expect_setequal(rownames(sub_adat), long$array_id)
  expect_setequal(getAnalytes(sub_adat), long$feature)
  expect_true(all(names(attributes(sub_adat)$Col.Meta) %in% names(long)))
  expect_true(all(getMeta(sub_adat) %in% names(long)))
})

test_that("pivotExpressionSet() preserves analyte values", {
  testthat::skip_if_not_installed("Biobase")
  expect_equal(sub_adat[order(row.names(sub_adat)),]$seq.10000.28,
               subset(long, feature == "seq.10000.28")$value)
})
