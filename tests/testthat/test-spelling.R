
test_that("SomaDataIO has no spelling errors", {
  skip_on_check()
  skip_on_covr()
  spell_df <- spelling::spell_check_package(ifelse(is_testing(), "../..", "."))
  spell_df <- dplyr::filter(spell_df, !grepl("Col.Meta", found))  # rm Col.Meta.Rd
  expect_length(spell_df$word, 0)
})
