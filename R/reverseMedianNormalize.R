#' Reverse Median Normalization from Study Samples
#'
#' @description Reverses median normalization (including ANML) that was
#' previously applied to study samples (`SampleType == "Sample"`). This function
#' is designed to work with standard SomaScan deliverable ADAT files where
#' study samples have undergone median normalization as the final processing step.
#'
#' This function validates that:
#' \enumerate{
#'   \item Study samples have a median normalization step applied
#'   \item The normalization was the last transformation applied to study samples
#'   \item The correct reversal method is applied based on the normalization type
#' }
#'
#' @section Use Cases:
#' \itemize{
#'   \item Converting from normalized ADAT to unnormalized ADAT for custom normalization
#'   \item Preparing normalized delivery data for use with `medianNormalize()` function
#'   \item Backing out normalization to apply different normalization strategies
#' }
#'
#' @section Data Requirements:
#' \itemize{
#'   \item ADAT file with study samples (`SampleType == "Sample"`) that have been
#'     median normalized (either standard median normalization or ANML)
#'   \item Intact header metadata with `ProcessSteps` field indicating the
#'     normalization history
#'   \item Median normalization must be the last processing step applied to study samples
#' }
#'
#' @param adat A `soma_adat` object with study samples that have been median normalized
#' @param verbose Logical. Should progress messages be printed? Default is `TRUE`.
#' @return A `soma_adat` object with median normalization reversed for study samples.
#'   QC, Calibrator, and Buffer samples retain their original normalization.
#'   The `ProcessSteps` header is updated to reflect the reversal operation,
#'   and median normalization-specific metadata fields are cleared.
#' @examples
#' \dontrun{
#' # Reverse normalization from a delivered ADAT file
#' normalized_adat <- read_adat("normalized_study_data.adat")
#' unnormalized_adat <- reverseMedianNormalize(normalized_adat)
#' }
#' @export
reverseMedianNormalize <- function(adat, verbose = TRUE) {

  # Input validation ----
  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

  # Get header metadata
  header <- attr(adat, "Header.Meta")$HEADER

  if (is.null(header)) {
    stop("ADAT header metadata is missing", call. = FALSE)
  }

  # Validate that study samples have been normalized ----
  process_steps <- header$ProcessSteps %||% ""

  if (process_steps == "") {
    stop(
      "ProcessSteps field is empty. Cannot determine normalization history.",
      call. = FALSE
    )
  }

  # Tokenize ProcessSteps so we can reason about ordering of steps ----
  step_tokens <- unlist(strsplit(process_steps, "\\s*[;,]\\s*"))
  step_tokens <- step_tokens[nzchar(step_tokens)]

  # Check for evidence of study sample median normalization (MedNormSMP / anmlSMP)
  has_mednorm_smp <- any(grepl("MedNormSMP", step_tokens, ignore.case = TRUE))
  has_anml_smp <- any(grepl("anmlSMP", step_tokens, ignore.case = TRUE))

  if (!has_mednorm_smp && !has_anml_smp) {
    stop(
      "No evidence of median normalization applied to study samples. ",
      "ProcessSteps: ", process_steps, ". ",
      "This function is designed to reverse median normalization from study samples.",
      call. = FALSE
    )
  }

  # Check that normalization hasn't already been reversed
  has_reversal <- any(grepl("rev-(?:MedNormSMP|medNormInt|anmlSMP|ANML)", step_tokens,
                            ignore.case = TRUE, perl = TRUE))

  if (has_reversal) {
    stop(
      "Data appears to have already been denormalized. ",
      "ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }

  # Determine which normalization type was applied to study samples ----
  # Only one type should be applied, check which was last
  # Identify the last normalization-related token and ensure it is the final step
  norm_idx <- which(
    grepl("MedNormSMP", step_tokens, ignore.case = TRUE) |
      grepl("anmlSMP", step_tokens, ignore.case = TRUE)
  )
  if (length(norm_idx) == 0L) {
    stop(
      "Could not determine normalization type from ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }
  last_norm_idx <- norm_idx[length(norm_idx)]
  if (last_norm_idx != length(step_tokens)) {
    stop(
      "Median/ANML normalization of study samples is not the final processing step. ",
      "ProcessSteps: ", process_steps, ". ",
      "Reversal requires normalization to be the last transformation applied to study samples.",
      call. = FALSE
    )
  }
  last_norm_token <- step_tokens[last_norm_idx]
  if (grepl("anmlSMP", last_norm_token, ignore.case = TRUE)) {
    normalization_type <- "anml"
  } else if (grepl("MedNormSMP", last_norm_token, ignore.case = TRUE)) {
    normalization_type <- "median"
  } else {
    stop(
      "Could not determine normalization type from ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }

  # Apply the appropriate denormalization ----
  if (normalization_type == "anml") {
    adat <- .reverseANMLSMP(adat, verbose)
  } else if (normalization_type == "median") {
    adat <- .reverseMedNormSMP(adat, verbose)
  }

  # Remove medNormSMP_ReferenceRFU field from analyte metadata after reversal ----
  col_meta <- attr(adat, "Col.Meta")
  if (!is.null(col_meta) && "medNormSMP_ReferenceRFU" %in% names(col_meta)) {
    col_meta$medNormSMP_ReferenceRFU <- NULL
    attr(adat, "Col.Meta") <- col_meta
    if (verbose) {
      cat("Removed medNormSMP_ReferenceRFU field from analyte metadata.\n")
    }
  }

  adat
}


#' Reverse Existing Median Normalization for Study Samples
#' @noRd
.reverseMedNormSMP <- function(adat, verbose) {

  # Get existing scale factors
  sf_cols <- grep("^NormScale_", names(adat), value = TRUE)

  if (length(sf_cols) == 0) {
    if (verbose) {
      cat("No existing median normalization scale factors found to reverse.\n")
    }
    return(adat)
  }

  if (verbose) {
    cat("Reversing existing median normalization for study samples...\n")
  }

  # Get dilution groups
  apt_data <- getAnalyteInfo(adat)
  dil_groups <- split(apt_data$AptName, apt_data$Dilution)
  names(dil_groups) <- gsub("\\.", "_", names(dil_groups))
  names(dil_groups) <- gsub("[.]0$|%|^[.]", "", names(dil_groups))

  # Only reverse for study samples, leave QC/Calibrator/Buffer alone
  if (is.null(adat$SampleType)) {
    stop("`SampleType` column is missing; cannot identify study samples to reverse normalization.", call. = FALSE)
  }
  sample_mask <- !is.na(adat$SampleType) & (adat$SampleType %in% "Sample")

  if (!any(sample_mask)) {
    if (verbose) {
      cat("No study samples found to reverse normalization.\n")
    }
    return(adat)
  }

  # For each dilution group, reverse normalization
  for (dil_name in names(dil_groups)) {
    sf_col <- paste0("NormScale_", dil_name)

    if (sf_col %in% names(adat)) {
      dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(adat))

      if (length(dil_apts) > 0) {
        for (i in which(sample_mask)) {
          scale_factor <- adat[[sf_col]][i]
          if (!is.na(scale_factor) && scale_factor != 0) {
            # Apply inverse of scale factor
            adat[i, dil_apts] <- adat[i, dil_apts] / scale_factor
            # Reset scale factor to 1.0
            adat[[sf_col]][i] <- 1.0
          }
        }
      }
    }
  }

  # Update ProcessSteps to indicate reversal
  header_meta <- attr(adat, "Header.Meta")
  if (!is.null(header_meta) && !is.null(header_meta$HEADER)) {
    current_steps <- header_meta$HEADER$ProcessSteps %||% ""

    # Add reversal step
    if (grepl("MedNormSMP", current_steps, ignore.case = TRUE)) {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-MedNormSMP", sep = ", ")
    }

    # Clear median normalization specific header fields
    header_meta$HEADER$NormalizationAlgorithm <- NULL
    header_meta$HEADER$MedNormReference <- NULL

    attr(adat, "Header.Meta") <- header_meta
  }

  if (verbose) {
    cat("Median normalization reversed for", sum(sample_mask), "study samples.\n")
  }

  adat
}


#' Reverse Existing ANML Normalization for Study Samples
#' @noRd
.reverseANMLSMP <- function(adat, verbose) {

  # Get existing scale factors
  sf_cols <- grep("^NormScale_", names(adat), value = TRUE)

  if (length(sf_cols) == 0) {
    if (verbose) {
      cat("No existing ANML normalization scale factors found to reverse.\n")
    }
    return(adat)
  }

  if (verbose) {
    cat("Reversing existing ANML normalization for study samples...\n")
  }

  # Get dilution groups
  apt_data <- getAnalyteInfo(adat)
  dil_groups <- split(apt_data$AptName, apt_data$Dilution)
  names(dil_groups) <- gsub("\\.", "_", names(dil_groups))
  names(dil_groups) <- gsub("[.]0$|%|^[.]", "", names(dil_groups))

  # Only reverse for study samples, leave QC/Calibrator/Buffer alone
  if (is.null(adat$SampleType)) {
    stop("`SampleType` column is missing; cannot identify study samples to reverse normalization.", call. = FALSE)
  }
  sample_mask <- !is.na(adat$SampleType) & (adat$SampleType %in% "Sample")

  if (!any(sample_mask)) {
    if (verbose) {
      cat("No study samples found to reverse ANML normalization.\n")
    }
    return(adat)
  }

  # For each dilution group, reverse ANML normalization using log space
  for (dil_name in names(dil_groups)) {
    sf_col <- paste0("NormScale_", dil_name)

    if (sf_col %in% names(adat)) {
      dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(adat))

      if (length(dil_apts) > 0) {
        for (i in which(sample_mask)) {
          scale_factor <- adat[[sf_col]][i]
          if (!is.na(scale_factor) && scale_factor != 0) {
            # ANML uses log space scaling - reverse by subtracting log scale factor
            log_sf <- log10(scale_factor)
            log_data <- log10(as.numeric(unlist(adat[i, dil_apts], use.names = FALSE)))
            reversed_log_data <- log_data - log_sf
            adat[i, dil_apts] <- 10^reversed_log_data
            # Reset scale factor to 1.0
            adat[[sf_col]][i] <- 1.0
          }
        }
      }
    }
  }

  # Clear ANMLFractionUsed columns for reversed study samples
  anml_frac_cols <- grep("^ANMLFractionUsed_", names(adat), value = TRUE)
  if (length(anml_frac_cols) > 0) {
    for (col in anml_frac_cols) {
      # Clear ANML-specific metadata for study samples that were reversed
      adat[[col]][sample_mask] <- NA
    }
  }

  # Update ProcessSteps to indicate reversal
  header_meta <- attr(adat, "Header.Meta")
  if (!is.null(header_meta) && !is.null(header_meta$HEADER)) {
    current_steps <- header_meta$HEADER$ProcessSteps %||% ""

    # Add reversal step - look for what type of ANML was reversed
    if (grepl("anmlSMP", current_steps, ignore.case = TRUE)) {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-anmlSMP", sep = ", ")
    } else if (grepl("ANML", current_steps, ignore.case = TRUE)) {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-ANML", sep = ", ")
    }

    # Clear median normalization specific header fields
    header_meta$HEADER$NormalizationAlgorithm <- NULL
    header_meta$HEADER$MedNormReference <- NULL

    attr(adat, "Header.Meta") <- header_meta
  }

  # Reset RowCheck for reversed samples
  if ("RowCheck" %in% names(adat)) {
    adat$RowCheck[sample_mask] <- "PASS"
  }

  if (verbose) {
    cat("ANML normalization reversed for", sum(sample_mask), "study samples.\n")
  }

  adat
}
