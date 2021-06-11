
# First 6 features of 'example_data'
seq_vec <- c("seq.10000.28", "seq.10001.7", "seq.10003.15",
             "seq.10006.25", "seq.10008.43", "seq.10011.65")

plex <- 5284

# Testing ----
test_that("getAnalytes S3 `soma_adat` and `data.frame` methods", {
  apts <- getAnalytes(example_data)
  expect_type(apts, "character")
  expect_length(apts, plex)
  expect_equal(head(apts), seq_vec)
  expect_true(all(apts %in% names(example_data)))
})

test_that("getAnalytes `n` argumnt works", {
  expect_equal(getAnalytes(example_data, n = TRUE), plex)
})

test_that("getAnalytes `rm.controls` argumnt works", {
  expect_equal(getAnalytes(example_data, n = TRUE, rm.controls = TRUE), 5220)
})

test_that("getAnalytes S3 `character` method kicks in", {
  apts <- names(example_data) %>% getAnalytes()
  expect_type(apts, "character")
  expect_length(apts, plex)
  expect_true(all(is.apt(apts)))
  expect_equal(head(apts), seq_vec)
})

test_that("getAnalytes S3 default method kicks in", {
  x <- factor(seq_vec)
  expect_error(
    getAnalytes(x),
    "Couldn't find a S3 method for this class object: .*factor.",
    class = "error"
  )
  expect_error(
    getAnalytes(seq(1000)),
    "Couldn't find a S3 method for this class object: .*integer.",
    class = "error"
  )
  expect_error(
    getAnalytes(c(TRUE, FALSE)),
    "Couldn't find a S3 method for this class object: .*logical.",
    class = "error"
  )
})

test_that("getAnalytes matrix S3 method kicks in", {
  apts <- as.matrix(example_data) %>% getAnalytes()
  expect_type(apts, "character")
  expect_equal(head(apts), seq_vec)
  expect_true(all(is.apt(apts)))
  expect_true(all(apts %in% names(example_data)))
})

test_that("the S3 list method kicks in", {
  apts <- as.list(seq_vec) %>% purrr::set_names()
  expect_type(apts, "list")
  expect_equal(getAnalytes(apts), head(getAnalytes(example_data)))
  expect_true(all(apts %in% names(example_data)))
})
