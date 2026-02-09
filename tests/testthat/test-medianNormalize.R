# Setup ----
# Create a minimal test dataset with options for small vs full size
create_test_data <- function(small = FALSE) {
  data("example_data", package = "SomaDataIO")

  if (small) {
    # Ultra-small dataset for most tests: 3 samples, subset of analytes
    sample_indices <- which(example_data$SampleType == "Sample")[1:2]
    qc_indices <- which(example_data$SampleType == "QC")[1:1]
    subset_indices <- c(sample_indices, qc_indices)

    # Select subset of analytes from different dilution groups for speed
    analytes <- getAnalytes(example_data)
    analyte_info <- getAnalyteInfo(example_data)

    # Get first 50 analytes from each dilution group for faster processing
    selected_analytes <- c()
    for (dil in unique(analyte_info$Dilution)) {
      dil_analytes <- analytes[analyte_info$Dilution == dil]
      selected_analytes <- c(selected_analytes, head(dil_analytes, 50))
    }

    test_adat <- example_data[subset_indices, c(getMeta(example_data), selected_analytes)]
  } else {
    # Standard test dataset: 16 samples, all analytes (for comprehensive tests)
    sample_indices <- which(example_data$SampleType == "Sample")[1:12]
    qc_indices <- which(example_data$SampleType == "QC")[1:4]
    subset_indices <- c(sample_indices, qc_indices)
    test_adat <- example_data[subset_indices, ]
  }

  # Modify header to simulate pre-ANML state (remove ANML steps)
  header_meta <- attr(test_adat, "Header.Meta")
  if (!is.null(header_meta) && !is.null(header_meta$HEADER)) {
    # Remove ANML and median normalization steps to simulate pre-processed state
    header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, plateScale, Calibration"
    attr(test_adat, "Header.Meta") <- header_meta
  }

  # Return subset with representative samples
  test_adat
}

test_data <- create_test_data(small = TRUE)
test_data_full <- create_test_data(small = FALSE)

# Testing ----
test_that("`medianNormalize` Method 1: Internal reference (default)", {

  # Test default internal reference method
  expect_no_error(
    result <- medianNormalize(test_data, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups
  expect_true(all(norm_cols %in% names(result)))

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(0.971895, 1.029779, 1.199944), tolerance = 0.000001)
  expect_equal(result$NormScale_0_005[1:3], c(1.002922, 0.997176, 1.058289), tolerance = 0.000001)
  expect_equal(result$NormScale_0_5[1:3], c(0.973205, 1.028323, 1.104745), tolerance = 0.000001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(463.1, 488.5, 501.5))
  expect_equal(result$seq.10001.7[1:3], c(301.4, 302.2, 207.4))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("MedNormSMP", result_header$ProcessSteps))
  expect_equal(result_header$NormalizationAlgorithm, "MedNorm")
  expect_true(grepl("intraplate, crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` Method 2: Reference from specific samples", {

  # Test with specific reference field and value - using QC as reference but normalizing both QC and Sample
  expect_no_error(
    result <- medianNormalize(test_data,
                              ref_field = "SampleType",
                              ref_value = "QC",
                              do_regexp = "QC|Sample",  # Normalize both types
                              verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output - normalized both QC and Sample types, so QC (3rd) gets scale factor 1.0
  expect_equal(result$NormScale_20[1:3], c(0.9089, 0.9578, 1.0000), tolerance = 0.001)
  expect_equal(result$NormScale_0_005[1:3], c(0.9783, 0.9806, 1.0000), tolerance = 0.001)
  expect_equal(result$NormScale_0_5[1:3], c(0.9879, 1.1445, 1.0000), tolerance = 0.001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(433.1, 454.4, 501.5), tolerance = 0.1)
  expect_equal(result$seq.10008.43[1:3], c(510.6, 519.0, 510.1), tolerance = 0.1)

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("intraplate, crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` Method 3: Reference from another ADAT", {
  # Create a minimal reference ADAT from sample subset
  ref_adat <- test_data[1:2, ]  # Use first 2 samples as reference

  expect_no_error(
    result <- medianNormalize(test_data, reference = ref_adat, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(0.9719, 1.0298, 1.1999), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(1.0029, 0.9972, 1.0583), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.9732, 1.0283, 1.1047), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(463.1, 488.5, 501.5), tolerance = 0.1)
  expect_equal(result$seq.10008.43[1:3], c(546, 558, 510.1), tolerance = 0.1)

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("external_adat", result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` External reference data.frame", {
  # Create reference data.frame with SeqId-Reference format
  analyte_info <- getAnalyteInfo(test_data)
  ref_data <- data.frame(
    SeqId = analyte_info$SeqId[1:15],  # Use first 15 SeqIds
    Reference = runif(15, 2000, 4000),  # Random reference values
    stringsAsFactors = FALSE
  )

  expect_no_error(
    result <- medianNormalize(test_data, reference = ref_data, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("external_data", result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))

  # Check that medNormSMP_ReferenceRFU field was added with proper formatting
  result_analyte_info <- getAnalyteInfo(result)
  expect_true("medNormSMP_ReferenceRFU" %in% names(result_analyte_info))

  # Check reference values are rounded to 2 decimal places
  ref_values <- result_analyte_info$medNormSMP_ReferenceRFU
  rounded_values <- round(ref_values, 2)
  expect_equal(ref_values[!is.na(ref_values)], rounded_values[!is.na(rounded_values)])
})

test_that("`medianNormalize` validates input requirements", {

  # Test with non-soma_adat object
  expect_error(
    medianNormalize(data.frame(a = 1:3, b = 4:6)),
    "`adat` must be a class `soma_adat` object"
  )

  # Test with missing hybridization normalization
  test_data_no_hyb <- test_data
  header_meta <- list(HEADER = list(ProcessSteps = "SomeOtherStep"))
  attr(test_data_no_hyb, "Header.Meta") <- header_meta

  expect_error(
    medianNormalize(test_data_no_hyb),
    "Hybrid normalization step not detected"
  )

  # Test with missing normalization scale factors
  test_data_no_norm <- test_data |>
    dplyr::select(-c(NormScale_0_005, NormScale_0_5, NormScale_20))
  header_meta <- list(HEADER = list(ProcessSteps = "Hyb Normalization"))
  attr(test_data_no_norm, "Header.Meta") <- header_meta

  expect_error(
    medianNormalize(test_data_no_norm),
    "No normalization scale factor columns found"
  )

  # Test with invalid reference field
  expect_error(
    medianNormalize(test_data, ref_field = "NonExistentField", verbose = FALSE),
    "Reference field `NonExistentField` not found"
  )

  # Test with invalid reference data.frame (missing required columns)
  invalid_ref <- data.frame(Wrong = c("10000-28", "10001-7"), Column = c(1000, 2000))
  expect_error(
    medianNormalize(test_data, reference = invalid_ref, verbose = FALSE),
    "Reference data must contain 'SeqId' and 'Reference' columns"
  )

  # Test with invalid reference type (non-data.frame)
  expect_error(
    medianNormalize(test_data, reference = "invalid_string", verbose = FALSE),
    "Invalid reference type"
  )

  # Test with numeric input
  expect_error(
    medianNormalize(test_data, reference = 123, verbose = FALSE),
    "Invalid reference type"
  )
})

test_that("`medianNormalize` external reference data.frame validation", {
  # Test with invalid SeqId format (should error when no matches found)
  invalid_seqid_ref <- data.frame(
    SeqId = c("invalid_format_1", "invalid_format_2"),  # Invalid SeqId format
    Reference = c(2500, 1800),
    stringsAsFactors = FALSE
  )

  expect_error(
    medianNormalize(test_data, reference = invalid_seqid_ref, verbose = FALSE),
    "No matching SeqIds or dilution groups found in reference data"
  )

  # Test with empty reference data
  empty_ref <- data.frame(
    SeqId = character(0),
    Reference = numeric(0),
    stringsAsFactors = FALSE
  )

  expect_error(
    medianNormalize(test_data, reference = empty_ref, verbose = FALSE),
    "No matching SeqIds or dilution groups found in reference data"
  )
})

test_that("`medianNormalize` handles grouping correctly", {
  # Test grouping by Sex
  expect_no_error(
    result1 <- medianNormalize(test_data, by = "Sex", do_regexp = "Sample", verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result1))
  norm_cols <- grep("^NormScale_", names(result1), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output - will vary based on grouping by sex
  expect_equal(result1$NormScale_20[1:3], c(0.971895, 1.029779, 1.199944), tolerance = 0.000001)
  expect_equal(result1$NormScale_0_005[1:3], c(1.002922, 0.997176, 1.058289), tolerance = 0.000001)
  expect_equal(result1$NormScale_0_5[1:3], c(0.973205, 1.028323, 1.104745), tolerance = 0.000001)

  # Test specific SeqId columns
  expect_equal(result1$seq.10000.28[1:3], c(463.1, 488.5, 501.5))
  expect_equal(result1$seq.10008.43[1:3], c(546.0, 558.0, 510.1))

  # Test grouping by multiple variables - use full example data
  if ("PlateId" %in% names(test_data_full)) {
    expect_no_error(
      result2 <- medianNormalize(test_data_full, by = c("PlateId", "SampleType"), verbose = FALSE)
    )

    # Check result structure
    expect_true(is.soma_adat(result2))
    norm_cols <- grep("^NormScale_", names(result2), value = TRUE)
    expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

    # Test scale factor output
    expect_equal(result2$NormScale_20[1:3], c(1.0678, 1.0571, 1.0917), tolerance = 0.001)
    expect_equal(result2$NormScale_0_005[1:3], c(1.0225, 1.0012, 1.0122), tolerance = 0.001)
    expect_equal(result2$NormScale_0_5[1:3], c(1.1031, 1.0544, 1.1087), tolerance = 0.001)

    # Test specific SeqId columns
    expect_equal(result2$seq.10000.28[1:3], c(508.8, 501.5, 453.7))
    expect_equal(result2$seq.10008.43[1:3], c(599.9, 572.8, 462.8))
  }

  # Test error with non-existent grouping column
  expect_error(
    medianNormalize(test_data, by = "NonExistentColumn", verbose = FALSE),
    "Grouping column\\(s\\) not found"
  )
})

test_that("`medianNormalize` handles sample selection correctly", {
  # Test selective normalization
  expect_no_error(
    result <- medianNormalize(test_data,
                              do_field = "SampleType",
                              do_regexp = "QC",
                              verbose = FALSE)
  )
  expect_true(is.soma_adat(result))

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output - same as Method 2 for QC selection
  expect_equal(result$NormScale_20[1:3], c(1.036936, 0.960225, 1.08410), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.857016, 0.848584, 1.05488), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.777175, 0.85202, 0.96014), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(476.5, 474.4, 543.7))
  expect_equal(result$seq.10008.43[1:3], c(561.8, 541.9, 553.0))

  # Test with non-existent field
  expect_error(
    medianNormalize(test_data, do_field = "NonExistentField", verbose = FALSE),
    "Field `NonExistentField` not found"
  )

  # Test with pattern that matches no samples
  expect_error(
    medianNormalize(test_data, do_regexp = "NoMatchPattern", verbose = FALSE),
    "No samples selected for normalization"
  )
})

test_that("`medianNormalize` produces expected verbose output", {
  # specific verbose output messages
  expect_snapshot(
    result <- medianNormalize(test_data, verbose = TRUE)
  )

  # no output
  expect_message(
    result <- medianNormalize(test_data, verbose = FALSE),
    NA  # NA indicates no output expected
  )
})

test_that("`medianNormalize` can reverse ANML normalization", {
  # Create ANML-like test data by modifying test_data
  anml_test_data <- test_data

  # Modify header to simulate ANML-processed data
  header_meta <- attr(anml_test_data, "Header.Meta")
  header_meta$HEADER$ProcessSteps <- "Raw RFU, Hyb Normalization, medNormInt (SampleId), plateScale, Calibration, anmlQC, qcCheck, anmlSMP"
  header_meta$HEADER$NormalizationAlgorithm <- "ANML"
  attr(anml_test_data, "Header.Meta") <- header_meta

  # Add ANML-like normalization scale factors (non-1.0 values to simulate ANML)
  anml_test_data$NormScale_20 <- c(1.15, 0.95, 1.08)
  anml_test_data$NormScale_0_5 <- c(1.22, 0.88, 1.12)
  anml_test_data$NormScale_0_005 <- c(0.93, 1.07, 0.98)

  # Add ANMLFractionUsed columns to mimic ANML data
  anml_test_data$ANMLFractionUsed_20 <- c(0.85, 0.92, 0.78)
  anml_test_data$ANMLFractionUsed_0_5 <- c(0.88, 0.91, 0.83)
  anml_test_data$ANMLFractionUsed_0_005 <- c(0.90, 0.87, 0.85)

  # Test ANML reversal
  expect_no_error(
    result <- medianNormalize(anml_test_data, reverse_existing = TRUE, verbose = FALSE)
  )

  # Check that result is valid
  expect_true(is.soma_adat(result))

  # Check that ProcessSteps includes reversal and new normalization
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("rev-anmlSMP", result_header$ProcessSteps))
  expect_true(grepl("MedNormSMP", result_header$ProcessSteps))

  # Test that error occurs without reverse_existing flag
  expect_error(
    medianNormalize(anml_test_data, reverse_existing = FALSE, verbose = FALSE),
  )
})

test_that("`medianNormalize` handles SeqId reference format properly", {
  # Test with SeqId-Reference format
  analytes <- getAnalytes(test_data)
  seqids <- getAnalyteInfo(test_data)$SeqId[1:10]  # First 10 SeqIds

  ref_data <- data.frame(
    SeqId = seqids,
    Reference = runif(10, 1000, 5000)  # Random reference values
  )

  expect_no_error(
    result <- medianNormalize(test_data, reference = ref_data, verbose = FALSE)
  )

  # Check that result is valid
  expect_true(is.soma_adat(result))

  # Check that medNormSMP_ReferenceRFU field was added with 2 decimal places
  analyte_info <- getAnalyteInfo(result)
  expect_true("medNormSMP_ReferenceRFU" %in% names(analyte_info))

  # Check reference values are rounded to 2 decimal places
  ref_values <- analyte_info$medNormSMP_ReferenceRFU
  rounded_values <- round(ref_values, 2)
  expect_equal(ref_values[!is.na(ref_values)], rounded_values[!is.na(rounded_values)])
})
