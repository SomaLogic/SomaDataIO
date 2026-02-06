# Update Col.Meta Attribute to Match Annotations Object

Utility to update a provided `soma_adat` object's column metadata to
match the annotations object.

## Usage

``` r
updateColMeta(adat, anno)
```

## Arguments

- adat:

  A `soma_adat` data object to update attributes.

- anno:

  A `tibble` containing analyte-specific annotations from
  [`read_annotations()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_annotations.md)

## Value

An identical object to `adat` with `Col.Meta` updated to match those in
`anno`.

## Details

Attempts to update the following column metadata in the adat:

- SomaId

- Target

- TargetFullName

- UniProt

- Type

- Organism

- EntrezGeneSymbol

- EntrezGeneID

## Author

Caleb Scheidel

## Examples

``` r
if (FALSE) { # \dontrun{
 anno_tbl     <- read_annotations("path/to/annotations.xlsx")
 adat         <- read_adat("path/to/adat_file.adat")
 updated_adat <- updateColMeta(adat, anno_tbl)
} # }
```
