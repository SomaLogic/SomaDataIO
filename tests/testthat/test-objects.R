
# Testing ----
test_that("Sample objects are created properly", {
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
