
# Setup ----
apts <- head(getAnalytes(example_data), 3L)
adat <- example_data[1:3L, c("SampleId", apts)]

# Testing ----
test_that("a mock table of scalars transforms to correct, rounded values", {
  expect_equal(getSomaScanVersion(adat), "V4")  # orig; 5k
  expect_warning( a <- lift_adat(adat, bridge = "5k_to_7k") )
  expect_true(is_lifted(a))
  expect_equal(getSomaScanVersion(a), "V4")   # not updated; 5k
  expect_equal(getSignalSpace(a), "v4.1")     # updated; 7k
  expect_equal(attr(a, "Header")$HEADER$SignalSpace, "v4.1")
  expect_match(attr(a, "Header")$HEADER$ProcessSteps, "Lifting Bridge")
  expect_equal(a$seq.10000.28, round(adat$seq.10000.28 * 1.053, 1L))
  expect_equal(a$seq.10001.7, round(adat$seq.10001.7 * 1.300, 1L))
  expect_equal(a$seq.10003.15, round(adat$seq.10003.15 * 1.507, 1L))
})

test_that("passing `anno.tbl=` is deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_warning(
    lift_adat(adat, "5k_to_7k", anno.tbl = data.frame(a = 1)),
    regexp = "The `anno.tbl` argument of `lift_adat()` is deprecated as of SomaDataIO",
    fixed = TRUE,
    class = "lifecycle_warning_deprecated"
  ) |>
  expect_warning("extra scaling values") # secondary warning from ScaleAnalytes()
})

test_that("lifting wrong direction triggers error; .check_direction()", {
  expect_error(
    lift_adat(adat, "5k_to_5k"),
    "'arg' should be one of"
  )
  expect_error(
    lift_adat(adat, "7k_to_5k"),
    "You have indicated a bridge from '7k' space"
  )
  attr(adat, "Header.Meta")$HEADER$AssayVersion <- "v5.0"   # 11k
  expect_error(
    lift_adat(adat, "5k_to_7k"),
    "You have indicated a bridge from '5k' space"
  )
})

test_that("un-supported matrices are trapped", {
  attr(adat, "Header.Meta")$HEADER$StudyMatrix <- "Cell Lysate"
  expect_error(
    lift_adat(adat, "5k_to_7k"),
    "Unsupported matrix: .*'Cell Lysate'.*\\.\nCurrent supported matrices:"
  )
})

test_that("only supported assay versions are allowed", {
  attr(adat, "Header.Meta")$HEADER$AssayVersion <- "V3"
  expect_error(
    lift_adat(adat),
    "Unsupported assay version: 'V3'\\. Supported versions:"
  )
})

test_that("only ANML normalized data can be lifted", {
  attr(adat, "Header.Meta")$HEADER$ProcessSteps <-    # trim off ANML step
    strtrim(attr(adat, "Header.Meta")$HEADER$ProcessSteps, 74L)
  expect_error(
    lift_adat(adat),
    "ANML normalized SOMAscan data is required for lifting."
  )
})

test_that("the lift_master reference object is correctly generated", {
  expect_s3_class(lift_master, "tbl_df")
  expect_equal(dim(lift_master), c(11083L, 19L))
  expect_named(
    lift_master,
    c("SeqId", "serum_11k_to_7k_ccc", "plasma_11k_to_7k_ccc",
      "serum_11k_to_5k_ccc", "plasma_11k_to_5k_ccc", "serum_11k_to_7k",
      "plasma_11k_to_7k", "serum_11k_to_5k", "plasma_11k_to_5k",
      "serum_5k_to_11k", "plasma_5k_to_11k", "serum_7k_to_5k_ccc",
      "plasma_7k_to_5k_ccc", "serum_7k_to_5k", "plasma_7k_to_5k",
      "serum_7k_to_11k", "plasma_7k_to_11k", "serum_5k_to_7k", "plasma_5k_to_7k")
  )
  # all are SeqIds
  expect_true(all(is.apt(lift_master$SeqId)))
  expect_equal(lift_master$SeqId, getSeqId(lift_master$SeqId))
  expect_true(all(vapply(lift_master[, -1L], typeof, "") == "double"))
})
