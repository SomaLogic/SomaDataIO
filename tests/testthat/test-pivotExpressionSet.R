
# Setup -----
sub_adat <- example_data[1:10, c(1:5, 35:37)]
long     <- pivotExpressionSet(adat2eSet(sub_adat))

# Testing ----
test_that("multiplication works", {
  expect_s3_class(long, "tbl_df")
  expect_equal(dim(long), c(30, 29))
  expect_setequal(rownames(sub_adat), long$array_id)
  expect_setequal(getFeatures(sub_adat), long$feature)
  skip("Add increased coverage unit tests for `pivotExpressionSet()`")
})
