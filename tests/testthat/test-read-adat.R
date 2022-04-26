
# Setup ----
f <- system.file("example", "single_sample.adat",
                 package = "SomaDataIO", mustWork = TRUE)
adat <- read_adat(f)

# Testing ----
test_that("read_adat is the correct class", {
  expect_s3_class(adat, "soma_adat")
  expect_s3_class(adat, "data.frame")
})

test_that("read_adat attributes are correct", {
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
  expect_equal(atts$row_meta, utils::head(names(adat), 34))
  expect_equal(atts$Header.Meta$ROW_DATA$Name,
               utils::head(names(adat), 34))
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
  expect_true(all(lengths(atts$Col.Meta) == 5284))
})

test_that("`read_adat()` the dimensions of the 'soma_adat' object are correct", {
  expect_equal(dim(adat), c(1, 5318))
  expect_equal(adat$Sex, "M")
})

test_that("read_adat produces the correct RFU values", {
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

# write ------
test_that("`write_adat()` function produced identical object when read back", {
  f_check <- tempfile(fileext = ".adat")
  write_adat(adat, file = f_check)
  # some attributes are expected to be false:
  #   TABLE_BEGIN will shift due to CreatedBy & CreatedDate changes
  #   Strings in Col.Meta are cleaned up "," -> ";"
  expect_equivalent(read_adat(f_check), adat)
  unlink(f_check)
})

test_that("`write_adat()` throws error when no file name is passed", {
  expect_error(write_adat(adat), "Must provide output file name ...")
})

test_that("`write_adat()` throws warning when passing invalid file format", {
  skip_on_os("windows")
  f_fail <- sub("//", "/", tempfile(fileext = ".txt"))
  expect_warning(
    write_adat(adat, file = f_fail),
    paste0(
      "File extension is not `*.adat` ('", f_fail, "').",
      " Are you sure this is the correct file extension?"),
    fixed = TRUE
  )
  unlink(f_fail)
})

test_that("`write_adat()` shifts Col.Meta correctly when clinical data added/removed", {
  # rm meta data
  f_check <- tempfile(fileext = ".adat")
  short   <- dplyr::select(head(adat),
                           SlideId, Subarray, SampleGroup,
                           seq.2182.54, seq.2190.55)
  write_adat(short, file = f_check)
  expect_equivalent(read_adat(f_check), short)
  expect_equal(getMeta(short), getMeta(read_adat(f_check)))
  unlink(f_check)

  # add meta data
  f_check2 <- tempfile(fileext = ".adat")
  long     <- head(adat)
  long$foo <- "bar"
  write_adat(long, file = f_check2)  # write_adat() re-orders meta to come 1st!
  new <- read_adat(f_check2)
  expect_equivalent(new[, getMeta(new)], long[, getMeta(long)])
  expect_equivalent(new[, getAnalytes(new)], long[, getAnalytes(long)])
  unlink(f_check2)
})

# print.soma_adat -------
test_that("print.soma_adat() returns original object", {
  skip_on_os("windows")
  withr::local_output_sink("/dev/null")    # dump console output
  y <- print(adat)
  z <- print(adat, show_header = TRUE)
  expect_equal(y, adat)
  expect_equal(z, adat)
})

# is.soma_adat -------
test_that("is.soma_adat() checks class correctly", {
  expect_true(is.soma_adat(adat))
  expect_false(is.soma_adat(unclass(adat)))
})
