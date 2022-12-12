
test_that("is.apt produces a logical", {
  expect_type(is.apt("ABCD.1234.50.5"), "logical")
  expect_type(is.apt("HelloKitty"), "logical")
})

test_that("is.apt returns TRUE by 'clone' ID", {
  expect_true(is.apt("ABCD9.1234.555.6"))
  expect_true(is.apt("ABCD9.1234.55.6"))
  expect_true(is.apt("ABCD9.1234.5.6"))
  expect_true(is.apt("ABCD9.1234.555.61"))
  expect_true(is.apt("ABCD9.1234.55.61"))
  expect_true(is.apt("ABCD9.1234.5.61"))
  expect_true(is.apt("ABCD9.1234.555.618"))
  expect_true(is.apt("ABCD9.1234.55.618"))
  expect_true(is.apt("ABCD9.1234.5.618"))
})

test_that("is.apt returns TRUE by 'version' ID", {
  expect_true(is.apt("ABCD9.1234.5.3"))
  expect_true(is.apt("ABCD9.1234.5.36"))
  expect_true(is.apt("ABCD9.1234.5.367"))
  expect_true(is.apt("ABCD9.1234.55.3"))
  expect_true(is.apt("ABCD9.1234.55.36"))
  expect_true(is.apt("ABCD9.1234.55.367"))
  expect_true(is.apt("ABCD9.1234.955.3"))
  expect_true(is.apt("ABCD9.1234.955.36"))
  expect_true(is.apt("ABCD9.1234.955.367"))
})

test_that("is.apt returns TRUE with 5 digit 'seqId'", {
  expect_true(is.apt("ABCD9.12349.5.3"))
  expect_true(is.apt("ABCD9.12349.5.36"))
  expect_true(is.apt("ABCD9.12349.5.367"))
  expect_true(is.apt("ABCD9.12349.55.3"))
  expect_true(is.apt("ABCD9.12349.55.36"))
  expect_true(is.apt("ABCD9.12349.55.367"))
  expect_true(is.apt("ABCD9.12349.955.3"))
  expect_true(is.apt("ABCD9.12349.955.36"))
  expect_true(is.apt("ABCD9.12349.955.367"))
})

test_that("is.apt returns TRUE when missing 'version' ID", {
  expect_true(is.apt("ABCD9.1234.5"))
  expect_true(is.apt("ABCD9.1234.55"))
  expect_true(is.apt("ABCD9.1234.555"))
  expect_true(is.apt("ABCD9.12348.5"))
  expect_true(is.apt("ABCD9.12348.55"))
  expect_true(is.apt("ABCD9.12348.555"))
})

test_that("is.apt returns FALSE when SeqId absent", {
  expect_false(is.apt(NA_character_))
  expect_equal(is.apt(NULL), logical(0))
  expect_false(is.apt(""))
  expect_false(is.apt("ABCD9.1234"))
  expect_false(is.apt("ABCD9.123.4"))
  expect_false(is.apt("ABCD9.23.4"))
  expect_false(is.apt("ABCD9.123.4.20"))
  expect_false(is.apt("ABCD9.12.4.20"))
  expect_false(is.apt("ABCD34.5656"))
  expect_false(is.apt("HelloKitty"))
  expect_false(is.apt("SomaLogic"))
  expect_false(is.apt("ABCD.9.44.0"))
})

test_that("is.apt returns FALSE when SeqId is not trailing", {
  expect_false(is.apt("ABCD.1234.5_A"))
  expect_false(is.apt("seq.1234.5_A"))
  expect_true(is.apt("1234.5"))
  expect_false(is.apt("1234.5 "))     # trailing whitespace
  expect_false(is.apt("This 1234.5 not an Apt"))
})

test_that("is.apt vectorized version works", {
  x <- is.apt(c("Super", "HB1A.9", "Sample", "ABCD.2343.2.12", "MMP.4342.12.1"))
  expect_type(x, "logical")
  expect_length(x, 5L)
  expect_equal(x, c(FALSE, FALSE, FALSE, TRUE, TRUE))
  expect_equal(sum(is.apt(names(mock_adat()))), 3)  # all analytes in `soma_adat`
})
