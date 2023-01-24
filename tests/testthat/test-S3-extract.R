
# Setup ----
adat <- mock_adat()

# Testing ----
test_that("extract charcter method within-type produces correct output", {
  # Meta data only
  chr <- c("PlateId", "SlideId", "Subarray", "SampleGroup")
  new <- adat[, chr]
  expect_named(new, chr)
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(6, 4))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_s3_class(atts$Col.Meta, "tbl_df")
  expect_equal(dim(atts$Col.Meta), c(0, 9))   # no Col.Meta

  # Aptamers only
  chr <- c("seq.1234.56", "seq.3333.33", "seq.9898.99")
  new <- adat[, chr]
  expect_named(new, chr)
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(6L, 3L))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(length(chr), 9L))
  expect_equal(atts$Col.Meta$Target, c("MMP-1", "MMP-2", "MMP-3"))
})

test_that("extract charcter method cross-types produces correct output", {
  chr <- c("PlateId", "SlideId", "Subarray",
           "seq.9898.99", "seq.1234.56")   # also out of order; rm 3333-33
  new <- adat[, chr]
  expect_named(new, chr)
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(6L, length(chr)))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(2L, 9L))
  expect_equal(atts$Col.Meta$Target, c("MMP-3", "MMP-1"))
})

test_that("extract numeric method within-type produces correct output", {
  # Meta data only
  idx <- seq(1, 7, by = 2)
  new <- adat[, idx]
  expect_named(new, names(adat)[idx])
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), length(idx)))
  expect_equal(rownames(new), rownames(adat))
  expect_equal(dim(attr(new, "Col.Meta")), c(0L, 9L))

  # Analytes only
  idx <- c(8L, 10L)
  new <- adat[, idx]
  expect_named(new, names(adat)[idx])
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), length(idx)))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(length(idx), 9L))
  expect_equal(getSeqId(names(adat)[idx]), getSeqId(atts$Col.Meta$SeqId, TRUE))
})

test_that("extract numeric method cross-types produces correct output", {
  idx <- c(1L, 2L, 3L, 8L, 10L)
  new <- adat[, idx]
  expect_named(new, names(adat)[idx])
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(dim(new), c(nrow(adat), length(idx)))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(2L, 9L))
  expect_equal(getSeqId(names(adat)[c(8L, 10L)]), atts$Col.Meta$SeqId)
})

test_that("negative numeric indices do not break attributes", {
  # single negative
  new <- adat[, -9L]
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), ncol(adat) - 1L))
  expect_equal(dim(attr(new, "Col.Meta")), c(2L, 9L))

  # vector negative
  idx <- c(8L, 10L)
  new <- adat[, -idx]
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), ncol(adat) - length(idx)))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta),
               c(getAnalytes(adat, n = TRUE) - length(idx), 9L))
})

test_that("the `drop = FALSE` argument is working correctly", {
  # numeric
  expect_type(adat[, 9], "double")
  expect_null(dim(adat[, 9]))
  # with drop = FALSE
  expect_s3_class(adat[, 9, drop = FALSE], "soma_adat")
  expect_equal(dim(adat[, 9, drop = FALSE]), c(nrow(adat), 1))
  # character
  expect_type(adat[, "SampleGroup"], "character")
  expect_null(dim(adat[, "TimePoint"]))
  # with drop = FALSE
  expect_s3_class(adat[, "Subarray", drop = FALSE], "soma_adat")
  expect_equal(dim(adat[, "PlateId", drop = FALSE]), c(nrow(adat), 1))
})

test_that("extracting a single row does not change the object class", {
  expect_s3_class(adat[3L, ], "soma_adat")
  expect_s3_class(adat[5L, ], "data.frame")
  expect_true(is_intact_attr(adat[5L, ]))
  expect_equal(dim(adat[3L, ]), c(1, 10))
  expect_named(adat[3L, seq(1, 7, 2)], c("PlateId", "Subarray",
                                        "SampleGroup", "NormScale"))
})

test_that("extracting a single column behaves like a `data.frame`", {
  expect_type(adat[, 1L], "character")
  expect_type(adat[, "PlateId"], "character")
  expect_type(adat[, 2L], "double")
  expect_type(adat[, 5L], "character")
  expect_type(adat[, "Subarray"], "integer")
  expect_type(adat[, "SlideId"], "double")
  expect_length(adat[, 3L], nrow(adat))
  expect_length(adat[, "TimePoint"], nrow(adat))
  expect_named(adat[3L, seq(1, 7, 2)], c("PlateId", "Subarray",
                                        "SampleGroup", "NormScale"))
  expect_null(dim(adat[, 3L]))
  expect_null(dim(adat[, "SampleGroup"]))
})

test_that("extract logical method within-type produces correct output", {
  # Meta data only
  lgl <- seq_len(ncol(adat)) %in% seq(1, 7, by = 2)
  new <- adat[, lgl]
  expect_named(new, names(adat)[lgl])
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), sum(lgl)))
  expect_equal(rownames(new), rownames(adat))
  expect_equal(dim(attr(new, "Col.Meta")), c(0L, 9L))

  # Aptamers only
  lgl <- seq_len(ncol(adat)) %in% c(8, 10)   # pick 2
  new <- adat[, lgl]
  expect_named(new, names(adat)[lgl])
  expect_true(is_intact_attr(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(dim(new), c(nrow(adat), sum(lgl)))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(sum(lgl), 9L))
  expect_equal(getSeqId(names(adat)[lgl]), atts$Col.Meta$SeqId)
})

test_that("extract logical method cross-type produces correct output", {
  lgl <- seq_len(ncol(adat)) %in% c(1L, 2L, 3L, 9L, 10L)
  new <- adat[, lgl]
  expect_named(new, names(adat)[lgl])
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(dim(new), c(nrow(adat), sum(lgl)))
  expect_equal(rownames(new), rownames(adat))
  atts <- attributes(new)
  expect_equal(dim(atts$Col.Meta), c(2L, 9L))
  expect_equal(getSeqId(names(adat)[c(9L, 10L)]), atts$Col.Meta$SeqId)
})

test_that("attributes already broken, return normal data.frame method", {
  # strip out important atts
  attributes(adat)$Header.Meta <- NULL
  attributes(adat)$Col.Meta    <- NULL
  attributes(adat)$row_meta    <- NULL
  attributes(adat)$file_specs  <- NULL
  expect_false(is_intact_attr(adat))   # just to be sure
  expect_equal(sum(adat[, 3L]), 12)   # sum Subarray
  expect_equal(dim(adat[5L, ]), c(1L, 10L))
})

test_that("attribute elements are not re-ordered by extract; same order", {
  new <- adat[, 10:8L]
  expect_equal(names(attributes(new)), names(attributes(adat)))
})

test_that("`$` dispatch is functioning, no partial matching!", {
  expect_equal(sum(adat$Subarray), 12)
  expect_equal(sum(adat$seq.3333.33), 17039)
  expect_warning(foo <- adat$Subar, "Unknown or uninitialised column: 'Subar'")
  expect_null(foo)
  expect_warning(foo <- adat$seq.5494, "Unknown or uninitialised column: 'seq.5494'")
  expect_null(foo)
})

test_that("`[[` dispatch is functioning like `$`", {
  expect_equal(sum(adat[["Subarray"]]), 12)
  var <- "Subarray"
  expect_equal(sum(adat[[var]]), 12)
  expect_equal(sum(adat[[3L]]), 12)
  expect_equal(adat[[3L]], adat[[var]])
  expect_equal(sum(adat[["seq.3333.33"]]), 17039)
})

test_that("`[[` dispatch no partial matching", {
  expect_warning(foo <- adat[["Subar"]], "Unknown or uninitialised column: 'Subar'")
  expect_null(foo)
  var <- "Subar"
  expect_warning(foo <- adat[[var]], "Unknown or uninitialised column: 'Subar'")
  expect_null(foo)
  expect_warning(foo <- adat[["seq.5494"]], "Unknown or uninitialised column: 'seq.5494'")
  expect_null(foo)
})

test_that("`[[` exact= argument trips a warning", {
  expect_warning(
    foo <- adat[[5L, exact = FALSE]], "`exact=` is ignored in `[[`.", fixed = TRUE
  )
  expect_equal(foo, adat[[5L]])
})

test_that("`[[` trips error when `j` or negative indices are passed", {
  expect_error(
    adat[[5, 3]],
    paste0("Passing jth column index not supported via `[[` for `soma_adat`.\n",
           "Please use `x[5, 3]` instead."), fixed = TRUE
  )
  expect_error(
    adat[[5L, 2:8L]],
    paste0("Passing jth column index not supported via `[[` for `soma_adat`.\n",
           "Please use `x[5L, 2:8L]` instead."), fixed = TRUE
  )
  expect_error(
    adat[[5L, foo]],
    paste0("Passing jth column index not supported via `[[` for `soma_adat`.\n",
           "Please use `x[5L, foo]` instead."), fixed = TRUE
  )
  expect_error(adat[[9000L]], "subscript out of bounds")
  expect_error(adat[[-1]], "invalid negative subscript in get1index")
})

test_that("Three `*<-.soma_adat` assignment methods preserve attribute order", {
  true_names <- names(attributes(adat))
  # [
  new <- adat
  new[4L, 9L] <- 999
  expect_equal(new[4L, 9L], 999)
  expect_equal(names(attributes(new)), true_names)
  # $
  new <- adat
  new$PlateId <- "Set 1"
  expect_equal(new$PlateId, rep_len("Set 1", nrow(adat)))
  expect_equal(names(attributes(new)), true_names)
  # [[
  new <- adat
  new[["PlateId"]] <- "Set 2"
  expect_equal(new$PlateId, rep_len("Set 2", nrow(adat)))
  expect_equal(names(attributes(new)), true_names)
})
