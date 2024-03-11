
# Setup ----
clin_file <- system.file("cli/merge", "meta.csv", package = "SomaDataIO",
                          mustWork = TRUE)
clin_df <- read.csv(clin_file, header = TRUE, colClasses = c(SampleId = "character"))
apts <- withr::with_seed(123, sample(getAnalytes(example_data), 2L))
adat <- head(example_data, 9L) |> dplyr::select(SampleId, all_of(apts))

# Testing ----
test_that("`merge_clin()` generates expected, merged output", {
  merged <- merge_clin(adat, clin_df, by = "SampleId")
  expect_true(all(names(adat) %in% names(merged)))
  expect_equal(setdiff(names(merged), names(adat)), c("group", "newvar"))
  expect_equal(dim(merged), c(9, 5L))
  expect_equal(sum(is.na(merged)), 8L)
  expect_equal(sum(merged$newvar, na.rm = TRUE), -1.779255)
})

test_that("`merge_clin()` generates same result on `clin_data` argument", {
  expect_equal(
    merge_clin(adat, clin_df, by = "SampleId"),
    merge_clin(adat, clin_file, by = "SampleId", by_class = c(SampleId = "character"))
  )
})

test_that("`merge_clin()` errors on bad `clin_data` argument", {
  expect_error( merge_clin(adat, letters) )
  expect_error( merge_clin(adat, 1:10L) )
  expect_error( merge_clin(adat, "Samples") )
  expect_error( merge_clin(adat, NA) )
  expect_error( merge_clin(adat, NA_character_) )
  expect_error( merge_clin(data.frame(adat)) )
})
