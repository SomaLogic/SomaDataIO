
# Setup ----
file <- test_path("testdata", "test-anno.xlsx")

# Testing ----
test_that("`read_annotations()` parses the annotations file correctly", {
  tbl <- read_annotations(file)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(dim(tbl), c(1L, 43L))

  # Check that required columns are present after field mapping
  expected_cols <- c("SeqId", "SomaId", "Target", "Type", "TargetFullName",
                     "Organism", "UniProt", "EntrezGeneID",
                     "EntrezGeneSymbol")
  expect_true(all(expected_cols %in% names(tbl)))
})

test_that("error conditions trigger appropriate errors", {
  expect_error(
    read_annotations("foo.txt"),
    "Annotations file must be"
  )
})
