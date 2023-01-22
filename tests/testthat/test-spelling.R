
test_that("the `SomaDataIO` package has no spelling errors", {
  skip_on_cran()
  skip_on_ci()
  skip_on_check()
  skip_on_covr()
  spell_df <- spelling::spell_check_package(ifelse(is_testing(), "../..", "."))
  spell_df <- dplyr::filter(spell_df, !grepl("Col[.]Meta[.]Rd", found)) # rm Col.Meta.Rd
  expect_length(spell_df$word, 0L)
})
