
# Setup ----
f <- system.file("extdata", "example_data10.adat",
                 package = "SomaDataIO", mustWork = TRUE)
lines <- .getHeaderLines(f) |> strsplit("\t", fixed = TRUE)

# Testing ----
test_that("`parseCheck()` prints expected output", {
  specs <- capture.output(suppressMessages(parseCheck(lines)))
  expect_snapshot(specs)
})

test_that("`parseCheck()` errors given incorrect `all.tokens` argument", {
  expect_error(parseCheck(f), "Format is wrong for the `all.tokens` argument.")
})
