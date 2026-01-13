# Setup ----
# Create a minimal test dataset
create_test_data <- function() {
  data("example_data", package = "SomaDataIO")
  # Select samples ensuring we have both Sample and QC types
  sample_indices <- which(example_data$SampleType == "Sample")[1:12]
  qc_indices <- which(example_data$SampleType == "QC")[1:4]

  # Combine indices and subset
  subset_indices <- c(sample_indices, qc_indices)
  test_adat <- example_data[subset_indices, ]

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

test_data <- create_test_data()

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
  expect_equal(result$NormScale_20[1:3], c(1.067845, 1.057102, 1.091748), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(1.022533, 1.001174, 1.012215), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(1.103112, 1.054358, 1.108711), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(508.8, 501.5, 453.7))
  expect_equal(result$seq.10008.43[1:3], c(599.9, 572.8, 462.8))

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
  expect_equal(result$NormScale_20[1:3], c(1.0369358, 0.9602251, 0.9841162), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.8570162, 0.8485842, 1.0327016), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.7771749, 0.8520195, 0.9151915), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(476.5, 474.4, 415.6))
  expect_equal(result$seq.10008.43[1:3], c(561.8, 541.9, 423.9))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl("intraplate, crossplate", result_header$MedNormReference))
})

test_that("`medianNormalize` Method 3: Reference from another ADAT", {
  # Create a minimal reference ADAT from sample subset
  ref_adat <- test_data[1:4, ]  # Use first 4 samples as reference

  expect_no_error(
    result <- medianNormalize(test_data, reference = ref_adat, verbose = FALSE)
  )

  # Check result structure
  expect_true(is.soma_adat(result))
  norm_cols <- grep("^NormScale_", names(result), value = TRUE)
  expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(0.9907154, 1.0109152, 0.9931271), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(1.005733, 1.008454, 0.986035), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(1.0090878, 0.9909594, 1.0002446), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(472.1, 479.6, 412.7))
  expect_equal(result$seq.10008.43[1:3], c(556.6, 547.8, 421.0))

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
  expect_equal(result$NormScale_20[1:3], c(2.937272, 2.982111, 2.936927), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.6313838, 0.5966632, 0.6624721), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.7147623, 0.7780614, 0.7704032), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(1399.6, 1414.7, 1220.6))
  expect_equal(result$seq.10008.43[1:3], c(1650.2, 1616.0, 1245.0))

  # Check header metadata
  result_header <- attr(result, "Header.Meta")$HEADER
  expect_true(grepl(basename(temp_csv), result_header$MedNormReference))
  expect_true(grepl("crossplate", result_header$MedNormReference))

  # Clean up
  unlink(temp_csv)

  # Test with TSV file
  temp_tsv <- tempfile(fileext = ".tsv")
  write.table(ref_data, temp_tsv, sep = "\t", row.names = FALSE)

  expect_no_error(
    result2 <- medianNormalize(test_data, reference = temp_tsv, verbose = FALSE)
  )

  expect_true(is.soma_adat(result2))

  # Test scale factor output
  expect_equal(result2$NormScale_20[1:3], c(2.937272, 2.982111, 2.936927), tolerance = 0.0001)
  expect_equal(result2$NormScale_0_005[1:3], c(0.6313838, 0.5966632, 0.6624721), tolerance = 0.0001)
  expect_equal(result2$NormScale_0_5[1:3], c(0.7147623, 0.7780614, 0.7704032), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result2$seq.10000.28[1:3], c(1399.6, 1414.7, 1220.6))
  expect_equal(result2$seq.10008.43[1:3], c(1650.2, 1616.0, 1245.0))

  # Clean up
  unlink(temp_tsv)
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
  expect_equal(result$NormScale_20[1:3], c(2.937272, 2.982111, 2.936927), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.6313838, 0.5966632, 0.6624721), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.7147623, 0.7780614, 0.7704032), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(1399.6, 1414.7, 1220.6))
  expect_equal(result$seq.10008.43[1:3], c(1650.2, 1616.0, 1245.0))

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

  # Test scale factor output
  expect_equal(result1$NormScale_20[1:3], c(1.066964, 1.060173, 1.020341), tolerance = 0.0001)
  expect_equal(result1$NormScale_0_005[1:3], c(1.000455, 1.005372, 1.000000), tolerance = 0.0001)
  expect_equal(result1$NormScale_0_5[1:3], c(1.115562, 1.050018, 1.030397), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result1$seq.10000.28[1:3], c(508.4, 502.9, 424.1))
  expect_equal(result1$seq.10008.43[1:3], c(599.4, 574.5, 432.5))

  # Test grouping by multiple variables
  if ("PlateId" %in% names(test_data)) {
    expect_no_error(
      result2 <- medianNormalize(test_data, by = c("PlateId", "SampleType"), verbose = FALSE)
    )

    # Check result structure
    expect_true(is.soma_adat(result2))
    norm_cols <- grep("^NormScale_", names(result2), value = TRUE)
    expect_equal(length(norm_cols), 3)  # Should have 3 dilution groups

    # Test scale factor output
    expect_equal(result2$NormScale_20[1:3], c(1.053656, 1.059554, 1.068602), tolerance = 0.0001)
    expect_equal(result2$NormScale_0_005[1:3], c(1.0124749, 1.0053543, 0.9992799), tolerance = 0.0001)
    expect_equal(result2$NormScale_0_5[1:3], c(1.080347, 1.056874, 1.074292), tolerance = 0.0001)

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

  # Test scale factor output
  expect_equal(result$NormScale_20[1:3], c(1.0369358, 0.9602251, 0.9841162), tolerance = 0.0001)
  expect_equal(result$NormScale_0_005[1:3], c(0.8570162, 0.8485842, 1.0327016), tolerance = 0.0001)
  expect_equal(result$NormScale_0_5[1:3], c(0.7771749, 0.8520195, 0.9151915), tolerance = 0.0001)

  # Test specific SeqId columns
  expect_equal(result$seq.10000.28[1:3], c(476.5, 474.4, 415.6))
  expect_equal(result$seq.10008.43[1:3], c(561.8, 541.9, 423.9))

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
