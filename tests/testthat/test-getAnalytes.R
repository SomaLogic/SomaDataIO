
# Setup ----
# Get full adat with controls
full <- read_adat(test_path("testdata", "single_sample.adat"))

# First 6 features of 'example_data' with controls
seq_vec <- c("seq.10000.28", "seq.10001.7", "seq.10003.15",
             "seq.10006.25", "seq.10008.43", "seq.10011.65")
plex <- 5284


# Testing ----
test_that("`getAnalytes()` S3 `soma_adat` and `data.frame` methods", {
  apts <- getAnalytes(full)
  expect_type(apts, "character")
  expect_length(apts, plex)
  expect_equal(head(apts), seq_vec)
  expect_true(all(is.apt(apts)))
  expect_true(all(apts %in% names(full)))
})

test_that("`getAnalytes()` S3 `recipe` methods work", {
  skip_on_cran()
  rec  <- recipes::recipe(~ ., data = full)
  apts <- getAnalytes(rec)
  expect_equal(typeof(apts), "character")
  expect_length(apts, plex)
  expect_equal(head(apts), seq_vec)
  expect_true(all(apts %in% names(full)))
})

test_that("`getAnalytes()` with the `n =` argument works", {
  expect_equal(getAnalytes(full, n = TRUE), plex)
})

test_that("`getAnalytes()` with the `rm.controls =` argument works", {
  expect_equal(getAnalytes(full, n = TRUE, rm.controls = TRUE), plex - 64)
})

test_that("`getAnalytes()` S3 `character` method kicks in", {
  apts <- getAnalytes(names(full))
  expect_type(apts, "character")
  expect_length(apts, plex)
  expect_true(all(is.apt(apts)))
  expect_equal(head(apts), seq_vec)
})

test_that("`getAnalytes()` S3 default method kicks in", {
  expect_error(
    getAnalytes(factor("A")),
    "Couldn't find a S3 method for this class object: 'factor'"
  )
  expect_error(
    getAnalytes(1L),
    "Couldn't find a S3 method for this class object: 'integer'"
  )
  expect_error(
    getAnalytes(1.1),
    "Couldn't find a S3 method for this class object: 'numeric'"
  )
  expect_error(
    getAnalytes(TRUE),
    "Couldn't find a S3 method for this class object: 'logical'"
  )
})

test_that("`getAnalytes()` matrix S3 method kicks in", {
  apts <- as.matrix(full) |> getAnalytes()
  expect_type(apts, "character")
  expect_equal(head(apts), seq_vec)
  expect_true(all(is.apt(apts)))
  expect_true(all(apts %in% names(full)))
})

test_that("the S3 list method kicks in", {
  apts <- setNames(as.list(seq_vec), seq_vec)
  expect_equal(getAnalytes(apts), head(getAnalytes(full)))
  expect_true(all(apts %in% names(full)))
})
