
test_that("`is_seqFormat()` soma_adat method returns correct booleans", {
  expect_true(is_seqFormat(example_data))
  example_data$ABCD.1234.5 <- 100
  expect_false(is_seqFormat(example_data))
})

test_that("`is_seqFormat()` data.frame method returns correct booleans", {
  expect_true(is_seqFormat(data.frame(seq.1243.5 = 1:10)))
  expect_false(is_seqFormat(data.frame(PlateId = 1:10)))
  expect_false(is_seqFormat(data.frame(1:10)))
})

test_that("`is_seqFormat()` character method returns correct booleans", {
  expect_false(is_seqFormat(names(example_data)))   # meta data makes false
  expect_false(is_seqFormat("SomaLogic"))
  expect_false(is_seqFormat("ABCD.1234.12"))
  expect_true(is_seqFormat("seq.1234.12"))
})

test_that("`is_seqFormat()` character(0) is false", {
  expect_false(is_seqFormat(character(0)))
})

test_that("`is_seqFormat()` default method is tripped for unknown classes", {
  withr::local_options(list(cli.num_colors = 1L))
  expect_error(
    is_seqFormat(1:10),
    "Couldn't find a S3 method for this class object: 'integer'"
  )
  expect_error(
    is_seqFormat(2.34),
    "Couldn't find a S3 method for this class object: 'numeric'"
  )
  expect_error(
    is_seqFormat(factor(letters)),
    "Couldn't find a S3 method for this class object: 'factor'"
  )
  expect_error(
    is_seqFormat(matrix(1:9, ncol = 3)),
    "Couldn't find a S3 method for this class object: 'matrix'"
  )
})
