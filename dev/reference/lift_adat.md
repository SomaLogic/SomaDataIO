# Lift an ADAT Between Assay Versions

The SomaScan platform continually improves its technical processes
between assay versions. The primary change of interest is content
expansion, and other protocol changes may be implemented including:
changing reagents, liquid handling equipment, and well volumes.

Table of SomaScan assay versions:

|             |                     |          |
|-------------|---------------------|----------|
| **Version** | **Commercial Name** | **Size** |
| `V4`        | 5k                  | 5284     |
| `v4.1`      | 7k                  | 7596     |
| `v5.0`      | 11k                 | 11083    |

However, for a given analyte, these technical upgrades can result in
minute measurement signal differences, requiring a calibration (aka
"lifting" or "bridging") to bring RFUs into a comparable signal space.
This is accomplished by applying an analyte-specific scalar, a linear
transformation, to each analyte RFU measurement (column). If you have an
annotations file (`*.xlsx`) and wish to examine the bridging scalars
themselves, please see
[`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md).

Lifting between SomaScan versions no longer requires an annotations file
containing lifting scalars. We now enable users to pass a `bridge`
parameter, indicating the direction of the bridge. For example, to
"lift" between `11k` -\> `7k`, you *must* be acting on SomaScan data in
`11k` RFU space and would pass `bridge = "11k_to_7k"`. Likewise, `7k`
-\> `5k` requires `bridge = "7k_to_5k"`. Lastly, you may also lift
directly from `11k` -\> `5k` (aka "double-bridge") with
`bridge = "11k_to_5k"`. See below for all options for the `bridge`
argument.

## Usage

``` r
lift_adat(
  adat,
  bridge = c("11k_to_7k", "11k_to_5k", "7k_to_11k", "7k_to_5k", "5k_to_11k", "5k_to_7k"),
  anno.tbl = deprecated()
)

is_lifted(adat)
```

## Arguments

- adat:

  A `soma_adat` object (with intact attributes), typically created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- bridge:

  The direction of the lift (i.e. bridge).

- anno.tbl:

  **\[deprecated\]**. Please now use the `bridge` argument.

## Value

`lift_adat()`: A "lifted" `soma_adat` object corresponding to the
scaling requested in the `bridge` parameter. RFU values are rounded to 1
decimal place to match standard SomaScan delivery format.

`is_lifted()`: Logical. Whether the RFU values in a `soma_adat` have
been lifted from its original signal space to a new signal space.

## Details

Matched samples across assay versions are used to calculate bridging
scalars. For each analyte, this scalar is computed as the ratio of
population *medians* across assay versions. Please see the lifting
vignette `vignette("lifting-and-bridging", package = "SomaDataIO")` for
more details.

## Lin's CCC

The Lin's Concordance Correlation Coefficient (CCC) is calculated by
computing the correlation between post-lift RFU values and the RFU
values generated on the original SomaScan version. This CCC estimate is
a measure of how well an analyte can be bridged across SomaScan
versions. See
`vignette("lifting-and-bridging", package = "SomaDataIO")`. As with the
lifting scalars, if you have an annotations file you may view the
analyte-specific CCC values via
[`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md).
Alternatively,
[`getSomaScanLiftCCC()`](https://somalogic.github.io/SomaDataIO/dev/reference/adat-helpers.md)
retrieves these values from an internal object for both `"serum"` and
`"plasma"`.

## Analyte Setdiff

- Newer versions of SomaScan typically have additional content, i.e. new
  reagents added to the multi-plex assay that bind to additional
  proteins. When lifting *to* a previous SomaScan version, new reagents
  that do *not* exist in the "earlier" assay version assay are scaled by
  1.0, and thus maintained, unmodified in the returned object. Users may
  need to drop these columns in order to combine these data with a
  previous study from an earlier SomaScan version, e.g. with
  [`collapseAdats()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md).

- In the inverse scenario, lifting "forward" *from* a previous,
  lower-plex version, there will be extra reference values that are
  unnecessary to perform the lift, and a warning is triggered. The
  resulting data consists of RFU data in the "new" signal space, but
  with fewer analytes than would otherwise be expected (e.g. `11k` space
  with only 5284 analytes; see example below).

## References

Lin, Lawrence I-Kuei. 1989. A Concordance Correlation Coefficient to
Evaluate Reproducibility. **Biometrics**. 45:255-268.

## Examples

``` r
# `example_data` is SomaScan (V4, 5k)
adat <- head(example_data, 3L)
dim(adat)
#> [1]    3 5318

getSomaScanVersion(adat)
#> [1] "V4"

getSignalSpace(adat)
#> [1] "V4"

# perform 'lift'
lift_11k <- lift_adat(adat, "5k_to_11k")  # warning
#> Warning: There are extra scaling values (5799) in the reference.
#> They will be ignored.

is_lifted(lift_11k)
#> [1] TRUE

dim(lift_11k)
#> [1]    3 5318

# attributes updated to reflect the 'lift'
attr(lift_11k, "Header")$HEADER$SignalSpace
#> [1] "v5.0"

attr(lift_11k, "Header")$HEADER$ProcessSteps
#> [1] "Raw RFU, Hyb Normalization, medNormInt (SampleId), plateScale, Calibration, anmlQC, qcCheck, anmlSMP, Lifting Bridge (5k -> 11k)"
```
