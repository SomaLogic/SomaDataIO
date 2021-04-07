
test_that("the rowname helpers move rownames safely", {
  new <- rn2col(example_data)    # default `name`
  expect_s3_class(new, "soma_adat")
  expect_true(is.intact.attributes(new))
  expect_equal(new$.rn, rownames(example_data))
  expect_true(".rn" %in% names(new))
  expect_equal(.row_names_info(new, type = 0L), c(NA, -192)) # rn now implicit ones

  # `name` argument
  new <- rn2col(example_data, "foo")
  expect_s3_class(new, "soma_adat")
  expect_true(is.intact.attributes(new))
  expect_equal(new$foo, rownames(example_data))
  expect_true("foo" %in% names(new))
  expect_equal(.row_names_info(new, type = 0L), c(NA, -192)) # rn now implicit ones

  # moving columns
  example_data$foo <- as.character(sample(1:nrow(example_data)))
  x <- expect_warning(col2rn(example_data, "foo"))   # over-write warning
  expect_s3_class(x, "soma_adat")
  expect_true(is.intact.attributes(x))
  expect_equal(rownames(x), example_data$foo)
  expect_false("foo" %in% rownames(x))

  # check the `as.character()` and unique rn feature; b => "numeric"
  x <- col2rn(data.frame(a = 1:3, b = c(1, 1, 2)), "b")
  expect_equal(x, data.frame(a = 1:3, row.names = c("1", "1-1", "2")))
})

test_that("the rowname helpers have object fidelity", {
  df <- rn2col(example_data) %>% col2rn()  # convert & convert back
  expect_equal(df, example_data)
})

test_that("warning tripped if explicit rownames are already present", {
  df <- data.frame(a = 1, b = "bar", row.names = "foo")
  expect_warning(col2rn(df, "b"), "already has assigned row names.*over-written")
})

test_that("has_rn returns correct implicit-explicit boolean", {
  df <- data.frame(a = 1)     # no rn
  expect_false(has_rn(df))
  df <- data.frame(a = 1, row.names = "A")   # with rn
  expect_true(has_rn(df))
  expect_false(has_rn(rn2col(df)))     # rownames moved to column; now implicit
  # initially implicit rn; now explicit via `b`
  expect_true(has_rn(col2rn(data.frame(a = 1, b = "A"), "b")))
})
