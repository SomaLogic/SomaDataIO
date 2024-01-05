
test_that("interactive session can be forced ON, but only within temp scope", {
  with_interactive(TRUE, {
    expect_true(interactive())
  })
  with_interactive(FALSE, {
    expect_false(interactive())
  })
  expect_false(interactive())   # FALSE during testthat
})
