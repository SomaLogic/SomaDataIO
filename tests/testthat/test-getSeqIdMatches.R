
test_that("`getSeqIdMatches()` returns correct and expected IDs", {
  adat <- mock_adat()
  apt_vec <- getAnalytes(adat)
  m <- getSeqIdMatches(apt_vec, names(adat))
  expect_s3_class(m, "data.frame")
  expect_named(m, c("apt_vec", "names(adat)"))
  expect_equal(dim(m), c(3, 2))
  expect_equal(dim(m), c(3, 2))
  # should be identical b/c nothing changed (only getMeta() differs)
  expect_equal(m[[1L]], m[[2L]])

  A1 <- apt_vec[1:2]
  A2 <- getSeqId(apt_vec[2:3])
  # There should be 1 overlapping analyte: 95-100
  m <- getSeqIdMatches(A1, A2)
  true <- data.frame(A1 = "seq.3333.33", A2 = "3333-33")
  expect_equal(m, true)
})
