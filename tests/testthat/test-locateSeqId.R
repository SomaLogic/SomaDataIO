
# Setup ----
# locateSeqId() and regexSeqId() are both tested here

# Testing ----
test_that("locateSeqId() returns NAs and integers with/without SeqId", {
  rex <- locateSeqId(c("Sample", "seq.1234.5"))
  expect_equal(rex, data.frame(x     = c("Sample", "seq.1234.5"),
                               start = c(NA_integer_, 5L),
                               stop  = c(NA_integer_, 10L)))
  expect_equal(locateSeqId(NA_character_),
               data.frame(x     = NA_character_,
                          start = NA_integer_,
                          stop  = NA_integer_)
  )
})

test_that("locateSeqId() works on aptamer names", {
  rex <- locateSeqId("ABCD.1234.5.5")
  expect_equal(rex, data.frame(x = "ABCD.1234.5.5", start = 6L, stop = 13L))
})

test_that("locateSeqId() works on SeqIds", {
  rex <- locateSeqId("1234-5_5")
  expect_equal(rex, data.frame(x = "1234-5_5", start = 1L, stop = 8L))
})

test_that("locateSeqId() works on funky aptamer names", {
  rex <- locateSeqId("SOMAmer.1.12345.666.13")
  expect_equal(rex, data.frame(x = "SOMAmer.1.12345.666.13",
                               start = 11L, stop = 22L))
  rex <- locateSeqId("ERVV.1.12531.5.3")
  expect_equal(rex, data.frame(x = "ERVV.1.12531.5.3", start = 8L, stop = 16L))
  rex <- locateSeqId("ERVV1.12531.5.3")
  expect_equal(rex, data.frame(x = "ERVV1.12531.5.3", start = 7L, stop = 15L))
})

test_that("locateSeqId() works with missing version numbers in SeqIds", {
  # 1 digit
  rex <- locateSeqId("1231-8")
  expect_equal(rex, data.frame(x = "1231-8", start = 1L, stop = 6L))
  # 2 digits
  rex <- locateSeqId("1231-54")
  expect_equal(rex, data.frame(x = "1231-54", start = 1L, stop = 7L))
})

test_that("locateSeqId() works with missing version numbers in Aptamers", {
  # 1 digit
  rex <- locateSeqId("ABCD.1231.8")
  expect_equal(rex, data.frame(x = "ABCD.1231.8", start = 6L, stop = 11L))
  # 2 digits
  rex <- locateSeqId("ABCD.1231.54")
  expect_equal(rex, data.frame(x = "ABCD.1231.54", start = 6L, stop = 12L))
})

test_that("locateSeqId() uses the trailing argument", {
  rex <- locateSeqId("ABCD.1231.54.EFGH", trailing = TRUE)
  expect_equal(rex, data.frame(x = "ABCD.1231.54.EFGH",
                               start = NA_integer_, stop = NA_integer_))
  rex <- locateSeqId("ABCD.1231.54.EFGH", trailing = FALSE)
  expect_equal(rex, data.frame(x = "ABCD.1231.54.EFGH", start = 6L, stop = 12L))
})
