
x <- list(Header.Meta = list(HEADER = list(Version = "1.2")))

test_that("`getAdatVersion()` returns the ADAT version string", {
  expect_equal(getAdatVersion(x), "1.2")
  x$Header.Meta$HEADER$Version <- "2.5"
  expect_equal(getAdatVersion(x), "2.5")
})

test_that("`getAdatVersion()` errors out if no `Version` in HEADER", {
  x$Header.Meta$HEADER <- list(Dummy = "Cox", Yellow = 3)
  expect_error(
    getAdatVersion(x),
    "Unable to identify ADAT Version from Header information."
  )
})

test_that("`getAdatVersion()` throws warning if tabs after key-value pair", {
  x$Header.Meta$HEADER$Version <- c("1.2", "\t")
  expect_warning(
    y <- getAdatVersion(x),
    paste("Version length > 1 ... there may be empty tabs",
          "in the header block above the data matrix."),
  )
  expect_equal(y, "1.2")
})

test_that("`getAdatVersion()` catches JAVA version number format", {
  x$Header.Meta$HEADER$Version <- "1.01"
  expect_error(
    getAdatVersion(x),
    "Invalid Version ('1.01'). Please modify to `1.0.1`.",
    fixed = TRUE
  )
})

test_that("`getAdatVersion()` S3 method returns the same character", {
  expect_equal(
    getAdatVersion(example_data),             # soma_adat
    getAdatVersion(attributes(example_data))  # list
  )
})

test_that("`getAdatVersion()` S3 default method trips errror", {
  expect_error(
    getAdatVersion(""), "Unable to find a method for class: 'character'"
  )
})
