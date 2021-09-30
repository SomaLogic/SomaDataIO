
# this is to ensure the S3 method is available and dispatched
# otherwise the base::transform.data.frame() method will not
# transform the analytes inside scaleAnalytes()

test_that("the transform S3 method exists in the namespace", {
  expect_error(getS3method("transform", "soma_adat"), NA)  # expect no error
})

test_that("the transform S3 method is listed in methods", {
  methods <- unclass(methods("transform", "soma_adat"))
  expect_true("transform.soma_adat" %in% methods)
})

# dummy ADAT:
# double seq1; half seq2
v  <- c(2, 0.5)
df <- data.frame(
  sample      = paste0("sample_", 1:3),
  seq.1234.56 = c(1, 2, 3),
  seq.9999.88 = c(4, 5, 6) * 10
  ) %>%  # `soma_adat` to invoke S3 method dispatch
  addClass("soma_adat")

test_that("transform() dispatches the soma_adat method and correctly scales", {
  trans <- transform(df, v)
  expect_s3_class(trans, "soma_adat")
  expect_equal(trans$seq.1234.56, df$seq.1234.56 * 2)
  expect_equal(trans$seq.9999.88, df$seq.9999.88 * 0.5)
  expect_named(trans, names(df))
})
