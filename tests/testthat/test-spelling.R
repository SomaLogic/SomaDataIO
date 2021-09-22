
test_that("SomaDataIO has no spelling errors", {
  on_check <- !identical(Sys.getenv("_R_CHECK_PACKAGE_NAME_"), "")
  skip_if(on_check, "On devtools::check()")
  skip_on_covr()
  spelling_errors <- spelling::spell_check_package(ifelse(is_testing(), "../..", "."))
  expect_length(spelling_errors$word, 0)
})
