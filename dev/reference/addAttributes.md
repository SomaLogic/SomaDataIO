# Add Attributes to `soma_adat` Objects

Adds a set of attributes, typically "Header.Meta" and "Col.Meta", to a
`data.frame`, `tibble`, `soma_adat` or similar tabular object. Existing
attributes `data` are *not* over-written. Typically untouched are:

- `names`

- `class`

- `row.names`

## Usage

``` r
addAttributes(data, new.atts)
```

## Arguments

- data:

  The *receiving* `data.frame` object for new attributes.

- new.atts:

  A *named* `list` object containing new attributes to add to the
  existing ones.

## Value

A data frame object corresponding to `data` but with the attributes of
`new.atts` grafted on to it. Existing attribute names are *not*
over-written.

## See also

[`attr()`](https://rdrr.io/r/base/attr.html),
[`generics::setdiff()`](https://generics.r-lib.org/reference/setops.html)

## Author

Stu Field
