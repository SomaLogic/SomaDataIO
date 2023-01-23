
# Setup ----
adat <- mock_adat()

# Testing ----
test_that("`.checkADAT()` produces an error when it should", {
  # Success
  withr::local_options(list(usethis.quiet = TRUE))
  expect_null(.checkADAT(adat))        # NULL
  expect_error(.checkADAT(adat), NA)   # NA; no errors
  expect_invisible(.checkADAT(adat))   # invisible

  # Failure
  # break sync with attributes and adat
  attributes(adat)$Header.Meta$ROW_DATA$Name <- "Foo"
  expect_error(
    .checkADAT(adat),
    "Meta data mismatch between `Header Meta` and ADAT meta data."
  )
})

test_that("`.checkADAT()` produces an error if Col.Meta-Apts are out of sync", {
  attr(adat, "Col.Meta") <- attr(adat, "Col.Meta")[-2, ]
  expect_error(
    .checkADAT(adat),
    "Number of RFU features in ADAT does not match No. analytes in Col.Meta!"
  )
})

test_that("`.checkADAT()` produces a warning if ADAT has no rows", {
  withr::local_options(list(usethis.quiet = TRUE))
  expect_warning(
    .checkADAT(adat[0L, ]),
    "ADAT has no rows! Writing just header and column meta data."
  )
})
