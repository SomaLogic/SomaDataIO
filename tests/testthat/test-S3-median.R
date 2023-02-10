
adat <- mock_adat()

test_that("the `median.soma_adat()` method trips correct warning", {
  expect_snapshot(median(adat))
})

test_that("the `median.soma_adat()` method invisibly returns `NULL`", {
  withr::local_options(list(warn = -1)) # turn off warnings tests
  expect_invisible(median(adat))
  expect_null(median(adat))
})
