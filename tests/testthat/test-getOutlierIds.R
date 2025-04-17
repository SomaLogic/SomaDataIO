# Setup ------
data <- example_data |> dplyr::filter(SampleType == "Sample")
apts <- getAnalytes(data)

# outlier map object
data[12, apts[1:2750]] <- data[12, apts[1:2700]] * 100 # 2700 apts - 52%
data[18, apts[1:423]]  <- data[18, apts[1:423]] * 100  # 423 apts ~ 8%
data[20, apts[1:212]]  <- data[20, apts[1:50]] * 100   # 212 apts ~ 4%
om <- calcOutlierMap(data)


# Testing ------
test_that("`getOutlierIds()` returns error if `x` is not the required class", {
  expect_error(
    getOutlierIds(1:3),
    "Input `x` object must be class `outlier_map`!"
  )
  expect_error(
    getOutlierIds("foo"),
    "Input `x` object must be class `outlier_map`!"
  )
  expect_error(
    getOutlierIds(data.frame(x = 1)),
    "Input `x` object must be class `outlier_map`!"
  )
})

test_that("`getOutlierIds()` returns error if `data` is not a df", {
  expect_error(
    getOutlierIds(om, data = 1:3),
    "The `data` argument must be a `data.frame` object."
  )
})

test_that("`getOutlierIds()` returns error if flags arg is not in [0, 1]", {
  expect_error(
    getOutlierIds(om, flags = 1.1),
    "`flags =` argument must be between 0 and 1!"
  )
  expect_error(
    getOutlierIds(om, flags = -0.1),
    "`flags =` argument must be between 0 and 1!"
  )
})

test_that("`getOutlierIds()` trips error if `include` not in `data`", {
  expect_error(
    getOutlierIds(om, 0.05, data, "foo"),
    "All `include` must be in `data`."
  )
})

test_that("`getOutlierIds()` returns 0 row df and msg if no obs are flagged", {
  expect_message(outliers <- getOutlierIds(om, 0.8),
                 "No observations were flagged at this flagging proportion:")

  expect_s3_class(outliers, "data.frame")
  expect_false(has_rn(outliers))
  expect_equal(outliers, data.frame(idx = numeric(0)))
})

test_that("`getOutlierIds()` works on `calcOutlierMap` object, using default
          flags = 0.05, no included variables", {
  outliers <- getOutlierIds(om, data = data)
  expect_s3_class(outliers, "data.frame")
  expect_false(has_rn(outliers))
  expect_equal(outliers, data.frame(idx = c(12, 18)))
})

test_that("`getOutlierIds()` works on `calcOutlierMap` object, using
          flags = 0.02, one included variable", {
  outliers <- getOutlierIds(om, 0.02, data, "SampleId")
  expect_s3_class(outliers, "data.frame")
  expect_false(has_rn(outliers))
  expect_equal(outliers, data.frame(idx      = c(12, 13, 18, 20),
                                    SampleId = c("14", "15", "21", "23")))
})

test_that("`getOutlierIds()` works on `calcOutlierMap` object, using
          flags = 0.1, multiple included variables", {
  outliers <- getOutlierIds(om, 0.1, data, c("SampleId", "Sex"))
  expect_s3_class(outliers, "data.frame")
  expect_false(has_rn(outliers))
  expect_equal(outliers, data.frame(idx         = 12,
                                    SampleId    = "14",
                                    Sex         = "M"))
})

test_that("`getOutlierIds()` works on `calcOutlierMap` object with `data = NULL`", {
  # data = NULL, include = NULL
  outliers <- getOutlierIds(om)
  expect_s3_class(outliers, "data.frame")
  expect_false(has_rn(outliers))
  expect_equal(outliers, data.frame(idx = c(12, 18)))
})

test_that("`getOutlierIds()` `include` is ignored `data = NULL`", {
  expect_equal(
    getOutlierIds(om),
    getOutlierIds(om, data = NULL, include = "SampleId")  # test if `data = NULL`
  )
})
