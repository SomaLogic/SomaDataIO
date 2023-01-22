
# Note ----
# Remote machines sometimes don't like the fancy UTF-8 unicode symbols
# set to FALSE to enable ASCII fallbacks; see `testthat::local_test_context()`
# unit tests for print output also don't colors/bold styles {from `pillar`}
# Turn all these off for the unit testing context

# Testing ----
test_that("`soma_adat` S3 print method returns known output", {
  withr::local_options(list(cli.num_colors = 1L,
                            cli.unicode    = FALSE,
                            pillar.bold    = FALSE,
                            pillar.subtle  = TRUE,
                            tibble.width   = 80))

  adat <- read_adat(system.file("example", "example_data.adat",
                    package = "SomaDataIO", mustWork = TRUE))
  # default
  expect_snapshot_output(adat)

  # head
  expect_snapshot_output(head(adat))

  # show_header is TRUE
  expect_snapshot_output(print(adat, show_header = TRUE))

  # break atts
  attributes(adat)$Header.Meta <- NULL
  expect_false(is.intact.attributes(adat))
  expect_snapshot_output(adat)
})
