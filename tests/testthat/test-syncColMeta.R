
test_that("`syncColMeta()` updates the Col.Meta data properly", {
  # `syncColMeta()` is called internally in `[`
  # we must by-pass it to force the Col.Meta out-of-sync
  # call the `data.frame` S3 method directly
  x <- mock_adat()
  rmcol <- ncol(x) - 1L
  new <- `[.data.frame`(x, -rmcol)   # rm analyte/column

  # add back Col.Meta to give `syncColMeta()` something to act upon
  attr(new, "Col.Meta") <- attr(x, "Col.Meta")

  # do the update
  new2 <- syncColMeta(new)
  truth <- tibble::tibble(
    SeqId    = c("1234-56", "9898-99"),
    UniProt  = c("P04321", "P04323"),
    EntrezGeneSymbol = c("MMP1", "MMP3"),
    Target   = c("MMP-1", "MMP-3"),
    Organism = c("Human", "Human"),
    Units    = c("RFU", "RFU"),
    Type     = c("Protein", "Protein"),
    Dilution = c("0.005", "40"),
    CalReference = c(0.4, 0.8)
  )
  expect_equal(truth, attr(new2, "Col.Meta"))
})
