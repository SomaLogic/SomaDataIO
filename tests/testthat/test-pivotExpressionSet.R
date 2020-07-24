
# Setup -----
sub_adat <- sample.adat[1:10, c(1:5, 25:27)]
long     <- adat2eSet(sub_adat) %>% pivotExpressionSet()

# Testing ----
test_that("multiplication works", {
  expect_is(long, "tbl_df")
  expect_equal(dim(long), c(30, 23))
  expect_setequal(rownames(sub_adat), long$array_id)
  expect_setequal(get_features(names(sub_adat)), long$feature)
  skip("Need to add unit tests for pivotExpressionSet()")
})
