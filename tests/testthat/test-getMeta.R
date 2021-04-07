
test_that("getMeta S3 `soma_adat` method", {
  meta <- getMeta(example_data)
  expect_type(meta, "character")
  expect_length(meta, 34)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("getMeta `n` argumnt works", {
  expect_equal(getMeta(example_data, n = TRUE), 34)
})

test_that("getMeta S3 'character' method", {
  meta <- names(example_data) %>% getMeta()
  expect_type(meta, "character")
  expect_length(meta, 34)
  expect_true(sum(is.apt(meta)) == 0)
})

test_that("getMeta S3 default method kicks in", {
  x <- factor(head(names(example_data)))
  expect_error(getMeta(x),                # factor
               "Couldn't find a S3 method for this class object: .*factor",
               class = "error")
  expect_error(getMeta(seq(1000)),        # integer
               "Couldn't find a S3 method for this class object: .*integer",
               class = "error")
  expect_error(getMeta(c(1.1, 2.6, 9)),   # numeric
               "Couldn't find a S3 method for this class object: .*numeric",
               class = "error")
  expect_error(getMeta(c(TRUE, FALSE)),   # logical
               "Couldn't find a S3 method for this class object: .*logical",
               class = "error")
})
