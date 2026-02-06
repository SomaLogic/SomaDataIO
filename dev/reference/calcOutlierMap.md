# Calculate MAD Outlier Map

Calculate the median absolute deviation (statistical) outliers
measurements and fold-change criteria from an ADAT. Two values are
required for the calculation: median absolute deviation (MAD) and
fold-change (FC). Outliers are determined based on the result of *both*
`6*MAD` and `x*FC` , where `x` is the number of fold changes defined.

## Usage

``` r
calcOutlierMap(
  data,
  anno_tbl = NULL,
  apt.order = c(NA, "dilution", "signal"),
  sample.order = NULL,
  fc.crit = 5
)

# S3 method for class 'outlier_map'
print(x, ...)
```

## Arguments

- data:

  A `soma_adat` object containing RFU feature data.

- anno_tbl:

  An annotations table produced via
  [`getAnalyteInfo()`](https://somalogic.github.io/SomaDataIO/dev/reference/getAnalyteInfo.md).
  Used to calculate analyte dilutions for the matrix column ordering. If
  `NULL`, a table is generated internally from `data` (if possible), and
  the analytes are plotted in dilution order.

- apt.order:

  Character. How should the columns/features be ordered? Options
  include: by dilution mix ("dilution"), by median overall signal
  ("signal"), or as-is in `data` (default).

- sample.order:

  Either a character string indicating the column name with entries to
  be used to order the data frame rows, or a numeric vector representing
  the order of the data frame rows. The default (`NULL`) leaves the row
  ordering as it is in `data`.

- fc.crit:

  Integer. The fold change criterion to evaluate. Defaults to 5x.

- x:

  An object of class `"outlier_map"`.

- ...:

  Arguments for S3 print methods.

## Value

A list of class `c("outlier_map", "Map")` containing:

- matrix:

  A boolean matrix of `TRUE/FALSE` whether each sample is an outlier
  according the the stated criteria.

- x.lab:

  A character string containing the plot x-axis label.

- title:

  A character string containing the plot title.

- rows.by.freq:

  A logical indicating if the samples are ordered by outlier frequency.

- class.tab:

  A table containing the frequencies of each class if input
  `sample.order` is defined as a categorical variable.

- sample.order:

  A numeric vector representing the order of the data frame rows.

- legend.sub:

  A character string containing the plot legend subtitle.

## Details

For the S3 plotting method, see
[`plot.Map()`](https://somalogic.github.io/SomaDataIO/dev/reference/plot.Map.md).

## Functions

- `print(outlier_map)`: There is a S3 print method for class
  `"outlier_map"`.

## See also

Other Calc Map:
[`getOutlierIds()`](https://somalogic.github.io/SomaDataIO/dev/reference/getOutlierIds.md),
[`plot.Map()`](https://somalogic.github.io/SomaDataIO/dev/reference/plot.Map.md)

## Author

Stu Field

## Examples

``` r
dat <- example_data |> dplyr::filter(SampleType == "Sample")
om <- calcOutlierMap(dat)
class(om)
#> [1] "outlier_map" "Map"         "list"       

# S3 print method
om
#> ══ SomaLogic Outlier Map ══════════════════════════════════════════════
#> "170 x 5284"
#> "Outlier Map: | x - median(x) | > 6 * mad(x) & FC > 5x"
#> "Proteins Ordered in Adat"
#> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, …, 169,
#> and 170
#> "Proteins"
#>   Outlier Map dimensions    NA
#>   Title                     FALSE
#>   Class Table               NA
#>   Rows by Frequency         FALSE
#>   Sample Order              NA
#>   x-label                   FALSE
#>   Legend Sub-title          NA
#> ═══════════════════════════════════════════════════════════════════════

# `sample.order = "frequency"` orders samples by outlier frequency
om <- calcOutlierMap(dat, sample.order = "frequency")
om$rows.by.freq
#> [1] TRUE
om$sample.order
#>   [1]   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
#>  [17]  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32
#>  [33]  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47  48
#>  [49]  49  50  51  52  53  54  55  56  57  58  59  60  61  62  63  64
#>  [65]  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80
#>  [81]  81  82  83  84  85  86  87  88  89  90  91  92  93  94  95  96
#>  [97]  97  98  99 100 101 102 103 104 105 106 107 108 109 110 111 112
#> [113] 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128
#> [129] 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144
#> [145] 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160
#> [161] 161 162 163 164 165 166 167 168 169 170

# order samples field in Adat
om <- calcOutlierMap(dat, sample.order = "Sex")
om$sample.order
#>   [1]   1   2   5   6   8   9  10  13  14  16  17  21  22  28  29  30
#>  [17]  31  32  35  38  39  41  43  44  46  47  48  51  53  54  58  61
#>  [33]  63  66  68  69  70  71  77  79  81  82  83  85  86  89  90  94
#>  [49]  95 101 102 104 106 108 112 114 119 120 122 125 126 127 128 132
#>  [65] 133 135 136 141 142 143 145 146 147 154 156 157 158 159 160 161
#>  [81] 164 165 166 167 170   3   4   7  11  12  15  18  19  20  23  24
#>  [97]  25  26  27  33  34  36  37  40  42  45  49  50  52  55  56  57
#> [113]  59  60  62  64  65  67  72  73  74  75  76  78  80  84  87  88
#> [129]  91  92  93  96  97  98  99 100 103 105 107 109 110 111 113 115
#> [145] 116 117 118 121 123 124 129 130 131 134 137 138 139 140 144 148
#> [161] 149 150 151 152 153 155 162 163 168 169
```
