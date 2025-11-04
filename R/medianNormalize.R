#' Perform Median Normalization
#'
#' @description Performs median normalization on a `soma_adat` object that has
#' already undergone hybridization normalization and contains plate scale
#' normalization factors.
#'
#' Median normalization is a technique used to adjust data sets to remove
#' certain assay artifacts and biases prior to analysis, particularly those that
#' may arise due to differences in overall protein concentration, pipetting
#' errors, reagent concentration changes, assay timing, and other systematic
#' variabilities. Median normalization can improve assay precision and reduce
#' technical variations that can mask true biological signals.
#'
#' This function works by calculating or using reference median values for each
#' dilution group present in the ADAT. Dilution groups are determined from the
#' analyte metadata and represent different sample dilutions used in the assay
#' (e.g., 1:1, 1:200, 1:2000). For each sample, the median RFU across all
#' analytes within a dilution group is calculated and compared to the reference
#' median for that group. Scale factors are then computed and applied to adjust
#' each sample's values toward the reference, ensuring consistent signal levels
#' across samples within each dilution group. This function supports multiple
#' reference approaches: calculating an internal reference from study samples,
#' or using a calculated reference from a different ADAT or external reference
#' file.
#'
#' @section Important Considerations:
#' \itemize{
#'   \item If there is a known change in total protein concentration due to analysis
#'     conditions, perform normalization _within_ groups using the `by` parameter
#'   \item In newer SomaScan assay versions, population references improve
#'     inter-plate consistency compared to within-plate references
#' }
#'
#' @param adat A `soma_adat` object created using [read_adat()], containing
#'   RFU values that have been hybridization normalized and plate scaled.
#' @param reference Optional. Reference for median normalization. Can be:
#'   \itemize{
#'     \item `NULL` (default): Use internal reference from study samples
#'     \item A `soma_adat` object: Extract reference from this ADAT
#'     \item A file path (character): Read external reference from tab/comma-separated file
#'     \item A data.frame: Use provided reference data directly
#'   }
#'   When providing an external reference file or data.frame it must contain:
#'   \describe{
#'     \item{Dilution}{Character column specifying the dilution group names
#'       (e.g., "0_005", "0_5", "20"). These should match the dilution
#'       groups present in the ADAT analyte data.}
#'     \item{Reference}{Numeric column containing the reference median values
#'       for each dilution group. These values will be used as the target
#'       medians for normalization.}
#'     \item{SeqId}{Optional character column. When included, SeqId-specific
#'       reference values are used for more precise normalization. Values
#'       must be in "10000-28" format, not "seq.10000.28" format.}
#'   }
#' @param ref_field Character. Field used to select reference samples when
#'   `reference = NULL`. Default is `"SampleType"`.
#' @param ref_value Character. Value(s) in `ref_field` to use as reference
#'   when `reference = NULL`. Default is `c("QC", "Sample")`.
#' @param by Character vector. Grouping variable(s) for grouped median normalization.
#'   Must be column name(s) in the ADAT. Use grouping when there are known changes
#'   in total protein load due to analysis conditions (e.g., disease vs. control,
#'   treatment vs. baseline). Normalization will be performed within each group
#'   separately. Default is `"SampleType"`.
#' @param do_field Character. The field used to select samples for normalization
#'   (others keep original values). Default is `"SampleType"`.
#' @param do_regexp Character. A regular expression pattern to select samples
#'   from `do_field` for normalization. Default is `"QC|Sample"`.
#' @param verbose Logical. Should progress messages be printed? Default is `TRUE`.
#' @return A `soma_adat` object with median normalization applied and RFU values
#'   adjusted. The existing `NormScale_*` columns are updated to include the
#'   effects of both plate scale normalization and median normalization.
#' @examples
#' \dontrun{
#' # Internal reference from study samples (default)
#' # Use when you have representative QC or control samples in your study
#' med_norm_adat <- medianNormalize(adat)
#'
#' # Reference from specific samples in the ADAT
#' # Use when you want to normalize against only QC samples
#' med_norm_adat <- medianNormalize(adat,
#'                                  ref_field = "SampleType",
#'                                  ref_value = "QC")
#'
#' # Reference from another ADAT
#' # Use when you have a reference population or control study
#' ref_adat <- read_adat("reference_file.adat")
#' med_norm_adat <- medianNormalize(adat, reference = ref_adat)
#'
#' # External reference file
#' # Use when you have pre-calculated reference medians for each dilution
#' med_norm_adat <- medianNormalize(adat, reference = "reference_file.csv")
#'
#' # External reference as data.frame
#' # Use for programmatic control over reference values
#' ref_data <- data.frame(
#'   Dilution = c("0_005", "0_5", "20"),
#'   Reference = c(1500.2, 3200.8, 4100.5)
#' )
#' med_norm_adat <- medianNormalize(adat, reference = ref_data)
#'
#' # Custom grouping by multiple variables
#' # Use when total protein load changes due to analysis conditions
#' # (normalize within groups to account for expected biological differences)
#' med_norm_adat <- medianNormalize(adat, by = c("Sex", "SampleType"))
#'
#' # Normalize only specific sample types
#' # Use when you want to preserve original values for certain sample types
#' med_norm_adat <- medianNormalize(adat,
#'                                  do_field = "SampleType",
#'                                  do_regexp = "Sample")
#' }
#' @importFrom dplyr filter
#' @importFrom stats median
#' @importFrom utils read.table read.csv
#' @export
medianNormalize <- function(adat,
                            reference = NULL,
                            ref_field = "SampleType",
                            ref_value = c("QC", "Sample"),
                            by = "SampleType",
                            do_field = "SampleType",
                            do_regexp = "QC|Sample",
                            verbose = TRUE) {

  # Input validation ----
  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

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

  if (length(dil_groups) < 2L) {
    warning("Fewer than 2 dilution groups detected", call. = FALSE)
  }

  # Check for existing normalization scale factors ----
  existing_norm_sf <- grep("^NormScale_", names(adat), value = TRUE)

  if ( verbose ) {
    if (length(existing_norm_sf) > 0) {
      .todo("Normalization scale factors already exist: {.val {paste0(existing_norm_sf, collapse = ', ')}} - they will be replaced with new scale factors")
    }
  }


  # Determine which samples to normalize ----
  if (!is.null(do_field) && !is.null(do_regexp)) {
    if (!do_field %in% names(adat)) {
      stop("Field `", do_field, "` not found in adat columns", call. = FALSE)
    }

    do_samples <- grep(do_regexp, adat[[do_field]])
    if (length(do_samples) == 0L) {
      stop(
        "No samples selected for normalization with pattern: ", do_regexp,
        call. = FALSE
      )
    }
    dont_samples <- setdiff(seq_len(nrow(adat)), do_samples)
  } else {
    do_samples <- seq_len(nrow(adat))
    dont_samples <- NULL
  }

  # Process reference ----
  if (is.null(reference)) {
    # Check if ref_field conflicts with grouping variables
    conflicts_with_grouping <- FALSE
    if (ref_field %in% by) {
      samples_to_normalize <- adat[do_samples, ]
      group_values <- unique(samples_to_normalize[[ref_field]])
      group_values <- group_values[!is.na(group_values)]
      all_groups_in_ref <- all(group_values %in% ref_value)
      conflicts_with_grouping <- !identical(by, ref_field) || !all_groups_in_ref
    }

    if (conflicts_with_grouping) {
      # Calculate global reference to avoid groups lacking reference samples
      if (verbose) {
        .todo("Building global internal reference from field: {.val {ref_field}} with values: {.val {ref_value}}")
      }
      ref_data <- .buildInternalReference(adat, ref_field, ref_value, dil_groups)
    } else {
      # Standard internal reference - calculate per group
      ref_data <- NULL
      if (verbose) {
        .todo("Building internal reference from field: {.val {ref_field}} with values: {.val {ref_value}}")
      }
    }
  } else {
    ref_data <- .processReference(reference, ref_field, ref_value, adat, dil_groups, apt_data, verbose)
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
      ref_field = ref_field,
      ref_value = ref_value,
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

  # Update header metadata
  .updateHeaderMetadata(norm_adat, reference)
}


#' Process Reference Data
#' @noRd
.processReference <- function(reference, ref_field, ref_value, adat, dil_groups, apt_data, verbose) {

  if (is.soma_adat(reference)) {
    # Use reference from provided ADAT
    if (verbose) {
      .todo("Using reference from provided ADAT object")
    }
    return(.extractReferenceFromAdat(reference, dil_groups))

  } else if (is.character(reference) && length(reference) == 1) {
    # External reference file
    if (verbose) {
      .todo("Reading external reference from file: {.val {reference}}")
    }
    return(.readExternalReference(reference, dil_groups, apt_data))

  } else if (is.data.frame(reference)) {
    # Reference data provided directly
    if (verbose) {
      .todo("Using provided reference data.frame")
    }
    return(.validateReferenceData(reference, dil_groups, apt_data))

  } else {
    stop(
      "Invalid reference type. Must be NULL, soma_adat, file path, or data.frame",
      call. = FALSE
    )
  }
}

#' Build Internal Reference from Study Samples
#' @noRd
.buildInternalReference <- function(adat, ref_field, ref_value, dil_groups) {

  if (!ref_field %in% names(adat)) {
    stop("Reference field `", ref_field, "` not found", call. = FALSE)
  }

  # Select reference samples
  ref_samples <- adat[[ref_field]] %in% ref_value
  if (sum(ref_samples) == 0) {
    stop(
      "No reference samples found with field `", ref_field,
      "` and values: ", paste(ref_value, collapse = ", "),
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

#' Read External Reference File
#' @noRd
.readExternalReference <- function(file_path, dil_groups, apt_data) {

  if (!file.exists(file_path)) {
    stop("Reference file not found: ", file_path, call. = FALSE)
  }

  # Determine file type and read
  file_ext_val <- file_ext(file_path)

  if (file_ext_val %in% c("csv")) {
    ref_df <- read.csv(file_path, stringsAsFactors = FALSE)
  } else if (file_ext_val %in% c("txt", "tsv")) {
    ref_df <- utils::read.table(file_path, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  } else {
    # Try to auto-detect
    ref_df <- tryCatch({
      read.csv(file_path, stringsAsFactors = FALSE)
    }, error = function(e) {
      utils::read.table(file_path, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    })
  }

  .validateReferenceData(ref_df, dil_groups, apt_data)
}

#' Validate Reference Data
#' @noRd
.validateReferenceData <- function(ref_df, dil_groups, apt_data = NULL) {

  # Check that required columns are present
  required_cols <- c("Dilution", "Reference")
  if (!all(required_cols %in% names(ref_df))) {
    missing_cols <- setdiff(required_cols, names(ref_df))
    stop(
      "Reference data must contain columns: ", paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  # Check if we have SeqId-specific information
  if ("SeqId" %in% names(ref_df)) {
    # Process as SeqId-specific reference
    return(.processSeqIdReference(ref_df, dil_groups, apt_data))
  } else {
    # Process as simple dilution-level reference
    return(.processSimpleReference(ref_df, dil_groups))
  }
}

#' Process SeqId-Specific Reference Data
#' @noRd
.processSeqIdReference <- function(ref_df, dil_groups, apt_data) {
  # Convert dilution values to character for consistent matching
  ref_df$Dilution <- as.character(ref_df$Dilution)

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

#' Process Simple Reference Data (Dilution -> Reference)
#' @noRd
.processSimpleReference <- function(ref_df, dil_groups) {
  # Convert to named list
  ref_data <- setNames(ref_df$Reference, ref_df$Dilution)

  # Check that we have references for all dilution groups
  missing_dils <- setdiff(names(dil_groups), names(ref_data))
  if (length(missing_dils) > 0) {
    stop(
      "Missing reference values for dilution groups: ", paste(missing_dils, collapse = ", "),
      call. = FALSE
    )
  }

  ref_data
}

#' Perform Median Normalization
#' @noRd
.performMedianNorm <- function(adat, dil_groups, by, ref_data, ref_field, ref_value, verbose) {

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
        # Internal reference: Use samples from this group only
        if (!ref_field %in% names(grp_adat)) {
          stop("Reference field `", ref_field, "` not found", call. = FALSE)
        }

        ref_samples_mask <- grp_adat[[ref_field]] %in% ref_value
        if (sum(ref_samples_mask) == 0) {
          stop(
            "No reference samples found with field `", ref_field,
            "` and values: ", paste(ref_value, collapse = ", "),
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
      if (!grepl("medNormInt", header_meta$HEADER$ProcessSteps)) {
        header_meta$HEADER$ProcessSteps <- paste(
          header_meta$HEADER$ProcessSteps,
          "medNormInt (SampleId)",
          sep = ", "
        )
      }
    } else {
      header_meta$HEADER$ProcessSteps <- "medNormInt (SampleId)"
    }

    # Set normalization algorithm
    header_meta$HEADER$NormalizationAlgorithm <- "MedNorm"

    # Set reference type
    if (is.null(reference)) {
      header_meta$HEADER$MedNormReference <- "intraplate"
    } else if (is.soma_adat(reference)) {
      header_meta$HEADER$MedNormReference <- "external_adat"
    } else if (is.character(reference)) {
      header_meta$HEADER$MedNormReference <- basename(reference)
    } else {
      header_meta$HEADER$MedNormReference <- "external_data"
    }

    attr(adat, "Header.Meta") <- header_meta
  }

  adat
}
