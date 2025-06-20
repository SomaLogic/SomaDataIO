# Testing ----
test_that("`preProcessAdat` applies default arguments as expected", {
  expect_snapshot(preProcessAdat(example_data))
})

test_that("`preProcessAdat` produces qc plots as expected", {
  expect_snapshot_plot(
    out <- capture_output(
      sex_plt <- suppressMessages(preProcessAdat(example_data, data.qc = "Sex"))
    ),
    "preProcessAdat_qc_plot_Sex"
  )

  expect_snapshot_plot(
    out <- capture_output(
      age_plt <- suppressMessages(preProcessAdat(example_data, data.qc = "Age"))
    ),
    "preProcessAdat_qc_plot_Age"
  )
})

test_that("`preProcessAdat` works if adat missing ColCheck annotation info", {
  missing_colcheck <- example_data
  attr(missing_colcheck, "Col.Meta") <- attr(missing_colcheck, "Col.Meta") |>
    select(-ColCheck)
  expect_snapshot(preProcessAdat(missing_colcheck))
})

test_that("`preProcessAdat` produces errors as expected", {
  # errors on object not `soma_adat` class
  expect_error(
    preProcessAdat(data.frame(a = 1:3, b = 4:6)),
    "`adat` must be a class `soma_adat` object"
  )

  # data.qc variables are not in input adat
  expect_error(
    suppressMessages(
      preProcessAdat(example_data, data.qc = "SUBJECT_AGE_AS_OF_OBS_DATE")
    ),
    "All variable names passed in `data.qc` argument must exist in `adat`"
  )
})
