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

# Urine / CSF / single dilution matrices ----
# scale factor columns differ from plasma-style 20/0.5/0.005:
#   urine / CSF:    single dilution + NormGroups -> NormScale_75_S1, ...
#   dotted:         dilutions written with dots  -> NormScale_0.3, ...
#   single dilution                              -> NormScale_2.5
scenarios <- list(
  urine        = list(dilutions = "75", norm_groups = c("S1", "S2", "S3")),
  dotted_dil   = list(dilutions = c("0.3", "0.05", "0.008"), norm_groups = NULL),
  single_dil   = list(dilutions = "2.5", norm_groups = NULL)
)

# analytes and scale factor column for each group of analytes
group_info <- function(x) {
  g <- SomaDataIO:::.getNormGroups(x)
  Map(function(apts, sf) list(apts = apts, sf = sf), g, attr(g, "sf_cols"))
}

for ( nm in names(scenarios) ) {
  sc <- scenarios[[nm]]

  test_that(paste0("`reverseMedianNormalize()` reverses normalization [", nm, "]"), {
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE))
    res <- reverseMedianNormalize(x, verbose = FALSE)
    smp <- x$SampleType == "Sample"

    expect_match(attr(res, "Header.Meta")$HEADER$ProcessSteps, "rev-MedNormSMP")
    for ( gi in group_info(x) ) {
      # scale factors reset to 1 for study samples only
      expect_true(all(res[[gi$sf]][smp] == 1))
      expect_equal(res[[gi$sf]][!smp], x[[gi$sf]][!smp])
      # RFU divided by the scale factor for study samples
      expect_equal(
        as.matrix(res[smp, gi$apts]),
        as.matrix(x[smp, gi$apts]) / x[[gi$sf]][smp],
        ignore_attr = TRUE
      )
      expect_equal(as.matrix(res[!smp, gi$apts]), as.matrix(x[!smp, gi$apts]),
                   ignore_attr = TRUE)
    }
  })

  test_that(paste0("`reverseMedianNormalize()` errors if no scale columns match [", nm, "]"), {
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE))
    x <- x[, grep("^NormScale", names(x), invert = TRUE)]
    expect_error(
      reverseMedianNormalize(x, verbose = FALSE),
      "No normalization scale factor columns found to reverse"
    )
  })

  test_that(paste0("`reverseMedianNormalize()` reverses ANML normalization [", nm, "]"), {
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE, anml = TRUE))
    res <- reverseMedianNormalize(x, verbose = FALSE)
    smp <- x$SampleType == "Sample"

    expect_match(attr(res, "Header.Meta")$HEADER$ProcessSteps, "rev-anmlSMP")
    for ( gi in group_info(x) ) {
      expect_true(all(res[[gi$sf]][smp] == 1))
      expect_equal(res[[gi$sf]][!smp], x[[gi$sf]][!smp])
      expect_equal(
        as.matrix(res[smp, gi$apts]),
        as.matrix(x[smp, gi$apts]) / x[[gi$sf]][smp],
        ignore_attr = TRUE
      )
    }
    # ANMLFractionUsed cleared for study samples only
    frac <- grep("^ANMLFractionUsed_", names(res), value = TRUE)
    expect_length(frac, length(group_info(x)))
    for ( col in frac ) {
      expect_true(all(is.na(res[[col]][smp])))
      expect_false(any(is.na(res[[col]][!smp])))
    }
  })

  test_that(paste0("`reverseMedianNormalize()` errors if only some scale columns exist [", nm, "]"), {
    skip_if(length(group_info(do.call(mock_matrix_adat, sc))) < 2L)
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE))
    drop <- grep("^NormScale_", names(x), value = TRUE)[1L]
    x <- x[, setdiff(names(x), drop)]
    expect_error(
      reverseMedianNormalize(x, verbose = FALSE),
      "scale factor column\\(s\\) not found for group\\(s\\)"
    )
  })

  test_that(paste0("`reverseMedianNormalize()` returns data if no study samples [", nm, "]"), {
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE))
    x$SampleType <- "QC"
    x <- x[, grep("^NormScale", names(x), invert = TRUE)]
    expect_no_error(res <- reverseMedianNormalize(x, verbose = FALSE))
    expect_equal(as.data.frame(res), as.data.frame(x))
  })

  test_that(paste0("`reverseMedianNormalize()` -> `medianNormalize()` round trip [", nm, "]"), {
    x <- do.call(mock_matrix_adat, c(sc, normalized = TRUE))
    unnorm <- reverseMedianNormalize(x, verbose = FALSE)
    res <- medianNormalize(unnorm, verbose = FALSE)
    expect_setequal(grep("^NormScale", names(res), value = TRUE),
                    grep("^NormScale", names(x), value = TRUE))
    expect_true(is.soma_adat(res))
  })
}

test_that("`reverseMedianNormalize()` works without a `Type` column in Col.Meta", {
  x <- mock_matrix_adat("75", c("S1", "S2", "S3"), normalized = TRUE)
  cm <- attr(x, "Col.Meta")
  cm$Type <- NULL
  attr(x, "Col.Meta") <- cm
  expect_no_error(reverseMedianNormalize(x, verbose = FALSE))
})
