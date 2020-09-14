
# Setup -----
sub_adat <- example_data[1:10, c(1:5, 35:37)]
long     <- adat2eSet(sub_adat) %>% pivotExpressionSet()

# Testing ----
test_that("multiplication works", {
  expect_is(long, "tbl_df")
  expect_equal(dim(long), c(30, 29))
  expect_setequal(rownames(sub_adat), long$array_id)
  expect_setequal(get_features(names(sub_adat)), long$feature)
  skip("Add increased coverage unit tests for `pivotExpressionSet()`")
})
