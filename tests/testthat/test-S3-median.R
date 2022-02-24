
test_that("the `median.soma_adat()` method trips warning", {
  adat <- mock_adat()
  expect_warning(
    median(adat),
    "As with the `data.frame` class, numeric data is required for `median()`.",
    fixed = TRUE
  )
  withr::local_options(list(warn = -1)) # turn off for next tests
  expect_invisible(median(adat))
  expect_null(median(adat))
})
