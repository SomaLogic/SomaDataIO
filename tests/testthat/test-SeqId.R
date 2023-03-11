
test_that("getSeqId deals with Aptamer names", {
  expect_equal(getSeqId("ABDC.3948.48.2"), "3948-48_2")
  expect_equal(getSeqId("My.Favorite.Apt.3948.88.9"), "3948-88_9")
})

test_that("getSeqId deals with SeqIds of various sorts", {
  expect_equal(getSeqId("3948.48.2"), "3948-48_2")
  expect_equal(getSeqId("3948-48_2"), "3948-48_2")
  expect_equal(getSeqId("3948-48"), "3948-48")
  expect_equal(getSeqId("3948.48"), "3948-48")
})

test_that("getSeqId trim argument works properly", {
  expect_equal(getSeqId("ABDC.3948.48.2", TRUE), "3948-48")
  expect_equal(getSeqId("My.Favorite.Apt.3948.88.9", TRUE), "3948-88")
  expect_equal(getSeqId("3948.48.2", TRUE), "3948-48")
  expect_equal(getSeqId("3948-48_2", TRUE), "3948-48")
})

test_that("getSeqId trim argument works even when there is no version #", {
  expect_equal(getSeqId("ABDC.3948.48", TRUE), getSeqId("3948-48", TRUE))
  expect_equal(getSeqId("My.Favorite.Apt.3948.88", TRUE),
               getSeqId("3948-88_12", TRUE))
  expect_equal(getSeqId("3948.48", TRUE), getSeqId("3948.48.83", TRUE))
  expect_equal(getSeqId("3948-48", TRUE), getSeqId("3948-48_14", TRUE))
  expect_equal(getSeqId("3948-48", TRUE), getSeqId("3948-48_4", TRUE))
})

test_that("`getSeqId()` vectorization works", {
  adat <- mock_adat()
  seq_vec <- getSeqId(getAnalytes(adat))
  expect_equal(seq_vec, attr(adat, "Col.Meta")$SeqId)
})

test_that("`getSeqId()` returns NAs for non-matches; char(0) for NULL", {
  expect_equal(getSeqId(""), NA_character_)
  expect_equal(getSeqId("A"), NA_character_)
  expect_equal(getSeqId(NA_character_), NA_character_)
  expect_equal(getSeqId(NULL), character(0))
})

test_that("`getSeqId()` matches only at the end of a string", {
  expect_equal(getSeqId("seq.1234.56_"), NA_character_)
  expect_equal(getSeqId("seq.1234.56x"), NA_character_)
  expect_equal(getSeqId("1234-56x"), NA_character_)
  expect_equal(getSeqId("seq.1234.56 "), "1234-56")   # trailing whitespace trim
  expect_equal(getSeqId("seq.1234.56\t"), "1234-56")  # trailing whitespace trim
  expect_equal(getSeqId("seq.1234.56 A"), NA_character_)
})

test_that("`getSeqId()` type conversion for factors and lists", {
  expect_equal(getSeqId(list("foo", "seq.1234.5")), c(NA_character_, "1234-5"))
  expect_equal(getSeqId(factor("seq.1234.5")), "1234-5")
  expect_equal(getSeqId(factor("foo")), NA_character_)
  expect_equal(getSeqId(list(NULL)), NA_character_)  # trimws() converts -> "NULL"
})


# New AptName format ----
test_that("`getSeqId` properly strips SeqId prefixes from 'Aptnames'", {
  test_vec <- c("seq.2182-54_1", "seq.2190-55_1", "seq.2192-63_10",
                "seq.2201-17_6", "seq.2211-9_6", "seq.2212-69_1")
  expect_equal(getSeqId(test_vec), c("2182-54_1", "2190-55_1",
                                     "2192-63_10", "2201-17_6",
                                     "2211-9_6", "2212-69_1"))
})

test_that("`getSeqId` properly strips the version number of SeqId", {
  test_vec <- c("seq.2182-54_1", "seq.2190-55_1", "seq.2192-63_10",
                "seq.2201-17_6", "seq.2211-9_6", "seq.2212-69_1")
  expect_equal(getSeqId(test_vec, TRUE),
               c("2182-54", "2190-55", "2192-63",
                 "2201-17", "2211-9", "2212-69"))
})

test_that("`getSeqId()` properly does nothing when there is no version number", {
  with_vers <- c("seq.2182-54_1", "seq.2190-55_1", "seq.2192-63_10",
                 "seq.2201-17_6", "seq.2211-9_6", "seq.2212-69_1")
  no_vers <- c("seq.2182-54", "seq.2190-55", "seq.2192-63",
               "seq.2201-17", "seq.2211-9", "seq.2212-69")
  expect_equal(getSeqId(with_vers, TRUE),
               getSeqId(no_vers, TRUE))
})

test_that("`seqid2apt()` properly generates AptNames in new format", {
  expect_equal(seqid2apt("1234-45"), "seq.1234.45")
  expect_equal(seqid2apt("1234-45_8"), "seq.1234.45")   # version stripped
  # error trips
  expect_error(seqid2apt(1), "inherits(x, \"character\") is not TRUE", fixed = TRUE)
  expect_error(
    seqid2apt("ABCD.1234.56"),
    paste("At least some values are not in 'SeqId' format.\nTry running",
          "`getSeqId()` for: 'ABCD.1234.56'"), fixed = TRUE
  )
  expect_error(
    seqid2apt("1234.56"),
    paste("At least some values are not in 'SeqId' format.\nTry running",
          "`getSeqId()` for: '1234.56'"), fixed = TRUE
  )
})

test_that("`apt2seqid()` properly generates SeqIds in new format", {
  expect_equal(apt2seqid("seq.1234.45"), "1234-45")
  expect_equal(apt2seqid("seq.1234.45.8"), "1234-45")   # version stripped

  # error trips
  expect_error(apt2seqid(1), "inherits(x, \"character\") is not TRUE", fixed = TRUE)
  expect_error(
    apt2seqid("1234_56"),
    paste("Some values of `x` do not contain 'SeqIds'.\nPlease check: '1234_56'")
  )

  meta_vec <- c("SampleId", "TimePoint", "seq.1234.45", "seq.5678.89.9")
  expect_error(
    apt2seqid(meta_vec),
    paste("Some values of `x` do not contain 'SeqIds'.\nPlease check:",
          "'SampleId', 'TimePoint'")
  )

  na_vec <- c("seq.1234.45", NA_character_, "seq.5678.89")
  expect_error(
    apt2seqid(na_vec),
    paste("Some values of `x` do not contain 'SeqIds'.\nPlease check: NA")
  )

  expect_error(apt2seqid(NULL))
  expect_error(apt2seqid(45))
})

test_that("apt2seqid() returns a seqId, when one is present in a vector", {
  seq_vec <- c("1234-56", "seq.5678.89", "9012-23", "seq.2345.67", "8910-01")
  expect_equal(apt2seqid(seq_vec), c("1234-56", "5678-89", "9012-23", "2345-67", "8910-01"))
})

test_that("apt2seqid() returns a warning when only seqIds are provided", {
  seq_vec <- c("1234-56", "9012-23", "8910-01")
  expect_warning(apt2seqid(seq_vec), "All values are already in 'SeqId' format.")
})

test_that("`is.SeqId()` properly returns matches", {
  x <- "ABCD.1234.56"
  expect_false(is.SeqId(x))
  expect_true(is.SeqId(getSeqId(x)))
  expect_true(is.SeqId("1234-56"))
  expect_true(is.SeqId("1234-5"))
  expect_true(is.SeqId("1234-56_7"))
  expect_true(is.SeqId("1234-5_6"))
  expect_false(is.SeqId("1234.56"))
  expect_false(is.SeqId("1234"))
  expect_false(is.SeqId("seq.1234-5"))
  expect_false(is.SeqId("1234-5a"))
  expect_false(is.SeqId("1234-5_6a"))
})
