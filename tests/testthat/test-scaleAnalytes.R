
# Setup ----
adat <- example_data
apts <- getAnalytes(adat)
short_adat <- head(adat[, c(getMeta(adat), head(apts, 3L))], 3L)

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
  a <- scaleAnalytes(adat, ref)
  expect_equal(adat, a)
})

test_that("a warning is triped if reference is missing any features", {
  ref <- setNames(rep(1.0, length(apts)), getSeqId(apts))
  ref <- head(ref, -3L)   # rm 3 seqids from end
  expect_length(ref, length(apts) - 3L)
  expect_snapshot( new <- scaleAnalytes(adat, ref) )
})

test_that("a subset adat can be transformed", {
  # extra scaling analytes in reference:
  #   sample() ensures ref is out of sync with short_adat analytes
  ref <- setNames(rep(1.0, length(apts)), sample(getSeqId(apts)))
  expect_warning(
    a <- scaleAnalytes(short_adat, ref),
    "There are extra scaling values (5281) in the reference.",
    fixed = TRUE
  )
  expect_equal(short_adat, a)
})

test_that("specific analytes are scaled with non-1.0 values", {
  # extra scaling analytes in reference
  ref <- setNames(c(0.75, 1.1, 1.25), getSeqId(getAnalytes(short_adat)))
  # re-order puts reference out of order; ensures SeqId matching must happen
  ref <- ref[c(2, 3, 1L)]
  a <- scaleAnalytes(short_adat, ref)
  expect_s3_class(a, "soma_adat")
  expect_equal(a$seq.10000.28, short_adat$seq.10000.28 * 0.75)
  expect_equal(a$seq.10001.7, short_adat$seq.10001.7 * 1.10)
  expect_equal(a$seq.10003.15, short_adat$seq.10003.15* 1.25)
})

test_that("`scaleAnalytes()` only accepts the `soma_adat` class", {
  bad_adat <- as.data.frame(short_adat)
  expect_snapshot(scaleAnalytes(bad_adat), error = TRUE)
})
