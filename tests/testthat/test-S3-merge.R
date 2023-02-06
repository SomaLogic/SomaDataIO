
# Testing ----
test_that("`merge.soma_adat()` triggers the expected lifecycle error messages", {
  data <- mock_adat()
  merge_data <- data.frame(SampleId = sample(data$SampleId), NewData = 6:1)
  # check lifecycle defunct is dispatched
  lifecycle::expect_defunct( merge(data, merge_data) )
  # check that error is triggered and messages are delivered
  expect_snapshot_error( merge(data, merge_data, by = "SampleId") )
})
