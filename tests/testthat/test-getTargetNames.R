
anno <- getTargetNames(getAnalyteInfo(example_data))

test_that("`getTargetNames()` returns correct value(s)", {
  expect_s3_class(anno, "target_map")
  expect_length(anno, 5284L)
  expect_named(anno, getAnalytes(example_data))
  expect_true(all(vapply(anno, typeof, "") == "character"))
})

test_that("`getTargetNames()` S3 print method for `target_map` snapshots", {
  # maps to tibble for printing
  expect_snapshot_output(anno)
})

test_that("`getTargetNames()` stop modes", {
  df <- data.frame(foo = 1)
  expect_error(
    getTargetNames(df),
    "`tbl` must contain Target info."
  )
  df$Target <- "bar"
  expect_error(
    getTargetNames(df),
    "`tbl` must contain an `AptName` column."
  )
  df$AptName <- "blah"
  expect_error(out <- getTargetNames(df), NA)   # no error
  expect_equal(unclass(out), list(blah = "bar"))
})
