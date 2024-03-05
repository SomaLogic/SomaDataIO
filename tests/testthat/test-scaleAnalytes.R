
# Setup ----
adat <- example_data
apts <- withr::with_seed(101, sample(getAnalytes(adat), 3L))
short_adat <- adat[, c(getMeta(adat), apts)] |> head(3L)

# this is to ensure the S3 method is available and dispatched
# otherwise the base::transform.data.frame() method will not
# transform the analytes inside scaleAnalytes()

test_that("the transform() S3 method exists in the namespace", {
  expect_no_error(getS3method("transform", "soma_adat"))
})

test_that("the transform() S3 method is listed in methods", {
  methods <- unclass(methods("transform", "soma_adat"))
  expect_true("transform.soma_adat" %in% methods)
})


# Testing ----
test_that("`scaleAnalytes()` returns identical adat when scalars are 1.0", {
  ref <- setNames(rep(1.0, length(apts)), getSeqId(apts))
  a <- scaleAnalytes(short_adat, ref)
  expect_equal(short_adat, a)
})

test_that("specific analytes are scaled with non-1.0 values", {
  ref <- setNames(c(0.75, 1.1, 1.25), getSeqId(getAnalytes(short_adat)))
  # re-order puts reference out of order
  # ensures SeqId matching
  ref <- ref[c(2, 3, 1L)]
  a <- scaleAnalytes(short_adat, ref)
  expect_s3_class(a, "soma_adat")
  expect_equal(a$seq.3072.4, short_adat$seq.3072.4 * 0.75)
  expect_equal(a$seq.18184.28, short_adat$seq.18184.28 * 1.10)
  expect_equal(a$seq.4430.44, short_adat$seq.4430.44 * 1.25)
})

# Warnings & Errors ----
test_that("extra refernce analytes are ignored with a warning", {
  # extra scaling analytes in reference
  ref <- setNames(rep(1.0, length(apts)), getSeqId(apts))
  # ensure SeqId matching
  ref <- ref[c(2, 3, 1L)]
  ref <- c(ref, "1234-56" = 1.0)  # add 1 extra scalar
  expect_warning(
    a <- scaleAnalytes(short_adat, ref),
    "There are extra scaling values (1) in the reference.",
    fixed = TRUE
  )
  expect_equal(short_adat, a)
})

test_that("missing analytes are skipped with a warning", {
  ref <- setNames(c(1.0, 1.0), getSeqId(getAnalytes(short_adat))[-2L])
  expect_warning(
    b <- scaleAnalytes(short_adat, ref),
    "Missing scalar value for (1) analytes. They will not be transformed.",
    fixed = TRUE
  )
  expect_equal(short_adat, b)
})

test_that("no matches returns identical object, with a 1 message & 2 warnings", {
  ref <- c("1234-56" = 1.555)
  expect_snapshot( new <- scaleAnalytes(short_adat, ref) )
  expect_equal(short_adat, new)
})

test_that("`scaleAnalytes()` only accepts the `soma_adat` class", {
  bad_adat <- as.data.frame(short_adat)
  expect_snapshot(scaleAnalytes(bad_adat), error = TRUE)
})
