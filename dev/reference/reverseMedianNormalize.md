# Reverse Median Normalization from Study Samples

Reverses median normalization (including ANML) that was previously
applied to study samples (`SampleType == "Sample"`). This function is
designed to work with standard SomaScan deliverable ADAT files where
study samples have undergone median normalization as the final
processing step.

This function validates that:

1.  Study samples have a median normalization step applied

2.  The normalization was the last transformation applied to study
    samples

3.  The correct reversal method is applied based on the normalization
    type

## Usage

``` r
reverseMedianNormalize(adat, verbose = TRUE)
```

## Arguments

- adat:

  A `soma_adat` object with study samples that have been median
  normalized

- verbose:

  Logical. Should progress messages be printed? Default is `TRUE`.

## Value

A `soma_adat` object with median normalization reversed for study
samples. QC, Calibrator, and Buffer samples retain their original
normalization. The `ProcessSteps` header is updated to reflect the
reversal operation, and median normalization-specific metadata fields
are cleared.

## Use Cases

- Converting from normalized ADAT to unnormalized ADAT for custom
  normalization

- Preparing normalized delivery data for use with
  [`medianNormalize()`](https://somalogic.github.io/SomaDataIO/dev/reference/medianNormalize.md)
  function

- Backing out normalization to apply different normalization strategies

## Data Requirements

- ADAT file with study samples (`SampleType == "Sample"`) that have been
  median normalized (either standard median normalization or ANML)

- Intact header metadata with `ProcessSteps` field indicating the
  normalization history

- Median normalization must be the last processing step applied to study
  samples

## Examples

``` r
if (FALSE) { # \dontrun{
# Reverse normalization from a delivered ADAT file
normalized_adat <- read_adat("normalized_study_data.adat")
unnormalized_adat <- reverseMedianNormalize(normalized_adat)
} # }
```
