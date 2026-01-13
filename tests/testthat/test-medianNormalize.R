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
  expect_equal(result$NormScale_20[1:3], c(0.971895, 1.029779, 1), tolerance = 0.000001)
  expect_equal(result$NormScale_0_005[1:3], c(1.002922, 0.997176, 1), tolerance = 0.000001)
  expect_equal(result$NormScale_0_5[1:3], c(0.973205, 1.028323, 1), tolerance = 0.000001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(463.1, 488.5, 501.5))
  expect_equal(result$seq.10001.7[1:3], c(301.4, 302.2, 207.4))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("medNormInt", result_header$ProcessSteps))
  expect_equal(result_header$NormalizationAlgorithm, "MedNorm")
  expect_true(grepl("intraplate, crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` Method 2: Reference from specific samples", {

  # Test with specific reference field and value
  expect_no_error(
    result <- medianNormalize(test_data,
                              ref_field = "SampleType",
                              ref_value = "QC",
                              do_regexp = "QC",
                              verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(1.0369358, 0.9602251, 1), tolerance = 0.000001)
  expect_equal(result$NormScale_0_005[1:3], c(0.8570162, 0.8485842, 1), tolerance = 0.000001)
  expect_equal(result$NormScale_0_5[1:3], c(0.7771749, 0.8520195, 1), tolerance = 0.000001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(476.5, 474.4, 501.5))
  expect_equal(result$seq.10008.43[1:3], c(561.8, 541.9, 510.1))

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
  expect_equal(result$NormScale_20[1:3], c(0.9718953, 1.0297787, 1.0841026), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(1.0029224, 0.9971762, 1.0548762), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.9732045, 1.0283228, 0.9601410), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(463.1, 488.5, 543.7))
  expect_equal(result$seq.10008.43[1:3], c(546, 558, 553))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("external_adat", result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` Method 4: External reference file", {
  # Create a temporary CSV file with reference data
  # Use realistic dilution groups from example_data: "20", "0.5", "0.005", "0"
  ref_data <- data.frame(
    Dilution = c("20", "0_5", "0_005", "0"),
    Reference = c(2500.5, 1800.2, 3200.8, 1500.0),
    stringsAsFactors = FALSE
  )

  # Create temporary CSV file
  temp_csv <- tempfile(fileext = ".csv")
  write.csv(ref_data, temp_csv, row.names = FALSE)

  expect_no_error(
    result <- medianNormalize(test_data, reference = temp_csv, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(3.31, 3.71, 4.21), tolerance = 0.01)
  expect_equal(result$NormScale_0_005[1:3], c(0.577, 0.561, 0.561), tolerance = 0.001)
  expect_equal(result$NormScale_0_5[1:3], c(0.90, 1.18, 1.03), tolerance = 0.01)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(1579.0, 1759.9, 2109.7))
  expect_equal(result$seq.10008.43[1:3], c(1861.7, 2010.3, 2145.9))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl(basename(temp_csv), result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))

  # Clean up
  unlink(temp_csv)
})

test_that("`medianNormalize` Method 5: External reference as data.frame", {

  # Create reference data.frame with realistic dilution groups
  ref_data <- data.frame(
    Dilution = c("20", "0_5", "0_005", "0"),
    Reference = c(2500.5, 1800.2, 3200.8, 1500.0),
    stringsAsFactors = FALSE
  )

  expect_no_error(
    result <- medianNormalize(test_data, reference = ref_data, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(3.31, 3.71, 4.21), tolerance = 0.01)
  expect_equal(result$NormScale_0_005[1:3], c(0.577, 0.561, 0.561), tolerance = 0.001)
  expect_equal(result$NormScale_0_5[1:3], c(0.90, 1.18, 1.03), tolerance = 0.01)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(1579.0, 1759.9, 2109.7))
  expect_equal(result$seq.10008.43[1:3], c(1861.7, 2010.3, 2145.9))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("external_data", result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))
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
  invalid_ref <- data.frame(Wrong = c("20", "0_5"), Column = c(1000, 2000))
  expect_error(
    medianNormalize(test_data, reference = invalid_ref, verbose = FALSE),
    "Reference data must contain columns: Dilution, Reference"
  )

  # Test with non-existent reference file
  expect_error(
    medianNormalize(test_data, reference = "non_existent_file.csv", verbose = FALSE),
    "Reference file not found"
  )

  # Test with invalid reference type
  expect_error(
    medianNormalize(test_data, reference = 123, verbose = FALSE),
    "Invalid reference type"
  )
})

test_that("`medianNormalize` external reference file validation", {
  # Test with missing dilution groups in reference
  incomplete_ref <- data.frame(
    Dilution = c("20", "0_5"),  # Missing "0_005" and "0"
    Reference = c(2500, 1800),
    stringsAsFactors = FALSE
  )

  expect_error(
    medianNormalize(test_data, reference = incomplete_ref, verbose = FALSE),
    "Missing reference values for dilution groups"
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
    expect_equal(result2$NormScale_20[1:3], c(1.054, 1.060, 1.069), tolerance = 0.001)
    expect_equal(result2$NormScale_0_005[1:3], c(1.0125, 1.0054, 0.9993), tolerance = 0.001)
    expect_equal(result2$NormScale_0_5[1:3], c(1.080, 1.057, 1.074), tolerance = 0.001)

    # Test specific SeqId columns
    expect_equal(result2$seq.10000.28[1:3], c(502.1, 502.7, 444.1))
    expect_equal(result2$seq.10008.43[1:3], c(591.9, 574.2, 453.0))
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
  expect_equal(result$NormScale_20[1:3], c(1.036936, 0.960225, 1), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.857016, 0.848584, 1), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.777175, 0.85202, 1), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(476.5, 474.4, 501.5))
  expect_equal(result$seq.10008.43[1:3], c(561.8, 541.9, 510.1))

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
