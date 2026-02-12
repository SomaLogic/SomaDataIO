# Write an ADAT to File

One can write an existing modified internal ADAT (`soma_adat` R object)
to an external file. However the ADAT object itself *must* have intact
attributes, see
[`is_intact_attr()`](https://somalogic.github.io/SomaDataIO/dev/reference/is_intact_attr.md).

## Usage

``` r
write_adat(x, file)
```

## Arguments

- x:

  A `soma_adat` object (with intact attributes), typically created using
  [`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md).

- file:

  Character. File path where the object should be written. For example,
  extensions should be `*.adat`.

## Value

Invisibly returns the input `x`.

## Details

The ADAT specification *no longer* requires Windows end of line (EOL)
characters (`"\r\n"`). The current EOL spec is `"\n"` which is commonly
used in POSIX systems, like MacOS and Linux. Since the EOL affects the
resulting checksum, ADATs written on other systems generate slightly
differing files. Standardizing to `"\n"` attempts to solve this issue.
For reference, see the EOL encoding for operating systems below:  

|        |             |           |
|--------|-------------|-----------|
| Symbol | Platform    | Character |
| LF     | Linux       | `"\n"`    |
| CR     | MacOS       | `"\r"`    |
| CRLF   | DOS/Windows | `"\r\n"`  |

## See also

[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
[`is_intact_attr()`](https://somalogic.github.io/SomaDataIO/dev/reference/is_intact_attr.md)

Other IO:
[`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md),
[`parseHeader()`](https://somalogic.github.io/SomaDataIO/dev/reference/parseHeader.md),
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
[`soma_adat`](https://somalogic.github.io/SomaDataIO/dev/reference/soma_adat.md)

## Author

Stu Field

## Examples

``` r
# trim to 1 sample for speed
adat_out <- head(example_data, 1L)

# attributes must(!) be intact to write
is_intact_attr(adat_out)
#> [1] TRUE

write_adat(adat_out, file = tempfile(fileext = ".adat"))
#> ✔ ADAT passed all checks and traps.
#> ✔ ADAT written to: "/var/folders/75/ggvb9t6x5mlbs46lkdhlcbyc0000gn/T//RtmpCzQiMW/filef56a6609fc.adat"
```
