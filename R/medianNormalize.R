#' Perform Median Normalization
#'
#' @description Performs median normalization on a `soma_adat` object that has
#' already undergone standard data processing for array-based SomaScan studies.
#'
#' Median normalization is a common, scale-based normalization technique that
#' corrects for assay-derived technical variation by applying sample-specific
#' linear scaling to expression measurements. Typical sources of assay
#' variation include robotic and manual liquid handling, manufactured
#' consumables such as buffers and plastic goods, laboratory instrument
#' calibration, ambient environmental conditions, inter-operator differences,
#' and other sources of technical variation. Median normalization
#' can improve assay precision and reduce technical variation that can mask
#' true biological signal.
#'
#' The method scales each sample so that the center of the within-sample analyte
#' distribution aligns to a defined reference, thereby correcting
#' global intensity shifts without altering relative differences between
#' measurements within a sample. For assay formats with multiple dilution groups
#' (e.g., 1:5 or 20%;  1:200 or 0.5%, 1:20,000 or 0.005%), separate scale
#' factors are calculated for each dilution because each dilution group is
#' processed separately during the assay. For each sample, the ratio of
#' reference RFU / observed RFU is calculated for every SeqId. The median ratio
#' within each dilution group is selected as the scale factor and applied to
#' all SeqIds for that sample within the associated dilution bin.
#'
#' @section Data Requirements:
#' This function is designed for data in standard SomaLogic deliverable formats.
#' Specific ADAT file requirements:
#' \enumerate{
#'   \item \strong{Intact ADAT file}, with available data processing information
#'     in the header section. Specifically, the `ProcessSteps` field must be
#'     present and correctly represent the data processing steps present in
#'     the data table.
#'   \item \strong{Minimal standard processing}, the function assumes a standard
#'     SomaScan data deliverable with minimally standard HybNorm and PlateScale
#'     steps applied.
#' }
#'
#' \strong{Primary use cases:}
#' \itemize{
#'   \item Combining data sets from the same overarching experiment or sample
#'     population and normalize to a common reference that were originally
#'     processed separately and each normalized "withing study".
#'   \item Normalize fundamentally different types of samples separately (by
#'     group). For instance, lysate samples from different cell lines that
#'     will be analyzed separately should likely be median normalized within
#'     each cell type. Lysis buffer background samples would also be expected
#'     to be normalized separately.
#' }
#'
#' @section Important Considerations:
#' \itemize{
#'   \item A core assumption of median normalization is that the majority of
#'     analytes are not differentially expressed; consequently, users should
#'     validate this assumption by inspecting scale-factor distributions for
#'     systematic bias between the biological groups intended for comparison.
#'   \item Note this function does not perform the adaptive normalization by
#'     maximum likelihood (ANML) method which leverages a population-based
#'     reference that iteratively down-selects the set of analytes to include
#'     for the normalization calculation.
#'   \item The function requires `reverse_existing = TRUE` to be set in order
#'     to process data where study samples have already undergone ANML or
#'     standard median normalization.
#'   \item When reversing existing normalization, only study samples are
#'     reversed; QC, Calibrator, and Buffer samples retain their normalization
#' }
#'
#' @param adat A `soma_adat` object created using [read_adat()], containing
#'   RFU values that have been hybridization normalized and plate scaled.
#' @param reference Optional. Reference for median normalization. Can be:
#'   \itemize{
#'     \item `NULL` (default): Calculate an internal reference from study
#'       samples by taking the median of each SeqId within the sample
#'       grouping. For multi-plate studies, the median of all plate medians
#'       is used.
#'     \item A `soma_adat` object: Extract reference from this ADAT
#'     \item A data.frame: Use provided reference data directly
#'   }
#'   When providing an external reference data.frame it must contain:
#'   \describe{
#'     \item{SeqId}{Character column containing the SeqId identifiers mapping
#'       to those in the `soma_adat` object. Must be in "10000-28" format, not
#'       "seq.10000.28" format.}
#'     \item{Reference}{Numeric column containing the reference RFU values
#'       for each SeqId.}
#'   }
#' @param by Character vector. Grouping variable(s) for grouped median
#'   normalization. Must be column name(s) in the ADAT. Normalization will be
#'   performed within each group separately. Default is `"SampleType"`. Note
#'   that only study samples (SampleType == 'Sample') are normalized; QC,
#'   Calibrator, and Buffer samples are automatically excluded.
#' @param reverse_existing Logical. Should existing median or ANML normalization be
#'   reversed before applying new normalization? When `TRUE`, existing median
#'   normalization scale factors or ANML normalization effects are reversed for
#'   study samples only (QC, Calibrator, and Buffer samples retain their
#'   normalization). This allows re-normalization of data that has already been
#'   median normalized or ANML normalized. Default is `FALSE`.
#' @param verbose Logical. Should progress messages be printed? Default is `TRUE`.
#' @return A `soma_adat` object with median normalization applied and RFU values
#'   adjusted. The existing `NormScale_*` columns are updated to include the
#'   effects of both plate scale normalization and median normalization.
#' @examples
#' \dontrun{
#' # Internal reference from study samples (default)
#' med_norm_adat <- medianNormalize(adat)
#'
#' # Reference from another ADAT
#' ref_adat <- read_adat("reference_file.adat")
#' med_norm_adat <- medianNormalize(adat, reference = ref_adat)
#'
#' # External reference as a data.frame - requires `SeqId` and `Reference` columns
#' ref_data <- read.csv("reference_file.csv")
#' med_norm_adat <- medianNormalize(adat, reference = ref_data)
#'
#' # Custom grouping by multiple variables
#' # Use when total protein load changes due to analysis conditions
#' # (normalize within groups to account for expected biological differences)
#' med_norm_adat <- medianNormalize(adat, by = c("Sex", "SampleType"))
#'
#' # Re-normalize data that has already been median or ANML normalized
#' # Use when you want to apply different normalization to previously normalized data
#' med_norm_adat <- medianNormalize(adat,
#'                                  reverse_existing = TRUE,
#'                                  reference = new_reference)
#' }
#' @importFrom dplyr filter
#' @importFrom stats median
#' @export
medianNormalize <- function(adat,
                            reference = NULL,
                            by = "SampleType",
                            reverse_existing = FALSE,
                            verbose = TRUE) {

  # Input validation ----
  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

  # Validate reference type early
  if (!is.null(reference) && !is.soma_adat(reference) && !is.data.frame(reference)) {
    stop(
      "Invalid reference type. Must be NULL, soma_adat, or data.frame",
      call. = FALSE
    )
  }

  # Check that required normalization steps have been applied ----
  header <- attr(adat, "Header.Meta")$HEADER

  if (is.null(header)) {
    stop("ADAT header metadata is missing", call. = FALSE)
  }

  # Check for hybrid normalization
  if (!"ProcessSteps" %in% names(header) ||
      !grepl("Hyb Normalization", header$ProcessSteps, ignore.case = TRUE)) {
    stop(
      "Hybrid normalization step not detected in ProcessSteps. ",
      "Please apply hybrid normalization before median normalization.",
      call. = FALSE
    )
  }

  # Check for plate scale factors
  norm_cols <- grep("^(Norm|norm)[Ss]cale", names(adat), value = TRUE)
  if (length(norm_cols) == 0) {
    stop(
      "No normalization scale factor columns found. ",
      "Please ensure plate scale normalization has been applied.",
      call. = FALSE
    )
  }

  # Check data state and existing normalization ----
  has_existing_norm <- .validateDataState(adat, header, verbose, reverse_existing)

  # Reverse existing normalization if requested ----
  if (reverse_existing && has_existing_norm) {
    if (verbose) {
      if (grepl("ANML", header$ProcessSteps %||% "", ignore.case = TRUE)) {
        cat("Reversing existing ANML normalization for study samples...\n")
        adat <- .reverseANMLSMP(adat, verbose)
      } else {
        cat("Reversing existing median normalization for study samples...\n")
        adat <- .reverseMedNormSMP(adat, verbose)
      }
    } else {
      if (grepl("ANML", header$ProcessSteps %||% "", ignore.case = TRUE)) {
        adat <- .reverseANMLSMP(adat, verbose)
      } else {
        adat <- .reverseMedNormSMP(adat, verbose)
      }
    }
  }

  # Create dilution groups ----
  apt_data <- getAnalyteInfo(adat)

  if (!"Dilution" %in% names(apt_data)) {
    stop("Dilution information not found in analyte data", call. = FALSE)
  }

  # Filter out hybridization controls
  apt_data <- filter(apt_data, !grepl("^Hybridization", Type, ignore.case = TRUE))

  # Create dilution groups
  dil_groups <- split(apt_data$AptName, apt_data$Dilution)

  # Clean up dilution names
  names(dil_groups) <- gsub("\\.", "_", names(dil_groups))
  names(dil_groups) <- gsub("[.]0$|%|^[.]", "", names(dil_groups))

  # Validate dilution count ----
  .validateDilutionCount(dil_groups, verbose)

  # Check for existing normalization scale factors ----
  existing_norm_sf <- grep("^NormScale_", names(adat), value = TRUE)

  if ( verbose ) {
    if (length(existing_norm_sf) > 0) {
      .todo("Normalization scale factors already exist: {.val {paste0(existing_norm_sf, collapse = ', ')}} - they will be replaced with new scale factors")
    }
  }


  # Determine which samples to normalize - only Sample types
  if (!"SampleType" %in% names(adat)) {
    stop("Field 'SampleType' not found in adat columns", call. = FALSE)
  }

  do_samples <- grep("Sample", adat[["SampleType"]])
  if (length(do_samples) == 0L) {
    stop(
      "No samples selected for normalization with pattern: Sample",
      call. = FALSE
    )
  }
  dont_samples <- setdiff(seq_len(nrow(adat)), do_samples)

  # Process reference ----
  if (is.null(reference)) {
    # Check if SampleType conflicts with grouping variables
    conflicts_with_grouping <- FALSE
    if ("SampleType" %in% by) {
      samples_to_normalize <- adat[do_samples, ]
      group_values <- unique(samples_to_normalize[["SampleType"]])
      group_values <- group_values[!is.na(group_values)]
      all_groups_in_ref <- all(group_values %in% "Sample")
      conflicts_with_grouping <- !identical(by, "SampleType") || !all_groups_in_ref
    }

    if (conflicts_with_grouping) {
      # Calculate global reference to avoid groups lacking reference samples
      if (verbose) {
        .todo("Building global internal reference from study samples (SampleType == 'Sample')")
      }
      ref_data <- .buildInternalReference(adat, dil_groups)
    } else {
      # Standard internal reference - calculate per group
      ref_data <- NULL
      if (verbose) {
        .todo("Building internal reference from study samples (SampleType == 'Sample')")
      }
    }
  } else {
    ref_data <- .processReference(reference, adat, dil_groups, apt_data, verbose)
  }

  # Add row identifier to maintain order
  adat$.rowid <- seq_len(nrow(adat))

  # Perform median normalization on selected samples
  if (length(do_samples) > 0) {
    norm_adat <- .performMedianNorm(
      adat[do_samples, ],
      dil_groups = dil_groups,
      by = by,
      ref_data = ref_data,
      verbose = verbose
    )
  }

  # Handle samples that were not normalized
  if (!is.null(dont_samples) && length(dont_samples) > 0) {
    unnorm_adat <- adat[dont_samples, ]
    sf_cols <- paste0("NormScale_", names(dil_groups))

    # Check if scale factor columns already exist in the original data
    existing_sf_cols <- intersect(sf_cols, names(adat))

    # For all scale factor columns, preserve existing values or set to 1.0
    for (col in sf_cols) {
      if (col %in% existing_sf_cols) {
        # Keep the existing value as-is - unnorm_adat[[col]] already contains it
      } else {
        # Set to 1.0 for new scale factor columns
        unnorm_adat[[col]] <- 1.0
      }
    }

    # Ensure column order matches
    unnorm_adat <- unnorm_adat[, names(norm_adat)]
    norm_adat <- rbind(norm_adat, unnorm_adat)
  }

  # Restore original order
  norm_adat <- norm_adat[order(norm_adat$.rowid), ]
  norm_adat$.rowid <- NULL

  # Add medNorm reference to SeqId annotations ----
  norm_adat <- .addMedNormReference(norm_adat, ref_data, dil_groups)

  # Recalculate RowCheck to adjust for new MedNorm values ----
  norm_adat <- .recalculateRowCheck(norm_adat, verbose)

  # Update header metadata
  .updateHeaderMetadata(norm_adat, reference)
}


#' Process Reference Data
#' @noRd
.processReference <- function(reference, adat, dil_groups, apt_data, verbose) {

  if (is.soma_adat(reference)) {
    # Use reference from provided ADAT
    if (verbose) {
      .todo("Using reference from provided ADAT object")
    }
    return(.extractReferenceFromAdat(reference, dil_groups))

  } else if (is.data.frame(reference)) {
    # Reference data provided directly
    if (verbose) {
      .todo("Using provided reference data.frame")
    }
    return(.validateReferenceData(reference, dil_groups, apt_data))

  } else {
    stop(
      "Invalid reference type. Must be NULL, soma_adat, or data.frame",
      call. = FALSE
    )
  }
}

#' Build Internal Reference from Study Samples
#' @noRd
.buildInternalReference <- function(adat, dil_groups) {

  if (!"SampleType" %in% names(adat)) {
    stop("Reference field 'SampleType' not found", call. = FALSE)
  }

  # Select reference samples
  ref_samples <- adat[["SampleType"]] %in% "Sample"
  if (sum(ref_samples) == 0) {
    stop(
      "No reference samples found with field 'SampleType' and value: Sample",
      call. = FALSE
    )
  }

  ref_adat <- adat[ref_samples, ]

  # Calculate reference medians for each dilution group
  ref_data <- list()
  for (dil_name in names(dil_groups)) {
    dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(adat))
    if (length(dil_apts) > 0) {
      ref_data[[dil_name]] <- apply(ref_adat[, dil_apts, drop = FALSE], 2, median, na.rm = TRUE)
    }
  }

  ref_data
}

#' Extract Reference from ADAT
#' @noRd
.extractReferenceFromAdat <- function(ref_adat, dil_groups) {

  # Calculate reference medians for each dilution group
  ref_data <- list()
  for (dil_name in names(dil_groups)) {
    dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(ref_adat))
    if (length(dil_apts) > 0) {
      ref_data[[dil_name]] <- apply(ref_adat[, dil_apts, drop = FALSE], 2, median, na.rm = TRUE)
    }
  }

  ref_data
}



#' Validate Reference Data
#' @noRd
.validateReferenceData <- function(ref_df, dil_groups, apt_data = NULL) {

  # Check for required SeqId and Reference columns
  required_cols <- c("SeqId", "Reference")
  if (!all(required_cols %in% names(ref_df))) {
    missing_cols <- setdiff(required_cols, names(ref_df))
    stop(
      "Reference data must contain 'SeqId' and 'Reference' columns.\n",
      "Missing columns: ", paste(missing_cols, collapse = ", "), "\n",
      "Found columns: ", paste(names(ref_df), collapse = ", "),
      call. = FALSE
    )
  }

  # Process as SeqId-specific reference
  return(.processSeqIdReference(ref_df, dil_groups, apt_data))
}

#' Process SeqId-Specific Reference Data
#' @noRd
.processSeqIdReference <- function(ref_df, dil_groups, apt_data) {

  if (!is.null(apt_data) && !"SeqId" %in% names(apt_data)) {
    stop("ADAT analyte data must contain SeqId column for SeqId reference matching", call. = FALSE)
  }

  # Create a global reference mapping from all dilutions
  # Expect SeqId column in reference data
  if (!"SeqId" %in% names(ref_df)) {
    stop("Reference data must contain SeqId column for SeqId reference matching", call. = FALSE)
  }
  global_seqid_refs <- setNames(ref_df$Reference, ref_df$SeqId)

  ref_data <- list()

  # Process each dilution group using the global reference
  for (dil_name in names(dil_groups)) {
    dil_apt_names <- dil_groups[[dil_name]]

    # Convert AptNames to SeqIds and find matches in global reference
    dil_seq_ids <- apt_data$SeqId[apt_data$AptName %in% dil_apt_names]
    matching_seq_ids <- intersect(dil_seq_ids, names(global_seqid_refs))

    if (length(matching_seq_ids) > 0) {
      # Convert back to AptNames for the final result
      matching_apt_names <- apt_data$AptName[apt_data$SeqId %in% matching_seq_ids]
      ref_values <- global_seqid_refs[matching_seq_ids]
      names(ref_values) <- matching_apt_names
      ref_data[[dil_name]] <- ref_values
    }
  }

  # Check that we have some references
  if (length(ref_data) == 0) {
    stop("No matching SeqIds or dilution groups found in reference data", call. = FALSE)
  }

  ref_data
}



#' Perform Median Normalization
#' @noRd
.performMedianNorm <- function(adat, dil_groups, by, ref_data, verbose) {

  # Store original rownames to restore later
  original_rownames <- rownames(adat)

  # Validate grouping variables
  if (is.character(by) && length(by) > 0) {
    missing_cols <- setdiff(by, names(adat))
    if (length(missing_cols) > 0) {
      stop("Grouping column(s) not found: ", paste(missing_cols, collapse = ", "),
           call. = FALSE)
    }
  }

  # Create grouping variable
  if (length(by) == 1L) {
    group_var <- adat[[by]]
  } else if (length(by) > 1L) {
    group_var <- apply(adat[, by, drop = FALSE], 1, paste, collapse = "__")
  } else {
    group_var <- rep("all", nrow(adat))
  }

  # Report grouping strategy if verbose
  if (verbose) {
    if (length(by) > 1L) {
      .todo("Performing grouped median normalization by: {.val {paste(by, collapse = ', ')}}")
    } else if (length(by) == 1L && by != "SampleType") {
      .todo("Performing grouped median normalization by: {.val {by}}")
    } else if (length(unique(group_var)) > 1) {
      .todo("Performing grouped median normalization by: {.val {by}} ({.val {length(unique(group_var))}} groups)")
    }
  }

  adat$.group <- group_var

  # Split data by groups and process each group separately
  groups <- unique(group_var)
  result_list <- list()

  for (grp in groups) {
    grp_samples <- which(group_var == grp)
    grp_adat <- adat[grp_samples, , drop = FALSE]

    if (verbose && length(groups) > 1) {
      .todo("Processing group: {.val {grp}} ({.val {length(grp_samples)}} samples)")
    }

    # Calculate scale factors for each dilution group within this sample group
    for (dil_name in names(dil_groups)) {
      sf_col <- paste0("NormScale_", dil_name)

      # Initialize scale factor column
      if (!sf_col %in% names(grp_adat)) {
        grp_adat[[sf_col]] <- 1.0
      }

      # Get analytes in this dilution
      dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(grp_adat))

      if (length(dil_apts) == 0) {
        next
      }

      if (verbose) {
        .done("Processing dilution '{dil_name}' with {length(dil_apts)} analytes")
      }

      # Calculate reference values for this dilution
      if (!is.null(ref_data) && dil_name %in% names(ref_data)) {
        # Use external reference
        ref_values <- ref_data[[dil_name]]

        if (is.numeric(ref_values) && length(ref_values) == 1) {
          # Single reference value for the whole dilution group
          grp_ref_values <- rep(ref_values, length(dil_apts))
          names(grp_ref_values) <- dil_apts
        } else if (is.numeric(ref_values) && length(ref_values) > 1) {
          # Aptamer-specific reference values
          grp_ref_values <- ref_values[dil_apts]
          has_ref <- !is.na(grp_ref_values)

          if (any(has_ref)) {
            dil_apts <- dil_apts[has_ref]
            grp_ref_values <- grp_ref_values[has_ref]
          } else {
            next  # No references available, skip this dilution group
          }
        } else {
          # Fallback to group-specific calculation
          grp_ref_values <- apply(grp_adat[, dil_apts, drop = FALSE], 2, median, na.rm = TRUE)
        }
      } else {
        # Internal reference: Use Sample types from this group only
        if (!"SampleType" %in% names(grp_adat)) {
          stop("Reference field 'SampleType' not found", call. = FALSE)
        }

        ref_samples_mask <- grp_adat[["SampleType"]] %in% "Sample"
        if (sum(ref_samples_mask) == 0) {
          stop(
            "No reference samples found with field 'SampleType' and value: Sample",
            call. = FALSE
          )
        }

        ref_sample_data <- grp_adat[ref_samples_mask, dil_apts, drop = FALSE]
        grp_ref_values <- apply(ref_sample_data, 2, median, na.rm = TRUE)
      }

      # Calculate scale factors for each sample in this group
      for (i in seq_len(nrow(grp_adat))) {
        sample_values <- as.numeric(grp_adat[i, dil_apts, drop = FALSE])
        ratios <- grp_ref_values / sample_values
        med_scale_factor <- median(ratios[is.finite(ratios)], na.rm = TRUE)

        if (!is.finite(med_scale_factor)) {
          med_scale_factor <- 1.0
        }

        grp_adat[[sf_col]][i] <- med_scale_factor
      }

      # Apply scale factors to analytes
      for (apt in dil_apts) {
        grp_adat[[apt]] <- grp_adat[[apt]] * grp_adat[[sf_col]]
      }
    }

    result_list[[as.character(grp)]] <- grp_adat
  }

  # Combine results and restore original order
  adat <- do.call(rbind, result_list)
  adat <- adat[order(adat$.rowid), ]

  # Restore original rownames
  rownames(adat) <- original_rownames

  # Remove temporary grouping column
  adat$.group <- NULL

  # Round to 1 decimal place (standard for SomaScan data)
  apts <- getAnalytes(adat)
  for (apt in apts) {
    adat[[apt]] <- round(adat[[apt]], 1)
  }

  adat
}

#' Update Header Metadata
#' @noRd
.updateHeaderMetadata <- function(adat, reference) {
  header_meta <- attr(adat, "Header.Meta")

  if (!is.null(header_meta) && !is.null(header_meta$HEADER)) {
    # Add median normalization to process steps
    if ("ProcessSteps" %in% names(header_meta$HEADER)) {
      if (!grepl("MedNormSMP", header_meta$HEADER$ProcessSteps)) {
        header_meta$HEADER$ProcessSteps <- paste(
          header_meta$HEADER$ProcessSteps,
          "MedNormSMP",
          sep = ", "
        )
      }
    } else {
      header_meta$HEADER$ProcessSteps <- "MedNormSMP"
    }

    # Set normalization algorithm
    header_meta$HEADER$NormalizationAlgorithm <- "MedNorm"

    # Set reference type - add "crossplate" as new comma-separated entry
    if (is.null(reference)) {
      # For internal references, use crossplate
      current_ref <- header_meta$HEADER$MedNormReference %||% ""
      if (current_ref == "") {
        header_meta$HEADER$MedNormReference <- "intraplate, crossplate"
      } else if (!grepl("crossplate", current_ref)) {
        header_meta$HEADER$MedNormReference <- paste(current_ref, "crossplate", sep = ", ")
      }
    } else if (is.soma_adat(reference)) {
      header_meta$HEADER$MedNormReference <- "external_adat, crossplate"
    } else if (is.character(reference)) {
      header_meta$HEADER$MedNormReference <- paste(basename(reference), "crossplate", sep = ", ")
    } else {
      header_meta$HEADER$MedNormReference <- "external_data, crossplate"
    }

    attr(adat, "Header.Meta") <- header_meta
  }

  adat
}


#' Validate Data State for Median Normalization
#' @noRd
.validateDataState <- function(adat, header, verbose, reverse_existing = FALSE) {

  # Check if data is in a standard deliverable state
  process_steps <- header$ProcessSteps %||% ""

  # Check for existing median normalization
  has_mednorm <- grepl("medNormInt|MedNorm", process_steps, ignore.case = TRUE)
  has_anml <- grepl("ANML", process_steps, ignore.case = TRUE)

  if (has_mednorm && !reverse_existing) {
    stop(
      "Data appears to already be median normalized. ",
      "Set reverse_existing = TRUE to reverse existing median normalization before applying new normalization. ",
      "ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }

  if (has_anml && !reverse_existing) {
    stop(
      "Data appears to be ANML normalized. ",
      "Set reverse_existing = TRUE to reverse existing ANML normalization before applying new normalization. ",
      "ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }

  # Check for required normalization steps
  has_hyb <- grepl("Hyb|hybridization", process_steps, ignore.case = TRUE)
  has_plate_scale <- grepl("PlateScale|plate.?scale", process_steps, ignore.case = TRUE)

  # Warn if not in standard deliverable state
  if (!has_hyb || !has_plate_scale) {
    warning(
      "Data may not be in standard deliverable format. ",
      "Standard format requires hybridization normalization, median normalization of controls ",
      "(buffer + calibrator), and plate scale normalization before applying median normalization. ",
      "Current ProcessSteps: ", process_steps,
      call. = FALSE
    )
  }

  if (verbose) {
    cat("Data validation passed for median normalization.\n")
    cat("Standard deliverable checks:\n")
    cat("  - Hybridization normalization:", if(has_hyb) "PASS" else "WARN", "\n")
    cat("  - Plate scale normalization:", if(has_plate_scale) "PASS" else "WARN", "\n")
    cat("  - No existing MedNorm/ANML:", if(!has_mednorm && !has_anml) "PASS" else if(reverse_existing && has_mednorm) "WARN (will reverse)" else "FAIL", "\n")
  }

  return(has_mednorm || has_anml)
}


#' Validate Dilution Count
#' @noRd
.validateDilutionCount <- function(dil_groups, verbose) {

  num_dilutions <- length(dil_groups)

  # Primary use cases are 1 or 3 dilutions
  if (!num_dilutions %in% c(1, 3)) {
    warning(
      "Non-standard dilution count detected: ", num_dilutions, " dilutions. ",
      "Primary use cases are 1 dilution (cell & tissue studies) or 3 dilutions (standard setups). ",
      "Found dilutions: ", paste(names(dil_groups), collapse = ", "),
      call. = FALSE
    )
  }

  if (verbose) {
    if (num_dilutions == 1) {
      cat("Single dilution setup detected (typical for cell & tissue studies).\n")
    } else if (num_dilutions == 3) {
      cat("Three dilution setup detected (standard setup).\n")
    } else {
      cat("Non-standard dilution setup detected (", num_dilutions, " dilutions).\n")
    }
  }

  invisible(NULL)
}


#' Add MedNorm Reference to SeqId Annotations
#' @noRd
.addMedNormReference <- function(adat, ref_data, dil_groups) {

  # Get analyte info
  apt_data <- getAnalyteInfo(adat)

  # Initialize the column if it doesn't exist
  if (!"medNormSMP_ReferenceRFU" %in% names(apt_data)) {
    apt_data$medNormSMP_ReferenceRFU <- NA_real_
  }

  # For each analyte, add medNormSMP_ReferenceRFU
  if (!is.null(ref_data)) {
    for (dil_name in names(dil_groups)) {
      if (dil_name %in% names(ref_data)) {
        dil_apts <- intersect(dil_groups[[dil_name]], getAnalytes(adat))

        if (length(dil_apts) > 0) {
          ref_values <- ref_data[[dil_name]]

          # Handle both single reference and aptamer-specific references
          if (is.numeric(ref_values) && length(ref_values) == 1) {
            # Single reference value for the whole dilution group (round to 2 decimal places)
            rounded_value <- round(ref_values, 2)
            apt_data$medNormSMP_ReferenceRFU[apt_data$AptName %in% dil_apts] <- rounded_value
          } else if (is.numeric(ref_values) && length(ref_values) > 1) {
            # Aptamer-specific reference values (round to 2 decimal places)
            for (apt in dil_apts) {
              if (apt %in% names(ref_values)) {
                rounded_value <- round(ref_values[apt], 2)
                apt_data$medNormSMP_ReferenceRFU[apt_data$AptName == apt] <- rounded_value
              }
            }
          }
        }
      }
    }

    # Update the analyte metadata
    attr(adat, "Col.Meta") <- apt_data
  }

  invisible(adat)
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
  sample_mask <- grepl("Sample|sample", adat$SampleType %||% adat$SampleId %||% "", ignore.case = TRUE)

  if (sum(sample_mask) == 0) {
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

    # Add reversal step - look for what type of median norm was reversed
    if (grepl("MedNormSMP", current_steps, ignore.case = TRUE)) {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-MedNormSMP", sep = ", ")
    } else if (grepl("medNormInt", current_steps, ignore.case = TRUE)) {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-medNormInt", sep = ", ")
    } else {
      header_meta$HEADER$ProcessSteps <- paste(current_steps, "rev-MedNorm", sep = ", ")
    }

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
  sample_mask <- grepl("Sample|sample", adat$SampleType %||% adat$SampleId %||% "", ignore.case = TRUE)

  if (sum(sample_mask) == 0) {
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
            log_data <- log10(as.numeric(adat[i, dil_apts]))
            reversed_log_data <- log_data - log_sf
            adat[i, dil_apts] <- 10^reversed_log_data
            # Reset scale factor to 1.0
            adat[[sf_col]][i] <- 1.0
          }
        }
      }
    }
  }

  # Remove ANMLFractionUsed columns if they exist
  anml_frac_cols <- grep("^ANMLFractionUsed_", names(adat), value = TRUE)
  if (length(anml_frac_cols) > 0) {
    for (col in anml_frac_cols) {
      if (all(is.na(adat[[col]][sample_mask]))) {
        adat[[col]][sample_mask] <- NA
      }
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


#' Recalculate RowCheck after Median Normalization
#'
#' Recalculates RowCheck values as PASS or FLAG based on normalization acceptance
#' criteria for row scale factors after median normalization. Samples with all
#' row scale factors within the acceptance range (0.4 to 2.5) receive "PASS",
#' while samples with any scale factor outside this range receive "FLAG".
#'
#' @param adat A `soma_adat` object after median normalization
#' @param verbose Logical. Whether to print progress messages
#' @return The `soma_adat` object with updated RowCheck values
#' @noRd
.recalculateRowCheck <- function(adat, verbose) {

  if (verbose) {
    cat("Recalculating RowCheck values based on normalization acceptance criteria...\n")
  }

  # Check if RowCheck column exists
  if (!"RowCheck" %in% names(adat)) {
    if (verbose) {
      cat("No RowCheck column found to recalculate.\n")
    }
    return(adat)
  }

  # Find all normalization scale factor columns (NormScale_*)
  scale_factor_cols <- grep("^NormScale_", names(adat), value = TRUE)

  if (length(scale_factor_cols) == 0) {
    if (verbose) {
      cat("No normalization scale factor columns found. Setting all RowCheck to PASS.\n")
    }
    adat$RowCheck <- "PASS"
    return(adat)
  }

  # Define acceptance criteria range for row scale factors
  min_scale <- 0.4
  max_scale <- 2.5

  # Calculate RowCheck for each sample
  for (i in seq_len(nrow(adat))) {
    # Get all scale factor values for this sample
    scale_values <- as.numeric(adat[i, scale_factor_cols, drop = FALSE])
    scale_values <- scale_values[!is.na(scale_values)]

    # Check if all scale factors are within acceptance range
    if (length(scale_values) == 0) {
      # No scale factors available - default to PASS
      adat$RowCheck[i] <- "PASS"
    } else if (all(scale_values >= min_scale & scale_values <= max_scale)) {
      adat$RowCheck[i] <- "PASS"
    } else {
      adat$RowCheck[i] <- "FLAG"
    }
  }

  if (verbose) {
    pass_count <- sum(adat$RowCheck == "PASS", na.rm = TRUE)
    flag_count <- sum(adat$RowCheck == "FLAG", na.rm = TRUE)
    cat("RowCheck values updated for", nrow(adat), "samples.\n")
    cat("  - PASS:", pass_count, "samples\n")
    cat("  - FLAG:", flag_count, "samples\n")
    cat("  - Acceptance criteria: scale factors within [", min_scale, ", ", max_scale, "]\n")
  }

  adat
}
