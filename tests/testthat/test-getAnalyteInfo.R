
anno <- getAnalyteInfo(example_data)

test_that("`getAnalyteInfo()` generates correct objects", {
  expect_s3_class(anno, "tbl_df")
  expect_equal(dim(anno), c(getAnalytes(example_data, n = TRUE), 22L))
  expect_setequal(anno$AptName, getAnalytes(example_data))
  expect_equal(vapply(anno, typeof, ""),
               c(AptName          = "character",
                 SeqId            = "character",
                 SeqIdVersion     = "double",
                 SomaId           = "character",
                 TargetFullName   = "character",
                 Target           = "character",
                 UniProt          = "character",
                 EntrezGeneID     = "character",
                 EntrezGeneSymbol = "character",
                 Organism         = "character",
                 Units            = "character",
                 Type             = "character",
                 Dilution         = "character",
                 PlateScale_Reference = "double",
                 CalReference     = "double",
                 Cal_Example_Adat_Set001 = "double",
                 ColCheck         = "character",
                 CalQcRatio_Example_Adat_Set001_170255 = "double",
                 QcReference_170255      = "double",
                 Cal_Example_Adat_Set002 = "double",
                 CalQcRatio_Example_Adat_Set002_170255 = "double",
                 Dilution2        = "double"))
})

test_that("`getAnalyteInfo()` error conditions are triggered", {
  x <- example_data
  attr(x, "Col.Meta") <- as.data.frame(attr(x, "Col.Meta"))
  expect_error(
    getAnalyteInfo(x),
    "`Col.Meta` must be a `tbl_df`."
  )
  attr(x, "Col.Meta") <- NULL
  expect_error(
    getAnalyteInfo(x),
    "`Col.Meta` is absent from ADAT."
  )
})

test_that("`getAnalyteInfo()` warning if Col.Meta out-of-sync with features", {
  # option 1; features in data but not in Col.Meta
  x <- example_data
  attr(x, "Col.Meta") <- head(attr(x, "Col.Meta"), -1L)  # rm final row
  expect_warning(
    y <- getAnalyteInfo(x),
    "Features inconsistent between `AptName` vs `SeqId` in `getAnalyteInfo()`.",
    fixed = TRUE
  )
  # tibble with NAs for missing features
  n <- getAnalytes(x, n = TRUE)
  expect_equal(dim(y), c(n, 22L))
  # all NAs except for 2 columns (AptName, SeqId)
  expect_equal(sum(!is.na(tail(y, 1L))), 2)

  # option 2; features in Col.Meta but not in data
  # rename final column
  x <- example_data
  attr(x, "Col.Meta")[n + 1L, ] <- attr(x, "Col.Meta")[n, ]  # add dummy feature
  attr(x, "Col.Meta")[n + 1L, 1L] <- "9999-99"
  expect_warning(
    y <- getAnalyteInfo(x),
    "Features inconsistent between `AptName` vs `SeqId` in `getAnalyteInfo()`.",
    fixed = TRUE
  )
  # no NAs; extra 9999-99 feature dropped
  expect_equal(dim(y), c(n, 22L))
})
