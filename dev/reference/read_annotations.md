# Import a SomaLogic Annotations File

Import a SomaLogic Annotations File

## Usage

``` r
read_annotations(file)
```

## Arguments

- file:

  A path to an annotations file location. This should be a SomaLogic
  annotations file in `*.xlsx` format.

## Value

A `tibble` containing analyte-specific annotations and related (e.g.
lift/bridging) information, keyed on SomaLogic
[SeqId](https://somalogic.github.io/SomaDataIO/dev/reference/SeqId.md),
the unique SomaScan analyte identifier.

## Examples

``` r
if (FALSE) { # \dontrun{
  # for example
  file <- "~/Downloads/SomaScan_11K_v5.0_Plasma_Serum_Annotated_Menu.xlsx"
  anno_tbl <- read_annotations(file)
} # }
```
