
# Setup ----
file   <- test_path("testdata", "single_sample.adat")
header <- parseHeader(file)

# Testing ----
test_that("`parseHeader()` correctly parses header information of an ADAT", {
  # test the Col.Meta entry up front (too big)
  expect_equal(header$file_specs$data_begin - (header$file_specs$table_begin + 1),
               length(header$Col.Meta))
  expect_named(header, c("Header.Meta", "Col.Meta", "file_specs", "row_meta"))
  expect_true(all(lengths(header$Col.Meta) == 5284L))
  expect_named(header$Col.Meta, c("SeqId", "SeqIdVersion", "SomaId",
                                  "TargetFullName", "Target", "UniProt",
                                  "EntrezGeneID", "EntrezGeneSymbol",
                                  "Organism", "Units", "Type", "Dilution",
                                  "PlateScale_Reference", "CalReference",
                                  "Cal_Example_Adat_Set001", "ColCheck",
                                  "CalQcRatio_Example_Adat_Set001_170255",
                                  "QcReference_170255",
                                  "Cal_Example_Adat_Set002",
                                  "CalQcRatio_Example_Adat_Set002_170255"))

  expect_equal(header$Header.Meta$COL_DATA$Name, names(header$Col.Meta),
               ignore_attr = TRUE)

  # remove Col.Meta entry and snapshot
  header <- header[names(header) != "Col.Meta"]
  expect_snapshot(header)
})


# Edge cases --------
test_that("`parseHeader()` free form section", {
  fil <- tempfile("header-", fileext = ".txt")
  cat("^HEADER\n!Version\t1.2\n^FreeForm\n!BumbleFish\tLion\n", file = fil)
  x <- parseHeader(fil)
  unlink(fil)
  expect_true(x$file_specs$empty_adat)
  expect_equal(x$Header.Meta$FreeForm$BumbleFish, .setAttr("Lion", "!BumbleFish"))
})

test_that("`parseHeader()` COL_DATA section", {
  fil <- tempfile("header-", fileext = ".txt")
  cat("^HEADER\n!Version\t1.2\n^COL_DATA\n!Name\tDog\tCat\tBear\n", file = fil)
  x <- parseHeader(fil)
  unlink(fil)
  expect_true(x$file_specs$empty_adat)
  expect_false(x$file_specs$old_adat)
  expect_equal(x$Col.Meta, list())
  expect_equal(x$Header.Meta$COL_DATA$Name,
               .setAttr(c("Dog", "Cat", "Bear"), "!Name"))
})

test_that("`parseHeader()` ROW_DATA section", {
  fil <- tempfile("header-", fileext = ".txt")
  cat("^HEADER\n!Version\t1.2\n^ROW_DATA\n!Name\tBear\tCat\tDog\n", file = fil)
  x <- parseHeader(fil)
  unlink(fil)
  expect_true(x$file_specs$empty_adat)
  expect_false(x$file_specs$old_adat)
  expect_equal(x$Col.Meta, list())
  expect_equal(x$Header.Meta$ROW_DATA$Name,
               .setAttr(c("Bear", "Cat", "Dog"), "!Name"))
})

test_that("`parseHeader()` skips blank rows in header section", {
  fil <- tempfile("header-", fileext = ".txt")
  cat("^HEADER\n!Version\t1.2\n!Key\tvalue\n", file = fil)
  x <- parseHeader(fil)
  unlink(fil)
  fil2 <- tempfile("header-", fileext = ".txt")
  cat("^HEADER\n!Version\t1.2\n\n!Key\tvalue\n", file = fil2)
  expect_warning(
    y <- parseHeader(fil2),
    "Blank row detected in `Header` section ... it will be skipped."
  )
  unlink(fil2)
  expect_equal(x, y)
})

test_that("trim runaway tabs in anchor lines and throw warning", {
  anchors <- c("^HEADER", "^ROW_META", "^COL_META", "^TABLE_BEGIN")
  lapply(anchors, function(.x) expect_equal(.trimRunawayTabs(.x), .x))
  expect_warning(
    y <- .trimRunawayTabs("^HEADER\t"),
    "Trailing tabs filling out header block in one of:"
  )
  expect_equal(y, "^HEADER")
  expect_warning(
    y <- .trimRunawayTabs("^TABLE_BEGIN\t"),
    "Trailing tabs filling out header block in one of:"
  )
  expect_equal(y, "^TABLE_BEGIN")
  # no caret ^ symbol; no trimming
  expect_equal(.trimRunawayTabs("TABLE_BEGIN"), "TABLE_BEGIN")
  expect_equal(.trimRunawayTabs("TABLE_BEGIN\t\t\t"), "TABLE_BEGIN\t\t\t")
  # tabs do not trail to end; no trimming
  expect_equal(.trimRunawayTabs("^HEADER\t\t\t\tfoo"), ("^HEADER\t\t\t\tfoo"))
})

test_that("catch for non-square Col.Meta section", {
  fil <- tempfile("header-", fileext = ".txt")
  cat(paste0("^HEADER\n!Version\t1.2\n",
             "^TABLE_BEGIN\n",
             "\t\t\tSeqId\ta\tb\tc\n",
             "\t\t\tType\t1\t2\t3\t4\n",
             "PlateId\n"), file = fil)
  expect_error(
    parseHeader(fil),
    paste0("Col.Meta lengths unequal! The Col.Meta block in not square\\.\n",
           "There may be trailing tabs in the Col.Meta section\\.")
  )
  unlink(fil)
})

# .getHeaderLines() ----
test_that("`.getHeaderLines()` grabs the header correctly, not the whole file", {
  fil <- tempfile("header-", fileext = ".txt")
  cat(paste0("^HEADER\n!Version\t1.2\n",
             "^TABLE_BEGIN\n",
             "\t\t\tSeqId\ta\tb\tc\n",
             "\t\t\tType\t1\t2\t3\t4\n",
             "PlateId\n"), file = fil)
  expect_length(.getHeaderLines(fil), 6L)
  expect_equal(.getHeaderLines(fil)[6L], "PlateId")
  unlink(fil)

  # create a dummy header
  fil     <- tempfile("header-", fileext = ".txt")
  header  <- rep_len("Key\tValue\n", 40L)
  colmeta <- paste0(strrep("\t", 25L), "SeqId", strrep("\t1234-7", 1000L), "\n")
  plate   <- paste0("PlateId", strrep("\t", 500L), "\n")
  cat(header, "TABLE_BEGIN\n", colmeta, plate, file = fil, sep = "")
  expect_length(.getHeaderLines(fil), 43L)
  expect_equal(.getHeaderLines(fil)[43L], trimws(plate, whitespace = "[\r\n]"))
})

test_that("`.getHeaderLines()` grabs header correctly, with actual ADAT", {
  lines <- .getHeaderLines(file)
  expect_length(lines, 42L)
  rowmetaline <- paste0(header$row_meta, collapse = "\t")
  L <- header$file_specs$data_begin
  expect_equal(trimws(lines[L]), rowmetaline)
  expect_match(
    squish(lines[L + 1L]),  # pick the single sample
    paste("Example Adat Set001 2020-06-18 SG15214400 H7 258495800010 8 3",
          "Sample 20 Plasma-PPT 1.00193072 PASS 0.98411617 1.03270156",
          "0.91519153 [0-9\\. ]+")
  )
})

# empty ADAT ----
test_that("an empty ADAT is correctly handled", {
  file <- test_path("testdata", "empty.adat")
  x <- .getHeaderLines(file)
  expect_length(x, 40L)
  x <- parseHeader(file)
  expect_named(x, c("Header.Meta", "Col.Meta", "file_specs"))
  expect_true(x$file_specs$empty_adat)
})
