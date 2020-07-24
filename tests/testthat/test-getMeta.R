
test_that("getMeta S3 `soma_adat` method", {
  meta <- getMeta(sample.adat)
  expect_is(meta, "character")
  expect_length(meta, 15)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("getMeta `n` argumnt works", {
  expect_equal(getMeta(sample.adat, n = TRUE), 15)
})

test_that("getMeta S3 'character' method", {
  meta <- names(sample.adat) %>% getMeta()
  expect_is(meta, "character")
  expect_length(meta, 15)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("getMeta S3 default method kicks in", {
  x <- factor(head(names(sample.adat)))
  expect_error(getMeta(x),                # factor
               "Couldn't find a S3 method for this object: factor",
               class = "error")
  expect_error(getMeta(seq(1000)),        # integer
               "Couldn't find a S3 method for this object: integer",
               class = "error")
  expect_error(getMeta(c(1.1, 2.6, 9)),   # numeric
               "Couldn't find a S3 method for this object: numeric",
               class = "error")
  expect_error(getMeta(c(TRUE, FALSE)),   # logical
               "Couldn't find a S3 method for this object: logical",
               class = "error")
})
