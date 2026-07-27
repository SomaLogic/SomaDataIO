
# Testing ----
test_that("Sample objects are created properly", {
  # Test lazy-loaded objects
  expect_s3_class(example_data, "soma_adat")
  expect_s3_class(ex_target_names, "target_map")
  expect_length(ex_analytes, 5284)
  expect_length(ex_target_names, 5284)
  expect_equal(dim(ex_anno_tbl), c(5284, 22))
  expect_named(ex_anno_tbl, c("AptName",
                              "SeqId",
                              "SeqIdVersion",
                              "SomaId",
                              "TargetFullName",
                              "Target",
                              "UniProt",
                              "EntrezGeneID",
                              "EntrezGeneSymbol",
                              "Organism",
                              "Units",
                              "Type",
                              "Dilution",
                              "PlateScale_Reference",
                              "CalReference",
                              "Cal_Example_Adat_Set001",
                              "ColCheck",
                              "CalQcRatio_Example_Adat_Set001_170255",
                              "QcReference_170255",
                              "Cal_Example_Adat_Set002",
                              "CalQcRatio_Example_Adat_Set002_170255",
                              "Dilution2"))
  expect_s3_class(ex_anno_tbl, "tbl_df")
  expect_equal(ex_analytes, getAnalytes(example_data))
  expect_named(ex_target_names, ex_analytes)
  expect_equal(unlist(ex_target_names, use.names = FALSE),
               ex_anno_tbl$TargetFullName)
  meta <- c("PlateId", "PlateRunDate", "ScannerID", "PlatePosition",
            "SlideId", "Subarray", "SampleId", "SampleType",
            "PercentDilution", "SampleMatrix", "Barcode", "Barcode2d",
            "SampleName", "SampleNotes", "AliquotingNotes",
            "SampleDescription", "AssayNotes", "TimePoint",
            "ExtIdentifier", "SsfExtId", "SampleGroup", "SiteId",
            "TubeUniqueID", "CLI", "HybControlNormScale", "RowCheck",
            "NormScale_20", "NormScale_0_005", "NormScale_0_5",
            "ANMLFractionUsed_20", "ANMLFractionUsed_0_005",
            "ANMLFractionUsed_0_5", "Age", "Sex")
  expect_equal(getMeta(example_data), meta)
  expect_equal(dim(example_data), c(192, 5318))
})

# Test creation functions ----
test_that("create_example_data() generates proper soma_adat objects", {
  # Test minimal
  mini <- create_example_data("minimal")
  expect_s3_class(mini, "soma_adat")
  expect_equal(dim(mini), c(10, 5318))
  expect_equal(length(getAnalytes(mini)), 5284)
  expect_equal(length(getMeta(mini)), 34)
  # First 10 samples: 9 Sample + 1 Calibrator (from original data)
  expect_equal(sum(mini$SampleType == "Sample"), 9)
  
  # Test full
  full <- create_example_data("full")
  expect_s3_class(full, "soma_adat")
  expect_equal(dim(full), c(192, 5318))
  expect_equal(as.numeric(table(full$SampleType)),
               c(6, 10, 6, 170))  # Buffer, Calibrator, QC, Sample
  
  # Test attributes
  expect_true(!is.null(attr(full, "Header.Meta")))
  expect_true(!is.null(attr(full, "Col.Meta")))
  expect_equal(dim(attr(full, "Col.Meta")), c(5284, 21))
})

test_that("create_ex_* helper functions work correctly", {
  # These should create from full by default
  apts <- create_ex_analytes()
  expect_length(apts, 5284)
  expect_true(all(grepl("^seq\\.", apts)))
  
  anno <- create_ex_anno_tbl()
  expect_equal(dim(anno), c(5284, 22))
  expect_true("AptName" %in% names(anno))
  
  targets <- create_ex_target_names()
  expect_length(targets, 5284)
  expect_s3_class(targets, "target_map")
  
  clin <- create_ex_clin_data()
  expect_equal(dim(clin), c(170, 3))
  expect_named(clin, c("SampleId", "smoking_status", "alcohol_use"))
})

