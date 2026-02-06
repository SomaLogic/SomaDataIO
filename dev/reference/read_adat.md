# Read (Load) SomaLogic ADATs

The parse and load a `*.adat` file as a `data.frame`-like object into an
R workspace environment. The class of the returned object is a
`soma_adat` object.

`read.adat()` is **\[superseded\]**. For backward compatibility it will
likely never go away completely, but you are strongly encouraged to
shift your code to use `read_adat()`.

`is.soma_adat()` checks whether an object is of class `soma_adat`. See
[`inherits()`](https://rdrr.io/r/base/class.html).

## Usage

``` r
read_adat(file, debug = FALSE, verbose = getOption("verbose"), ...)

read.adat(file, debug = FALSE, verbose = getOption("verbose"), ...)

is.soma_adat(x)
```

## Arguments

- file:

  Character. The elaborated path and file name of the `*.adat` file to
  be loaded into an R workspace.

- debug:

  Logical. Used for debugging and development of an ADAT that fails to
  load, particularly out-of-spec, poorly modified, or legacy ADATs.

- verbose:

  Logical. Should the function call be run in *verbose* mode, printing
  relevant diagnostic call information to the console.

- ...:

  Additional arguments passed ultimately to
  [`read.delim()`](https://rdrr.io/r/utils/read.table.html), or
  additional arguments passed to either other S3 print or summary
  methods as required by those generics.

- x:

  An `R` object to test.

## Value

A `data.frame`-like object of class `soma_adat` consisting of SomaLogic
RFU (feature) data and clinical meta data as columns, and samples as
rows. Row names are labeled with the unique ID "SlideId_Subarray"
concatenation. The sections of the ADAT header (e.g., "Header.Meta",
"Col.Meta", ...) are stored as attributes (e.g.
`attributes(x)$Header.Meta`).

Logical. Whether `x` inherits from class `soma_adat`.

## See also

[`read.delim()`](https://rdrr.io/r/utils/read.table.html)

Other IO:
[`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md),
[`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md),
[`soma_adat`](https://somalogic.github.io/SomaDataIO/dev/reference/soma_adat.md),
[`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)

## Author

Stu Field

## Examples

``` r
# path to *.adat file
# replace with your file path
adat_path <- system.file("extdata", "example_data10.adat",
                         package = "SomaDataIO", mustWork = TRUE)
adat_path
#> [1] "/Users/runner/work/_temp/Library/SomaDataIO/extdata/example_data10.adat"

my_adat <- read_adat(adat_path)

is.soma_adat(my_adat)
#> [1] TRUE
```
