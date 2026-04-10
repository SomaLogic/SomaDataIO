# Perform Median Normalization on Study Samples

Performs median normalization on a `soma_adat` object that has already
undergone standard data processing for array-based SomaScan studies.

Median normalization is a common, scale-based normalization technique
that corrects for assay-derived technical variation by applying
sample-specific linear scaling to expression measurements. Typical
sources of assay variation include robotic and manual liquid handling,
manufactured consumables such as buffers and plastic goods, laboratory
instrument calibration, ambient environmental conditions, inter-operator
differences, and other sources of technical variation. Median
normalization can improve assay precision and reduce technical variation
that can mask true biological signal.

The method scales each sample so that the center of the within-sample
analyte distribution aligns to a defined reference, thereby correcting
global intensity shifts without altering relative differences between
measurements within a sample. For assay formats with multiple dilution
groups (e.g., 1:5 or 20%; 1:200 or 0.5%; 1:20,000 or 0.005%), separate
scale factors are calculated for each dilution because each dilution
group is processed separately during the assay. For each sample, the
ratio of reference RFU / observed RFU is calculated for every SeqId. The
median ratio within each dilution group is selected as the scale factor
and applied to all SeqIds for that sample within the associated dilution
bin.

## Usage

``` r
medianNormalize(adat, reference = NULL, by = NULL, verbose = TRUE)
```

## Arguments

- adat:

  A `soma_adat` object created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
  containing RFU values that have been hybridization normalized and
  plate scaled.

- reference:

  Optional. Reference for median normalization. Can be:

  - `NULL` (default): Calculate an internal reference from study samples
    by taking the median of each SeqId within the sample grouping.

  - A `soma_adat` object: Extract reference from this ADAT

  - A data.frame: Use provided reference data directly

  When providing an external reference data.frame it must contain:

  SeqId

  :   Character column containing the SeqId identifiers mapping to those
      in the `soma_adat` object. Must be in "10000-28" format, not
      "seq.10000.28" format.

  Reference

  :   Numeric column containing the reference RFU values for each SeqId.

- by:

  Character vector. Grouping variable(s) for grouped median
  normalization. Must be column name(s) in the ADAT. Normalization will
  be performed within each group separately. Default is `NULL` (all
  samples normalized together). Note that only study samples (SampleType
  == 'Sample') are normalized; QC, Calibrator, and Buffer samples are
  automatically excluded.

- verbose:

  Logical. Should progress messages be printed? Default is `TRUE`.

## Value

A `soma_adat` object with median normalization applied and RFU values
adjusted. The existing `NormScale_*` columns are updated to include the
effects of both plate scale normalization and median normalization.

## Data Requirements

This function is designed for data in standard SomaLogic deliverable
formats. Specific ADAT file requirements:

1.  **Intact ADAT file**, with available data processing information in
    the header section. Specifically, the `ProcessSteps` field must be
    present and correctly represent the data processing steps present in
    the data table.

2.  **Minimal standard processing**, the function assumes a standard
    SomaScan data deliverable with minimally standard HybNorm and
    PlateScale steps applied.

**Primary use cases:**

- Combining data sets from the same overarching experiment or sample
  population and normalize to a common reference that were originally
  processed separately and each normalized "within study".

- Normalize fundamentally different types of samples separately (by
  group). For instance, lysate samples from different cell lines that
  will be analyzed separately should likely be median normalized within
  each cell type. Lysis buffer background samples would also be expected
  to be normalized separately.

## Important Considerations

- A core assumption of median normalization is that the majority of
  analytes are not differentially expressed; consequently, users should
  validate this assumption by inspecting scale-factor distributions for
  systematic bias between the biological groups intended for comparison.

- Note this function does not perform the adaptive normalization by
  maximum likelihood (ANML) method which leverages a population-based
  reference that iteratively down-selects the set of analytes to include
  for the normalization calculation.

- This function requires unnormalized data as input. If study samples
  have already undergone median normalization (ANML or standard), first
  use
  [`reverseMedianNormalize()`](https://somalogic.github.io/SomaDataIO/dev/reference/reverseMedianNormalize.md)
  to remove existing normalization.

## Examples

``` r
if (FALSE) { # \dontrun{
# Starting with unnormalized ADAT
unnormalized_adat <- read_adat("unnormalized_study_data.adat")

# Internal reference from study samples (default - all samples normalized together)
med_norm_adat <- medianNormalize(unnormalized_adat)

# Reference from another ADAT
ref_adat <- read_adat("reference_file.adat")
med_norm_adat <- medianNormalize(unnormalized_adat, reference = ref_adat)

# External reference as a data.frame - requires `SeqId` and `Reference` columns
ref_data <- read.csv("reference_file.csv")
med_norm_adat <- medianNormalize(unnormalized_adat, reference = ref_data)

# Custom grouping by biological variables
# Use when samples should be normalized separately by group
med_norm_adat <- medianNormalize(unnormalized_adat, by = "Sex")
med_norm_adat <- medianNormalize(unnormalized_adat, by = c("Sex", "Age_Group"))

# If you already have normalized data, first reverse the normalization
normalized_adat <- read_adat("normalized_study_data.adat")
unnormalized_adat <- reverseMedianNormalize(normalized_adat)
custom_norm_adat <- medianNormalize(unnormalized_adat, reference = new_reference)
} # }
```
