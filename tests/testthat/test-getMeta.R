
# Setup ----
adat <- mock_adat()

# Testing ----
test_that("`getMeta()` S3 `soma_adat` method", {
  meta <- getMeta(adat)
  expect_type(meta, "character")
  expect_length(meta, 7L)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("`getMeta()` `n` argument works", {
  expect_equal(getMeta(adat, n = TRUE), 7)
})

test_that("`getMeta()` S3 'character' method", {
  meta <- getMeta(names(adat))
  expect_type(meta, "character")
  expect_length(meta, 7L)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("`getMeta()` S3 default method kicks in", {
  expect_error(
    getMeta(factor("A")),
    "Couldn't find a S3 method for this class object: 'factor'"
  )
  expect_error(
    getMeta(1L),
    "Couldn't find a S3 method for this class object: 'integer'"
  )
  expect_error(
    getMeta(1.1),
    "Couldn't find a S3 method for this class object: 'numeric'"
  )
  expect_error(
    getMeta(TRUE),
    "Couldn't find a S3 method for this class object: 'logical'"
  )
})
