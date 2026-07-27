# Create R/sysdata.rda
#
# This script documents how the internal package data (R/sysdata.rda) is created.
# The sysdata.rda file contains objects used internally by the package that are
# not directly exported to users but are accessed by create_example_data() and
# related functions via lazy loading in .onLoad().
#
# Original source: https://github.com/SomaLogic/SomaLogic-Data/blob/main/example_data.adat
#
# Objects stored in sysdata.rda:
#   - original_example_data_full: Complete example SomaScan data (192 samples)
#   - lift_master: Bridging data for cross-platform normalization
#
# Note: Only re-run this script if you need to update the internal data from a
# new source file.

# Load required packages
library(SomaDataIO)
library(dplyr)

# Step 1: Load the original example_data.adat file
# ------------------------------------------------------------------------------
# The original file should be downloaded from the SomaLogic-Data repository:
# wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/main/example_data.adat

adat_file <- "example_data.adat"  # Adjust path as needed

if (!file.exists(adat_file)) {
  stop(
    "Please download example_data.adat first:\n",
    "wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/main/example_data.adat"
  )
}

cat("Reading ADAT file...\n")
original_example_data_full <- read_adat(adat_file)

# Verify dimensions
stopifnot(
  "Expected 192 samples" = nrow(original_example_data_full) == 192,
  "Expected 5318 columns" = ncol(original_example_data_full) == 5318,
  "Must be soma_adat class" = is.soma_adat(original_example_data_full)
)

cat("  Dimensions:", dim(original_example_data_full), "\n")
cat("  Sample breakdown:", table(original_example_data_full$SampleType), "\n")


# Step 2: Load lift_master data
# ------------------------------------------------------------------------------
# The lift_master object is used for cross-platform normalization
# This should already exist in the current sysdata.rda if this is an update

cat("\nLoading existing lift_master...\n")
if (file.exists("R/sysdata.rda")) {
  load("R/sysdata.rda")
  if (!exists("lift_master")) {
    stop("lift_master not found in existing sysdata.rda")
  }
  cat("  lift_master dimensions:", dim(lift_master), "\n")
} else {
  stop(
    "R/sysdata.rda not found. Cannot proceed without lift_master.\n",
    "If this is a fresh setup, the lift_master object must be provided separately."
  )
}


# Step 3: Create R/sysdata.rda
# ------------------------------------------------------------------------------
cat("\nCreating R/sysdata.rda...\n")

# Save all internal objects with xz compression (best compression ratio)
save(
  original_example_data_full,
  lift_master,
  file = "R/sysdata.rda",
  compress = "xz",
  compression_level = 9
)

# Report sizes
sysdata_info <- file.info("R/sysdata.rda")
cat("  File created:", sysdata_info$size / (1024^2), "MB\n")

cat("\nObject sizes (uncompressed):\n")
cat("  original_example_data_full:",
    format(object.size(original_example_data_full), units = "MB"), "\n")
cat("  lift_master:",
    format(object.size(lift_master), units = "KB"), "\n")


# Step 4: Verify the created file
# ------------------------------------------------------------------------------
cat("\nVerifying sysdata.rda...\n")

# Clear environment and reload
rm(original_example_data_full, lift_master)
load("R/sysdata.rda")

# Verify all objects exist
stopifnot(
  "original_example_data_full missing" = exists("original_example_data_full"),
  "lift_master missing" = exists("lift_master")
)
cat("  ✓ All required objects present\n")

# Verify data integrity
stopifnot(
  "Data dimensions incorrect" = identical(dim(original_example_data_full), c(192L, 5318L)),
  "Class incorrect" = is.soma_adat(original_example_data_full)
)
cat("  ✓ Data integrity verified\n")

cat("\n✓ sysdata.rda successfully created and verified!\n")
