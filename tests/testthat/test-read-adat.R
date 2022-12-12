
# Setup ----
f <- system.file("example", "single_sample.adat",
                 package = "SomaDataIO", mustWork = TRUE)
adat <- read_adat(f)

# Testing ----
test_that("`read_adat()` is the correct class", {
  expect_s3_class(adat, "soma_adat")
  expect_s3_class(adat, "data.frame")
})

test_that("`read_adat()` attributes are correct", {
  atts <- attributes(adat)
  expect_named(atts,
               c("names",
                 "class",
                 "row.names",
                 "Header.Meta",
                 "Col.Meta",
                 "file_specs",
                 "row_meta"))
  expect_named(atts$file_specs,
               c("empty_adat",
                 "table_begin",
                 "col_meta_start",
                 "col_meta_shift",
                 "data_begin",
                 "old_adat"))
  expect_false(atts$file_specs$empty_adat)
  expect_equal(atts$file_specs$table_begin, 20)
  expect_equal(atts$file_specs$col_meta_start, 21)
  expect_equal(atts$Header.Meta$TABLE_BEGIN, basename(f))
  expect_equal(atts$file_specs$col_meta_shift, 35)
  expect_equal(atts$file_specs$data_begin, 41)
  expect_false(atts$file_specs$old_adat)
  expect_equal(atts$row_meta, utils::head(names(adat), 34L))
  expect_equal(atts$Header.Meta$ROW_DATA$Name,
               .setAttr(utils::head(names(adat), 34L), "!Name"))
  expect_named(atts$Header.Meta,
               c("HEADER", "COL_DATA", "ROW_DATA", "TABLE_BEGIN"))
  expect_named(atts$Col.Meta,
               c('SeqId', 'SeqIdVersion', 'SomaId', 'TargetFullName',
                 'Target', 'UniProt', 'EntrezGeneID', 'EntrezGeneSymbol',
                 'Organism', 'Units', 'Type', 'Dilution',
                 'PlateScale_Reference', 'CalReference',
                 'Cal_Example_Adat_Set001', 'ColCheck',
                 'CalQcRatio_Example_Adat_Set001_170255', 'QcReference_170255',
                 'Cal_Example_Adat_Set002',
                 'CalQcRatio_Example_Adat_Set002_170255', 'Dilution2'))
  expect_true(all(lengths(atts$Col.Meta) == 5284L))
})

test_that("`read_adat()` the dimensions of the 'soma_adat' object are correct", {
  expect_equal(dim(adat), c(1L, 5318L))
  expect_equal(adat$Sex, "M")
})

test_that("`read_adat()` produces the correct RFU values", {
  expect_equal(median(adat$seq.3343.1), 2046.6)
  apts <- getAnalytes(adat)
  expect_equal(sum(adat[, apts]), 21311516)
})

test_that("is.intact.attributes produces an error when it should", {
  expect_true(is.intact.attributes(adat))          # good attributes
  attributes(adat) <- attributes(adat)[ -c(5, 6)]  # break attributes
  expect_false(is.intact.attributes(adat))
})

test_that("an empty ADAT is correctly handled", {
  expect_warning(
    tbl <- read_adat(test_path("testdata/empty.adat")),
    paste("No RFU feature data in ADAT.",
          "Returning a `tibble` object with Column Meta data only."),
  )
  expect_s3_class(tbl, "tbl_df")
  expect_equal(tbl, attr(adat, "Col.Meta"), check.attributes = FALSE)
})

# print.soma_adat -------
test_that("print.soma_adat() returns original object", {
  dump <- tempfile(pattern = "tmp-")
  withr::local_output_sink(dump)    # dump console output
  y <- print(adat)
  z <- print(adat, show_header = TRUE)
  expect_equal(y, adat)
  expect_equal(z, adat)
  unlink(dump)
})

# is.soma_adat -------
test_that("is.soma_adat() checks class correctly", {
  expect_true(is.soma_adat(adat))
  expect_false(is.soma_adat(unclass(adat)))
})
