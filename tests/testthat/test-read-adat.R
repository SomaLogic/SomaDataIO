
# Setup ----
f <- test_path("testdata", "single_sample.adat")
adat <- read_adat(f)

# Testing ----
test_that("`read_adat()` is the correct class", {
  expect_s3_class(adat, "soma_adat")
  expect_s3_class(adat, "data.frame")
})

test_that("`read_adat()` attributes are correct", {
  atts <- attributes(adat)
  expect_named(atts, c("names", "class", "row.names", "Header.Meta",
                       "Col.Meta", "file_specs", "row_meta"))
  expect_equal(atts$Header.Meta$TABLE_BEGIN, basename(f))
  expect_equal(atts$Header.Meta$ROW_DATA$Name, .setAttr(getMeta(adat), "!Name"))
  expect_named(atts$Header.Meta, c("HEADER", "COL_DATA", "ROW_DATA", "TABLE_BEGIN"))
  expect_named(atts$Col.Meta,c("SeqId", "SeqIdVersion", "SomaId", "TargetFullName",
                               "Target", "UniProt", "EntrezGeneID", "EntrezGeneSymbol",
                               "Organism", "Units", "Type", "Dilution",
                               "PlateScale_Reference", "CalReference",
                               "Cal_Example_Adat_Set001", "ColCheck",
                               "CalQcRatio_Example_Adat_Set001_170255",
                               "QcReference_170255", "Cal_Example_Adat_Set002",
                               "CalQcRatio_Example_Adat_Set002_170255", "Dilution2"))
  expect_true(all(lengths(atts$Col.Meta) == 5284L))
  # do not test here -> too much output
  slim_atts <- atts[!names(atts) %in% c("names", "Col.Meta")]
  expect_snapshot( slim_atts )
})

test_that("`read_adat()` the dimensions of the 'soma_adat' object are correct", {
  expect_equal(dim(adat), c(1L, 5318L))
  expect_equal(adat$Sex, "M")
})

test_that("`read_adat()` produces the correct RFU values", {
  withr::local_options(list(digits = 14))
  expect_snapshot(adat$seq.3343.1)                 # random specific analyte
  expect_snapshot(sum(adat[, getAnalytes(adat)]))  # sum of all analytes
})

test_that("`is_intact_attr()` produces an error when it should", {
  expect_true(is_intact_attr(adat))                  # good attributes
  attributes(adat) <- attributes(adat)[ -c(5L, 6L)]  # break attributes
  expect_false(is_intact_attr(adat))
})

test_that("an empty ADAT is correctly handled", {
  expect_warning(
    tbl <- read_adat(test_path("testdata/empty.adat")),
    paste("No RFU feature data in ADAT.",
          "Returning a `tibble` object with Column Meta data only."),
  )
  expect_s3_class(tbl, "tbl_df")
  expect_equal(tbl, attr(adat, "Col.Meta"), ignore_attr = TRUE)
})

# print.soma_adat ----
test_that("print.soma_adat() returns original object", {
  dump <- tempfile("print-", fileext = ".txt")
  withr::local_output_sink(dump)    # dump console output
  y <- print(adat)
  z <- print(adat, show_header = TRUE)
  expect_equal(y, adat)
  expect_equal(z, adat)
  unlink(dump)
})

# is.soma_adat ----
test_that("is.soma_adat() checks class correctly", {
  expect_true(is.soma_adat(adat))
  expect_false(is.soma_adat(unclass(adat)))
})
