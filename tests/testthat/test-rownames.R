
test_that("the rowname helpers move rownames safely", {
  new <- rn2col(example_data)    # default `name`
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(new$.rn, rownames(example_data))
  expect_true(".rn" %in% names(new))
  expect_equal(.row_names_info(new, type = 0L), c(NA, -192)) # now implicit rn
  expect_true(has_implicit_rn(new))                          # now implicit rn

  # `name` argument
  new <- rn2col(example_data, "foo")
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(new$foo, rownames(example_data))
  expect_true("foo" %in% names(new))
  expect_equal(.row_names_info(new, type = 0L), c(NA, -192)) # now implicit rn
  expect_true(has_implicit_rn(new))                          # now implicit rn

  # moving columns
  expect_warning(x <- col2rn(example_data, "SampleId"))   # over-write warning
  expect_s3_class(x, "soma_adat")
  expect_true(is_intact_attr(x))
  expect_equal(rownames(x), make.unique(example_data$SampleId, "-"))
  expect_false("SampleId" %in% rownames(x))

  # check the `as.character()` and unique rn feature; b => "numeric"
  x <- col2rn(data.frame(a = 1:3, b = c(1, 1, 2)), "b")
  expect_equal(x, data.frame(a = 1:3, row.names = c("1", "1-1", "2")))
})

test_that("the rowname helpers have object fidelity", {
  df <- rn2col(example_data) |> col2rn()  # convert & convert back
  expect_equal(df, example_data)
})

test_that("warning tripped if explicit rownames are already present", {
  df <- data.frame(a = 1, b = "bar", row.names = "foo")
  expect_warning(col2rn(df, "b"),
                 "`df` already has row names. They will be over-written")
})

test_that("`has_rn()` returns correct implicit-explicit boolean", {
  expect_false(has_rn(data.frame()))     # no rn if empty df
  df <- data.frame(a = 1)     # no rn
  expect_false(has_rn(df))
  df <- data.frame(a = 1, row.names = "A")   # with rn
  expect_true(has_rn(df))
  expect_false(has_rn(rn2col(df)))     # rownames moved to column; now implicit
  # initially implicit rn; now explicit via `b`
  expect_true(has_rn(col2rn(data.frame(a = 1, b = "A"), "b")))
})

test_that("`set_rn()` behaves as expected", {
  df <- data.frame(a = 1:3, b = 4:6)     # no rn
  rn <- c("a", "b", "c")
  expect_equal(set_rn(df, rn), data.frame(a = 1:3, b = 4:6, row.names = rn))

  # duplicated kicks in
  expect_equal(set_rn(df, c("a", "b", "a")),
               data.frame(a = 1:3, b = 4:6, row.names = c("a", "b", "a-1")))
  expect_equal(set_rn(df, rep_len("foo", nrow(df))),
               data.frame(a = 1:3, b = 4:6, row.names = c("foo", "foo-1", "foo-2")))

  # errors out; wrong length
  expect_error(set_rn(df, c("a", "b")), "invalid 'row.names' length")
  # errors out; not a df
  expect_error(set_rn(matrix(0, ncol = 1), "a"), "`data` must be a data.frame")

  # overwriting existing rn
  x <- set_rn(df, rn)
  expect_equal(rownames(set_rn(x, toupper(rn))), toupper(rn))
})

test_that("`rm_rn()` removes rownames properly", {
  expect_equal(.row_names_info(mtcars, 1L), 32)
  expect_equal(.row_names_info(rm_rn(mtcars), 1L), -32)

  expect_equal(.row_names_info(data.frame(a = 1:4), 1L), -4)
  expect_equal(.row_names_info(rm_rn(data.frame(a = 1:4)), 1L), -4)
})

test_that("`implicit_rn()` doesn't get tricked", {
  expect_true(has_implicit_rn(data.frame(a = 1)))
  expect_false(has_implicit_rn(data.frame(a = 1, row.names = "a")))
  expect_false(has_implicit_rn(mtcars))
  expect_true(has_implicit_rn(iris))
  expect_false(has_implicit_rn(data.frame()))
})
