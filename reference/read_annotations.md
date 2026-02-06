# Import a SomaLogic Annotations File

Import a SomaLogic Annotations File

## Usage

``` r
read_annotations(file)
```

## Arguments

- file:

  A path to an annotations file location. This is a sanctioned,
  versioned file provided by SomaLogic Operating Co., Inc. and should be
  an *unmodified* `*.xlsx` file.

## Value

A `tibble` containing analyte-specific annotations and related (e.g.
lift/bridging) information, keyed on SomaLogic
[SeqId](https://somalogic.github.io/SomaDataIO/reference/SeqId.md), the
unique SomaScan analyte identifier.

## Examples

``` r
if (FALSE) { # \dontrun{
  # for example
  file <- "~/Downloads/SomaScan_11K_Annotated_Content.xlsx"
  anno_tbl <- read_annotations(file)
} # }
```
