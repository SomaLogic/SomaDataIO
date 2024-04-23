
# Note ----
# Remote machines sometimes don't like the fancy UTF-8 unicode symbols
# set to FALSE to enable ASCII fallbacks; see `testthat::local_test_context()`
# unit tests for print output also don't colors/bold styles {from `pillar`}
# Turn all these off for the unit testing context
testthat::local_reproducible_output()
adat <- example_data

# Testing ----
test_that("`soma_adat` S3 print method returns expected default output", {
  # default
  expect_snapshot_output(adat)
})

test_that("`soma_adat` S3 print method returns expected head output", {
  # head
  expect_snapshot_output(head(adat))
})

test_that("`soma_adat` S3 print method returns expected `show_header = TRUE` output", {
  # show_header is TRUE
  expect_snapshot_output(print(adat, show_header = TRUE))
})

test_that("`soma_adat` S3 print method returns expected `grouped_df` output", {
  # grouped_df
  grouped_adat <- dplyr::group_by(adat, SampleType)
  expect_snapshot_output(grouped_adat)
})

test_that("`soma_adat` S3 print method returns expected broken attributes output", {
  # break atts
  attr(adat, "Header.Meta") <- NULL
  expect_false(is_intact_attr(adat, verbose = FALSE))
  expect_snapshot_output(adat)
})
