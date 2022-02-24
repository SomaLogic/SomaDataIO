
test_that("SomaDataIO has no spelling errors", {
  skip_on_check()
  skip_on_covr()
  spelling_errors <- spelling::spell_check_package(ifelse(is_testing(), "../..", "."))
  expect_length(spelling_errors$word, 0)
})
