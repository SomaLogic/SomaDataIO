
# Setup ----
# Generate dummy soma_adat-like attributes
x <- list()
x$Header.Meta$HEADER$CreatedDate <- "1999-12-31"
x$Header.Meta$HEADER$CreatedBy <- "DonTrump"
x$Header.Meta$HEADER$Version <- "1.0"
col <- c("SeqId", "Target", "Units", "Dilution")
x$Header.Meta$COL_DATA$Name <- c(col, "UniProt", "Dilution2")
x$Header.Meta$COL_DATA$Type <- rep_len("string", length(col) + 2L)
x$Header.Meta$ROW_DATA$Name <- c("a", "b")
x$Col.Meta <- tibble::tibble(SeqId = "1234-56", Target = "MyProtein",
                             Units = "RFU", Dilution = 0.01, Dilution2 = 1)
x$Header.Meta$TABLE_BEGIN <- "my-adat.adat"
y <- data.frame(a = 1:10, b = LETTERS[1:10], c = runif(10), seq.1234.56 = runif(10))
y <- addAttributes(y, x)
y <- addClass(y, "soma_adat")


# Testing ----
test_that("`prepHeaderMeta()` wrangles the correct fields", {
  expect_message(z <- prepHeaderMeta(y), "Updating ADAT version to")
  expect_type(z, "list")
  expect_equal(z$Header.Meta$HEADER$CreatedDate, format(Sys.time(), "%Y-%m-%d"))
  expect_equal(z$Header.Meta$HEADER$Version, "1.2")
  expect_equal(z$Header.Meta$HEADER$CreatedByHistory,
               paste0("DonTrump (", x$Header.Meta$HEADER$CreatedDate, ")"))

  by <- strsplit(z$Header.Meta$HEADER$CreatedBy, "; ", fixed = TRUE)[[1L]]
  expect_length(by, 4L)
  expect_match(by[1L], "^User:")
  expect_match(by[2L], "^Package: SomaDataIO v[0-9][.][0-9][.][0-9]")
  expect_match(by[3L],
    "^R [3-7][.][0-9][.][0-9]|^using R Under development",
    ignore.case = TRUE
  )
  expect_match(by[4L], "^OS:")

  expect_equal(z$Header.Meta$COL_DATA$Name, col)   # UniProt + Dilution2 removed
  expect_equal(z$Header.Meta$COL_DATA$Type, rep_len("string", 4L))
  expect_equal(z$Header.Meta$ROW_DATA$Name, getMeta(y))
  expect_equal(z$Header.Meta$ROW_DATA$Type, c(a = "integer",
                                              b = "character",
                                              c = "double"))

  expect_null(as.list(z$Col.Meta)$Dilution2)  # Dilution2 removed
  expect_equal(z$Header.Meta$TABLE_BEGIN, x$Header.Meta$TABLE_BEGIN)
  expect_equal(z$Col.Meta, x$Col.Meta[, col])
  expect_equal(z$row.names, 1:10)
  expect_equal(z$names, names(y))
  expect_equal(z$class, class(y))
})

test_that("an error is thrown if new data has broken attributes", {
  expect_output(
    prepHeaderMeta(data.frame(1:10))
  ) |>
  expect_error(
    "Stopping while you fix the attributes of `.*`."
  )
})

test_that("`prepHeaderMeta()` correctly reconstitutes the original key-names", {
  header <- parseHeader(test_path("testdata/empty.adat"))$Header.Meta
  attr(y, "Header.Meta") <- header
  z <- prepHeaderMeta(y)
  # remove 'History' new entries from check
  mapped_idx <- grep("History$", names(z$Header.Meta$HEADER))
  true_names <- vapply(header$HEADER, attr, which = "raw_key", "")
  expect_named(z$Header.Meta$HEADER[-mapped_idx], unname(true_names))
  expect_named(z$Header.Meta$COL_DATA, paste0("!", names(header$COL_DATA)))
  expect_named(z$Header.Meta$ROW_DATA, paste0("!", names(header$ROW_DATA)))
})
