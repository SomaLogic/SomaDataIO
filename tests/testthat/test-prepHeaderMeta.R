
# Setup ----
# Generate dummy soma_adat-like attributes
x <- list()
x$Header.Meta$HEADER$CreatedDate <- "1999-12-31"
x$Header.Meta$HEADER$CreatedBy <- "DonTrump"
x$Header.Meta$HEADER$Version <- "1.0"
col <- c("SeqId", "Target", "Units", "Dilution")
x$Header.Meta$COL_DATA$Name <- c(col, "UniProt", "Dilution2")
x$Header.Meta$COL_DATA$Type <- rep_len("string", length(col) + 2)
x$Header.Meta$ROW_DATA$Name <- c("a", "b")
x$Col.Meta <- tibble::tibble(SeqId = "1234-56", Target = "MyProtein",
                             Units = "RFU", Dilution = 0.01, Dilution2 = 1)
x$Header.Meta$TABLE_BEGIN <- "my-adat.adat"
y <- data.frame(a = 1:10, b = LETTERS[1:10], c = runif(10),
                seq.1234.56 = rnorm(10), stringsAsFactors = FALSE)
y <- addAttributes(y, x)
y <- addClass(y, "soma_adat")


# Testing ----
test_that("`prepHeaderMeta()` wrangles the correct fields", {
  z <- prepHeaderMeta(y)
  expect_type(z, "list")
  expect_equal(z$Header.Meta$HEADER$CreatedDate, format(Sys.time(), "%Y-%m-%d"))
  expect_equal(z$Header.Meta$HEADER$Version, "1.2")
  expect_equal(z$Header.Meta$HEADER$CreatedDateHistory, "1999-12-31")
  expect_equal(z$Header.Meta$HEADER$CreatedByHistory, "DonTrump")

  by <- strsplit(z$Header.Meta$HEADER$CreatedBy, "; ", fixed = TRUE)[[1L]]
  expect_length(by, 4)
  expect_match(by[1L], "^User:")
  expect_match(by[2L], "^Package: SomaDataIO_[0-9][.][0-9][.][0-9]")
  expect_match(by[3L],
    "^using R version [3-7][.][0-9][.][0-9]|^using R Under development",
    ignore.case = TRUE
  )
  expect_match(by[4L], "^Platform:")

  expect_equal(z$Header.Meta$COL_DATA$Name, col)   # UniProt + Dilution2 removed
  expect_equal(z$Header.Meta$COL_DATA$Type, rep_len("string", 4))
  expect_equal(z$Header.Meta$ROW_DATA$Name, getMeta(y))
  expect_equal(z$Header.Meta$ROW_DATA$Type, c(a = "integer",
                                              b = "character",
                                              c = "double"))

  expect_false("Dilution2" %in% names(z$Col.Meta))   # Dilution2 removed
  expect_equal(z$Header.Meta$TABLE_BEGIN, x$Header.Meta$TABLE_BEGIN)
  expect_equal(z$Col.Meta, x$Col.Meta[, col])
  expect_equal(z$row.names, 1:10)
  expect_equal(z$names, names(y))
  expect_equal(z$class, class(y))
})

test_that("error is thrown if no data has broken attributes", {
  expect_error(
    prepHeaderMeta(data.frame(1:10)),
    "Stopping while you fix the attributes of `data`."
  )
})
