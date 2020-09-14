
# First 6 features of 'example_data'
seq_vec <- c("seq.10000.28", "seq.10001.7", "seq.10003.15",
             "seq.10006.25", "seq.10008.43", "seq.10011.65")

# Testing ----
test_that("getFeatures S3 `soma_adat` and `data.frame` methods", {
  apts <- getFeatures(example_data)
  expect_is(apts, "character")
  expect_length(apts, 5284)
  expect_equal(head(apts), seq_vec)
  expect_true(all(apts %in% names(example_data)))
})

test_that("getFeatures `n` argumnt works", {
  expect_equal(getFeatures(example_data, n = TRUE), 5284)
})

test_that("getFeatures `rm.controls` argumnt works", {
  expect_equal(getFeatures(example_data, n = TRUE, rm.controls = TRUE), 5220)
})

test_that("getFeatures S3 `character` method kicks in", {
  apts <- names(example_data) %>% getFeatures()
  expect_is(apts, "character")
  expect_length(apts, 5284)
  expect_true(all(is.apt(apts)))
  expect_equal(head(apts), seq_vec)
})

test_that("getFeatures S3 default method kicks in", {
  x <- factor(seq_vec)
  expect_error(
    getFeatures(x),
    "Couldn't find a S3 method for this class object: factor.",
    class = "error"
  )
  expect_error(
    getFeatures(seq(1000)),
    "Couldn't find a S3 method for this class object: integer.",
    class = "error"
  )
  expect_error(
    getFeatures(c(TRUE, FALSE)),
    "Couldn't find a S3 method for this class object: logical.",
    class = "error"
  )
})

test_that("getFeatures matrix S3 method kicks in", {
  apts <- example_data %>% as.matrix() %>% getFeatures()
  expect_is(apts, "character")
  expect_equal(head(apts), seq_vec)
  expect_true(all(is.apt(apts)))
  expect_true(all(apts %in% names(example_data)))
})

test_that("the S3 list method kicks in", {
  apts <- as.list(seq_vec) %>% purrr::set_names()
  expect_is(apts, "list")
  expect_equal(getFeatures(apts), head(getFeatures(example_data)))
  expect_true(all(apts %in% names(example_data)))
})
