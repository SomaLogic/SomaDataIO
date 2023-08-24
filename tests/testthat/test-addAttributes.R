
test_that("`addAttributes()` correctly adds the attr list", {
  df   <- data.frame(num = 1:6)
  atts <- list(A = 1:10, B = LETTERS)
  new  <- attributes(addAttributes(df, atts))
  expect_type(new, "list")
  expect_named(new, c("names", "class", "row.names", names(atts)))
  expect_equal(new$A, 1:10)
  expect_equal(new$B, LETTERS)
})

test_that("`addAttributes()` throws correct errors and messages", {
  expect_error(
    addAttributes(1:10L, list(A = 1:10)),
    "`data` must be a data frame, tibble, or similar.",
  )
  df <- data.frame(num = 1:6)
  expect_error(
    addAttributes(df, c(A = 1)),
    "`new.atts` must be a *named* list.", fixed = TRUE
  )
  expect_error(
    addAttributes(df, list(1:10)),
    "`new.atts` must be a *named* list.", fixed = TRUE
  )
})
