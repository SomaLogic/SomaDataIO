
# Note ----
# Remote machines sometimes don't like the fancy UTF-8 unicode symbols
# set to FALSE to enable ASCII fallbacks; see `testthat::local_test_context()`
# unit tests for print output also don't colors/bold styles {from `pillar`}
# Turn all these off for the unit testing context

# Testing ----
test_that("`soma_adat` S3 print method returns known output", {
  testthat::local_reproducible_output()

  adat <- example_data

  # default
  expect_snapshot_output(adat)

  # head
  expect_snapshot_output(head(adat))

  # show_header is TRUE
  expect_snapshot_output(print(adat, show_header = TRUE))

  # grouped_df
  grouped_adat <- dplyr::group_by(adat, SampleType)
  expect_snapshot_output(grouped_adat)

  # break atts
  attr(adat, "Header.Meta") <- NULL
  expect_false(is_intact_attr(adat, verbose = FALSE))
  expect_snapshot_output(adat)
})
