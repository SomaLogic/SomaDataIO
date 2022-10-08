
# Setup ----
file   <- system.file("example", "example_data.adat",
                      package = "SomaDataIO", mustWork = TRUE)
header <- parseHeader(file)

# Testing ----
test_that("`parseHeader()` correctly parses header information of an ADAT", {
  expect_type(header, "list")
  expect_type(header$file_specs, "list")
  expect_named(header, c("Header.Meta", "Col.Meta", "file_specs", "row_meta"))
  expect_named(header$file_specs,
               c("empty_adat", "table_begin",
                 "col_meta_start", "col_meta_shift",
                 "data_begin", "old_adat"))
  expect_false(header$file_specs$empty_adat)
  expect_equal(header$file_specs$table_begin, 45)
  expect_equal(header$file_specs$col_meta_start, 46)
  expect_equal(header$file_specs$col_meta_shift, 35)
  expect_equal(header$file_specs$data_begin, 66)
  expect_false(header$file_specs$old_adat)
  expect_equivalent(header$Header.Meta$ROW_DATA$Name, header$row_meta)
  expect_equal(attr(header$Header.Meta$ROW_DATA$Name, "raw_key"), "!Name")
  expect_equivalent(header$Header.Meta$COL_DATA$Name, names(header$Col.Meta))
  expect_equal(attr(header$Header.Meta$COL_DATA$Name, "raw_key"), "!Name")
  expect_equal(header$file_specs$data_begin -
               (header$file_specs$table_begin + 1),
               length(header$Col.Meta))
  expect_named(header$Header.Meta,
               c("HEADER", "COL_DATA", "ROW_DATA", "TABLE_BEGIN"))
  expect_named(header$Col.Meta,
               c("SeqId", "SeqIdVersion", "SomaId", "TargetFullName",
                 "Target", "UniProt", "EntrezGeneID", "EntrezGeneSymbol",
                 "Organism", "Units", "Type", "Dilution", "PlateScale_Reference",
                 "CalReference", "Cal_Example_Adat_Set001", "ColCheck",
                 "CalQcRatio_Example_Adat_Set001_170255", "QcReference_170255",
                 "Cal_Example_Adat_Set002", "CalQcRatio_Example_Adat_Set002_170255"))
  expect_true(all(lengths(header$Col.Meta) == 5284))
  expect_type(header$Header.Meta$HEADER, "list")
  # HEADER entry
  expect_length(header$Header.Meta$HEADER, 37L)
  HD <- header$Header.Meta$HEADER
  tbl <- list(
    AdatId              = "GID-1234-56-789-abcdef",
    Version             = "1.2",
    AssayType           = "PharmaServices",
    AssayVersion        = "V4",
    AssayRobot          = "Fluent 1 L-307",
    Legal               = paste("Experiment details and data have been",
                                "processed to protect Personally Identifiable",
                                "Information (PII) and comply with existing",
                                "privacy laws."),
    CreatedBy           = "PharmaServices",
    CreatedDate         = "2020-07-24",
    EnteredBy           = "Technician1",
    ExpDate             = "2020-06-18, 2020-07-20",
    GeneratedBy         = "Px (Build:  : ), Canopy_0.1.1",
    RunNotes            = paste("2 columns ('Age' and 'Sex') have been added",
                                "to this ADAT. Age has been randomly",
                                "increased or decreased by 1-2 years to",
                                "protect patient information"),
    ProcessSteps        = paste("Raw RFU, Hyb Normalization, medNormInt",
                                "(SampleId), plateScale, Calibration, anmlQC,",
                                "qcCheck, anmlSMP"),
   ProteinEffectiveDate = "2019-08-06",
    StudyMatrix         = "EDTA Plasma",
    PlateType           = character(0),
    LabLocation         = "SLUS",
    StudyOrganism       = character(0),
    Title               = "Example Adat Set001, Example Adat Set002",
    AssaySite           = "SW",
    CalibratorId        = "170261",
    HybNormReference    = "intraplate",
    MedNormReference    = "intraplate",
    NormalizationAlgorithm                  = "ANML",
    PlateScale_ReferenceSource              = "Reference_v4_Plasma_Calibrator_170261",
    PlateScale_Scalar_Example_Adat_Set001   = "1.08091554",
    PlateScale_PassFlag_Example_Adat_Set001 = "PASS",
    CalibrationReference                    = "Reference_v4_Plasma_Calibrator_170261",
    CalPlateTailPercent_Example_Adat_Set001 = "0.1",
    PlateTailPercent_Example_Adat_Set001    = "1.2",
    PlateTailTest_Example_Adat_Set001       = "PASS",
    PlateScale_Scalar_Example_Adat_Set002   = "1.09915270",
    PlateScale_PassFlag_Example_Adat_Set002 = "PASS",
    CalPlateTailPercent_Example_Adat_Set002 = "2.6",
    PlateTailPercent_Example_Adat_Set002    = "4.2",
    PlateTailTest_Example_Adat_Set002       = "PASS"
  )
  expect_true("ReportConfig" %in% names(HD))   # test that it's there
  i <- which(names(HD) == "ReportConfig")
  expect_equivalent(HD[-i], tbl)   # don't test attributes; skip ReportConfig
  expect_equal(header$Header.Meta$TABLE_BEGIN, basename(file))
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
  expect_length(.getHeaderLines(fil), 43)
  expect_equal(.getHeaderLines(fil)[43L], trimws(plate, whitespace = "[\r\n]"))
})

test_that("`.getHeaderLines()` grabs header correctly, with actual ADAT", {
  lines <- .getHeaderLines(file)
  expect_length(lines, 80L)
  rowmetaline <- paste0(header$row_meta, collapse = "\t")
  L <- header$file_specs$data_begin
  expect_equal(trimws(lines[L]), rowmetaline)
  expect_match(
    squish(lines[L + 2L]),  # pick sample #2
    paste("Example Adat Set001 2020-06-18 SG15214400 H8 258495800004 7 2",
          "Sample 20 Plasma-PPT 0.96671829 PASS 0.96022505 0.84858420",
          "0.85201953 [0-9\\. ]+")
  )
})

# empty ADAT ----
test_that("an empty ADAT is correctly handled", {
  file <- test_path("testdata/empty.adat")
  x <- .getHeaderLines(file)
  expect_length(x, 40L)
  x <- parseHeader(file)
  expect_named(x, c("Header.Meta", "Col.Meta", "file_specs"))
  expect_true(x$file_specs$empty_adat)
})
