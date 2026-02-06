# Calculate Estimated Limit of Detection (eLOD)

Calculate the estimated limit of detection (eLOD) for SOMAmer reagent
analytes in the provided input data. The input data should be filtered
to include only buffer samples desired for eLOD calculation.

## Usage

``` r
calc_eLOD(data)
```

## Arguments

- data:

  A `soma_adat`, `data.frame`, or `tibble` object including SeqId
  columns (`seq.xxxxx.xx`) containing RFU values.

## Value

A `tibble` object with 2 columns: SeqId and eLOD.

## Details

eLOD is calculated using the following steps:

1.  For each SOMAmer, the median and adjusted median absolute deviation
    (\\MAD\_{Adjusted}\\) are calculated, where \$\$MAD\_{Adjusted} =
    1.4826 \* MAD\$\$ The 1.4826 is a set constant used to adjust the
    MAD to be reflective of the standard deviation of the normal
    distribution.

2.  For each SOMAmer, calculate \$\$eLOD = median + 3.3 \*
    MAD\_{Adjusted}\$\$

Note: The eLOD is useful for non-core matrices, including cell lysate
and CSF, but should be used carefully for evaluating background signal
in plasma and serum.

## Author

Caleb Scheidel, Christopher Dimapasok

## Examples

``` r
# filter data frame using vector of SampleId controls
df <- withr::with_seed(101, {
  data.frame(
    SampleType = rep(c("Sample", "Buffer"), each = 10),
    SampleId = paste0("Sample_", 1:20),
    seq.20.1.100 = runif(20, 1, 100),
    seq.21.1.100 = runif(20, 1, 100),
    seq.22.2.100 = runif(20, 1, 100)
  )
})
sample_ids <- paste0("Sample_", 11:20)
selected_samples <- df |> filter(SampleId %in% sample_ids)

selected_elod <- calc_eLOD(selected_samples)
head(selected_elod)
#> # A tibble: 3 × 2
#>   SeqId         eLOD
#>   <chr>        <dbl>
#> 1 seq.20.1.100  168.
#> 2 seq.21.1.100  131.
#> 3 seq.22.2.100  116.
if (FALSE) { # \dontrun{
# filter `soma_adat` object to buffer samples
buffer_samples <- example_data |> filter(SampleType == "Buffer")

# calculate eLOD
buffer_elod <- calc_eLOD(buffer_samples)
head(buffer_elod)

# use eLOD to calculate signal to noise ratio of samples
samples_median <- example_data |> dplyr::filter(SampleType == "Sample") |>
  dplyr::summarise(across(starts_with("seq"), median, .names = "median_{col}")) |>
  tidyr::pivot_longer(starts_with("median_"), names_to = "SeqId",
                      values_to = "median_signal") |>
  dplyr::mutate(SeqId = gsub("median_seq", "seq", SeqId))

# analytes with signal to noise > 2
ratios <- samples_median |>
  dplyr::mutate(signal_to_noise = median_signal / buffer_elod$eLOD) |>
  dplyr::filter(signal_to_noise > 2) |>
  dplyr::arrange(desc(signal_to_noise))

head(ratios)
} # }
```
