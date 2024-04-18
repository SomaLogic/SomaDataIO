
# Setup ----
file   <- test_path("testdata", "single_sample.adat")
adat   <- read_adat(file)
header <- parseHeader(file)

# Testing ----
test_that("`checkHeader()` prints expected output", {
  expect_silent(checkHeader(header, verbose = FALSE))
  expect_message(checkHeader(header, verbose = TRUE),
                 "Header passed checks and traps")
})

test_that(".verbosity()` prints expected output", {
  expect_snapshot(.verbosity(adat, header))
})
