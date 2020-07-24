
# Testing ----
test_that("Sample objects are created properly", {
  expect_is(sample.adat, "soma_adat")
  expect_is(ex_target_names, "list")
  expect_length(ex_features, 1129)
  expect_length(ex_target_names, 1129)
  expect_equal(dim(ex_feature_table), c(1129, 16))
  expect_named(ex_feature_table, c("AptName",
                                   "SeqId",
                                   "SomaId",
                                   "Target",
                                   "TargetFullName",
                                   "UniProt",
                                   "EntrezGeneID",
                                   "EntrezGeneSymbol",
                                   "Organism",
                                   "Units",
                                   "Type",
                                   "CalReference",
                                   "Dilution",
                                   "ColCheck",
                                   "Cal.Set.A",
                                   "Dilution2"))
  expect_is(ex_feature_table, "tbl_df")
  expect_equal(ex_features, getAptamers(sample.adat))
  expect_named(ex_target_names, ex_features)
  expect_equal(ex_target_names %>% unlist() %>% unname(),
               ex_feature_table$TargetFullName)
  meta <- c("PlateId", "SlideId", "Subarray",
            "SampleId", "SampleType", "SampleMatrix",
            #"Barcode", "Barcode2d", "SampleNotes",
            "TimePoint", "SampleGroup", "SiteId",
            "Subject_ID", "HybControlNormScale", "RowCheck",
            "NormScale_40", "NormScale_0_005", "NormScale_1")
  expect_equal(getMeta(sample.adat), meta)
  expect_equal(dim(sample.adat), c(20, 1144))
})
