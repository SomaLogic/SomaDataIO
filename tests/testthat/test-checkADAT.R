
# Setup ----
adat <- mock_adat()

# Testing ----
test_that("`.checkADAT()` produces an error when it should", {
  # Success
  expect_null(.checkADAT(adat))        # NULL
  expect_error(.checkADAT(adat), NA)   # NA; no errors
  expect_invisible(.checkADAT(adat))   # invisible

  # Failure
  attr(adat, "Header.Meta") <- NULL  # break attributes
  attr(adat, "Col.Meta")    <- NULL  # break attributes
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
  expect_warning(
    .checkADAT(adat[0L, ]),
    "ADAT has no rows! Writing just header and column meta data."
  )
})
