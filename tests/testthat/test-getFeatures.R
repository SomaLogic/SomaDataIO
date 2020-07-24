
# First 6 features of 'sample.adat'
seq_vec <- c("seq.2182.54", "seq.2190.55", "seq.2192.63", "seq.2201.17",
             "seq.2211.9", "seq.2212.69")

# Testing ----
test_that("getFeatures S3 `soma_adat` and `data.frame` methods", {
  apts <- getFeatures(sample.adat)
  expect_is(apts, "character")
  expect_length(apts, 1129)
  expect_equal(head(apts), seq_vec)
  expect_true(all(apts %in% names(sample.adat)))
})

test_that("getFeatures `n` argumnt works", {
  expect_equal(getFeatures(sample.adat, n = TRUE), 1129)
})

test_that("getFeatures `rm.controls` argumnt works", {
  expect_equal(getFeatures(sample.adat, n = TRUE, rm.controls = TRUE), 1129)
})

test_that("getFeatures S3 `character` method kicks in", {
  apts <- names(sample.adat) %>% getFeatures()
  expect_is(apts, "character")
  expect_length(apts, 1129)
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
  apts <- sample.adat %>% as.matrix() %>% getFeatures()
  expect_is(apts, "character")
  expect_equal(head(apts), seq_vec)
  expect_true(all(is.apt(apts)))
  expect_true(all(apts %in% names(sample.adat)))
})

test_that("the S3 list method kicks in", {
  apts <- as.list(seq_vec) %>% purrr::set_names()
  expect_is(apts, "list")
  expect_equal(getFeatures(apts), head(getFeatures(sample.adat)))
  expect_true(all(apts %in% names(sample.adat)))
})
