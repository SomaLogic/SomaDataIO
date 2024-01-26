
test_that("`getSomaScanVersion()` returns the ADAT version string", {
  expect_equal(getSomaScanVersion(example_data), "V4")
})

test_that("`checkSomaScanVersion()` returns the correct error mode", {
  expect_null(checkSomaScanVersion("V4"))
  expect_null(checkSomaScanVersion("v4"))
  expect_null(checkSomaScanVersion("v4.1"))
  expect_null(checkSomaScanVersion("v5.0"))
  expect_null(checkSomaScanVersion("v5"))
  expect_error(checkSomaScanVersion("V2"), "Unsupported")
  expect_error(checkSomaScanVersion("foo"), "Unsupported")
})
