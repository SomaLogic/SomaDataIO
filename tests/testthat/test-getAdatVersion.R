
test_that("getAdatVersion returns the ADAT version string", {
  x <- list(HEADER = list(Version = "1.2"))
  expect_equal(getAdatVersion(x), "1.2")
  x <- list(HEADER = list(Version = "2.5"))
  expect_equal(getAdatVersion(x), "2.5")
})

test_that("getAdatVersion errors out if no `Version` in HEADER", {
  x <- list(HEADER = list(Dummy = "Cox", Yellow = 3))
  expect_error(
    getAdatVersion(x),
    "Unable to identify ADAT Version from Header information."
  )
})

test_that("getAdatVersion throws warning if tabs after key-value pair", {
  x <- list(HEADER = list(Version = c("1.2", "\t")))
  expect_warning(
    y <- getAdatVersion(x),
    paste("Version length > 1 ... there may be empty tabs",
          "in the header block filling out the data matrix"),
    )
  expect_equal(y, "1.2")
})

test_that("getAdatVersion catches JAVA version number format", {
  x <- list(HEADER = list(Version = "1.01"))
  expect_error(
    getAdatVersion(x),
    "Fix java ADAT writer! Version cannot be"
  )
})
