
test_that("matchSeqIds returns correct 'y'", {
  x <- c("seq.4554.56", "seq.3714.49", "PlateId")
  y <- c("Fake", "3714-49", "Assay", "4554-56")
  # non-SeqId elements should be removed
  expect_equal(matchSeqIds(x, y), c("4554-56", "3714-49"))  # ordered by 'x'
  expect_equal(matchSeqIds(x, y, order.by.x = FALSE),
               c("3714-49", "4554-56"))  # ordered by 'y'
  # when SeqIds are passes as 'x'
  expect_equal(matchSeqIds(y, x), c("seq.3714.49", "seq.4554.56"))  # ordered by 'y'
  expect_equal(matchSeqIds(y, x, order.by.x = FALSE),
               c("seq.4554.56", "seq.3714.49"))  # ordered by 'x'
})
