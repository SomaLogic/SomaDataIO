
# Setup ----
apts <- head(getAnalytes(example_data), 3L)
adat <- example_data[1:3, c("SampleId", apts)]

# mock up a dummy annotations table
# example_data is V4; lift V4 -> v4.1
tbl <- tibble::tibble(
  SeqId = getSeqId(apts), "Plasma Scalar v4.0 to v4.1" = c(0.5, 1.1, 1.5)
)
attr(tbl, "version") <- "SL-99999999-rev99-1999-01"   # lookup test from `ver_dict`



# Testing ----
test_that("a mock table of scalars transforms to correct, rounded values", {
  a <- lift_adat(adat, tbl)
  expect_equal(a$seq.10000.28, round(adat$seq.10000.28 * 0.5, 1L))
  expect_equal(a$seq.10001.7, round(adat$seq.10001.7 * 1.1, 1L))
  expect_equal(a$seq.10003.15, round(adat$seq.10003.15 * 1.5, 1L))
})

test_that("a reference vector of 1.0 scalars returns identical adat", {
  tbl$`Plasma Scalar v4.0 to v4.1` <- 1.0
  a <- lift_adat(adat, tbl)
  expect_equal(a, adat, ignore_attr = TRUE)  # Header.Meta modified
  # check that header entries were added correctly
  expect_equal(attr(a, "Header")$HEADER$SignalSpace, "v4.1")
  expect_match(attr(a, "Header")$HEADER$ProcessSteps, "Annotation Lift")
})

test_that("an error occurs if analytes are missing from anno.tbl", {
  t2 <- head(tbl, 2)
  expect_error(
    lift_adat(adat, t2),
    paste0("Missing scalar value for 1 analytes. Cannot continue.\n",
           "Please check the reference scalars, their names, or the ",
           "annotations file to proceed."), fixed = TRUE
  )
})

test_that("lifting wrong direction triggers error", {
  attributes(adat)$Header.Meta$HEADER$AssayVersion <- "v4.1"
  expect_error(
    lift_adat(adat, tbl),
    "Annotations table indicates v4.0 -> v4.1, .* v4.1 space"
  )
})

test_that("error is tripped if Scalar is not found in annotations table", {
  names(tbl) <- c("SeqId", "ReferenceScalars")
  expect_error(
    lift_adat(adat, tbl),
    "Unable to find the required 'Scalar' column in the annotations file"
  )
})

test_that("un-supported matrices are trapped", {
  attributes(adat)$Header.Meta$HEADER$StudyMatrix <- "Cell Lysate"
  expect_error(
    lift_adat(adat, tbl),
    "Unsupported matrix: .*'Cell Lysate'.*\\.\nCurrent supported matrices:"
  )
})

test_that("only supported assay versions are allowed", {
  attributes(adat)$Header.Meta$HEADER$AssayVersion <- "V3"
  expect_error(
    lift_adat(adat, tbl),
    "Unsupported assay version: .*V3.*\\. Supported versions:"
  )
})

test_that("only ANML normalized data can be lifted", {
  attributes(adat)$Header.Meta$HEADER$ProcessSteps <-    # trim off ANML step
    strtrim(attributes(adat)$Header.Meta$HEADER$ProcessSteps, 74)
  expect_error(
    lift_adat(adat, tbl),
    "ANML normalized SOMAscan data is required for lifting."
  )
})
