
# generate mock `soma_adat`
df <- mock_adat()
withr::local_options(list(usethis.quiet = TRUE))   # silence signalling


test_that("TRUE returned when attributes look good", {
  expect_true(is_intact_attr(df))
})

test_that("FALSE returned when attributes <= 3 in length", {
  df <- data.frame(df)
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE returned when Col.Meta or Header.Meta are missing", {
  x <- df
  attributes(x)$Col.Meta <- NULL
  expect_false(is_intact_attr(x, TRUE))
  x <- df
  attributes(x)$Header.Meta <- NULL
  expect_false(is_intact_attr(x, TRUE))
})

test_that("FALSE when Header.Meta has elements missing", {
  attributes(df)$Header.Meta <- c("this", "should", "fail")
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE when Col.Meta has elements missing", {
  attributes(df)$Col.Meta <- c("SeqId", "Target", "DUMMY", "Units")
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE when Col.Meta is not a tibble", {
  attr(df, "Col.Meta") <- as.list(attr(df, "Col.Meta"))
  expect_false(is_intact_attr(df, TRUE))
})
