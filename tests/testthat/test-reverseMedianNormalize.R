# Setup ----
data("example_data", package = "SomaDataIO")

# Create small representative subset for faster tests
test_data_full <- example_data[1:3, ]

# Testing  ----
test_that("`reverseMedianNormalize` reverses ANML normalization", {
  # Use example_data which already has anmlSMP ProcessStep
  anml_data <- test_data_full

  # Verify it has anmlSMP in ProcessSteps (should already be there)
  header_meta <- attr(anml_data, "Header.Meta")
  expect_true(grepl("anmlSMP", header_meta$HEADER$ProcessSteps))

  # Add ANML-like normalization scale factors
  anml_data$NormScale_20 <- c(1.15, 0.95, 1.08)
  anml_data$NormScale_0_5 <- c(1.22, 0.88, 1.12)
  anml_data$NormScale_0_005 <- c(0.93, 1.07, 0.98)

  # Reverse ANML normalization
  expect_no_error(
    result <- reverseMedianNormalize(anml_data, verbose = FALSE)
  )

  # Check that result is valid
  expect_true(is.soma_adat(result))

  # Check that ProcessSteps includes reversal
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("rev-anmlSMP", result_header$ProcessSteps))

  # Check that scale factors are reset to 1.0 for study samples
  sample_mask <- result$SampleType == "Sample"
  expect_true(all(result$NormScale_20[sample_mask] == 1.0))
  expect_true(all(result$NormScale_0_5[sample_mask] == 1.0))
  expect_true(all(result$NormScale_0_005[sample_mask] == 1.0))
})

test_that("`reverseMedianNormalize` error conditions", {
  # Create unnormalized data by modifying ProcessSteps
  unnormalized_data <- test_data_full
  header_meta <- attr(unnormalized_data, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, medNormInt, plateScale, Calibration"
  attr(unnormalized_data, "Header.Meta") <- header_meta

  # Test with unnormalized data (should error)
  expect_error(
    reverseMedianNormalize(unnormalized_data, verbose = FALSE),
    "No evidence of median normalization applied to study samples"
  )

  # Test with non-soma_adat object
  expect_error(
    reverseMedianNormalize(data.frame(a = 1:3, b = 4:6)),
    "`adat` must be a class `soma_adat` object"
  )
})

test_that("`reverseMedianNormalize` + `medianNormalize` workflow", {
  # Create normalized data with MedNormSMP
  normalized_data <- test_data_full
  header_meta <- attr(normalized_data, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, medNormInt (SampleId), plateScale, Calibration, MedNormSMP"
  attr(normalized_data, "Header.Meta") <- header_meta
  normalized_data$NormScale_20 <- c(1.05, 0.98, 1.12)
  normalized_data$NormScale_0_5 <- c(1.08, 0.92, 1.15)
  normalized_data$NormScale_0_005 <- c(0.97, 1.03, 0.95)

  # Test complete workflow: reverse then re-normalize
  expect_no_error(
    unnormalized <- reverseMedianNormalize(normalized_data, verbose = FALSE)
  )

  expect_no_error(
    renormalized <- medianNormalize(unnormalized, verbose = FALSE)
  )

  # Check final result structure
  expect_true(is.soma_adat(renormalized))
  final_header <- attr(renormalized, "Header.Meta")$HEADER
  expect_true(grepl("rev-MedNormSMP", final_header$ProcessSteps))
  expect_true(grepl("MedNormSMP", final_header$ProcessSteps))
})

test_that("`reverseMedianNormalize` validates normalization is final SMP step", {
  # Test error when normalization is not the final SMP transformation step
  test_data_invalid <- test_data_full
  header_meta <- attr(test_data_invalid, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, anmlSMP, medNormInt, CustomSMP"  # anmlSMP not final SMP step
  attr(test_data_invalid, "Header.Meta") <- header_meta

  expect_error(
    reverseMedianNormalize(test_data_invalid, verbose = FALSE),
    "Median/ANML normalization of study samples is not the final SMP transformation step"
  )
})

test_that("`reverseMedianNormalize` works with production ADATs having Filtered step", {
  # Test that function works when "Filtered" step is appended after normalization
  filtered_data <- test_data_full
  header_meta <- attr(filtered_data, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, medNormInt, plateScale, anmlSMP, Filtered"
  attr(filtered_data, "Header.Meta") <- header_meta

  # Add normalization scale factors
  filtered_data$NormScale_20 <- c(1.15, 0.95, 1.08)
  filtered_data$NormScale_0_5 <- c(1.22, 0.88, 1.12)
  filtered_data$NormScale_0_005 <- c(0.93, 1.07, 0.98)

  # Should not error despite "Filtered" being the final step
  expect_no_error(
    result <- reverseMedianNormalize(filtered_data, verbose = FALSE)
  )

  # Check that result is valid and normalization was reversed
  expect_true(is.soma_adat(result))
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("rev-anmlSMP", result_header$ProcessSteps))
  
  # Scale factors should be reset to 1.0 for study samples
  sample_mask <- result$SampleType == "Sample"
  expect_true(all(result$NormScale_20[sample_mask] == 1.0))
  expect_true(all(result$NormScale_0_5[sample_mask] == 1.0))
  expect_true(all(result$NormScale_0_005[sample_mask] == 1.0))
})

test_that("`reverseMedianNormalize` handles ANMLFractionUsed columns properly", {
  # Test clearing ANML-specific metadata columns
  test_data_anml <- test_data_full
  header_meta <- attr(test_data_anml, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, medNormInt, plateScale, anmlSMP"
  attr(test_data_anml, "Header.Meta") <- header_meta

  # Add ANML metadata columns
  test_data_anml$ANMLFractionUsed_20 <- c(0.85, 0.92, 0.78)
  test_data_anml$ANMLFractionUsed_0_5 <- c(0.91, 0.87, 0.95)
  test_data_anml$NormScale_20 <- c(1.15, 0.95, 1.08)
  test_data_anml$NormScale_0_5 <- c(1.22, 0.88, 1.12)

  result <- reverseMedianNormalize(test_data_anml, verbose = FALSE)

  # ANMLFractionUsed columns should be cleared for study samples
  expect_true(is.na(result$ANMLFractionUsed_20[1]))  # Sample should be NA
  expect_true(is.na(result$ANMLFractionUsed_0_5[1]))  # Sample should be NA

  # Scale factors should be reset to 1.0 for study samples
  expect_equal(result$NormScale_20[1], 1.0)
  expect_equal(result$NormScale_0_5[1], 1.0)
})
