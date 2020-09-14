
# Testing ----
test_that("Sample objects are created properly", {
  expect_is(example_data, "soma_adat")
  expect_is(ex_target_names, "list")
  expect_length(ex_features, 5284)
  expect_length(ex_target_names, 5284)
  expect_equal(dim(ex_feature_table), c(5284, 22))
  expect_named(ex_feature_table, c("AptName",
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
  expect_is(ex_feature_table, "tbl_df")
  expect_equal(ex_features, getAptamers(example_data))
  expect_named(ex_target_names, ex_features)
  expect_equal(ex_target_names %>% unlist() %>% unname(),
               ex_feature_table$TargetFullName)
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
