
# Setup ----
adat <- mock_adat()

# Testing ----
test_that("`diffAdats()` generates 'all-passing' output with equal ADATs", {
  expect_snapshot(diffAdats(adat, adat))
})

test_that("`diffAdats()` generates correct output with 1 analyte missing", {
  # random remove analyte column
  expect_snapshot(diffAdats(adat, adat[, -9L]))
})

test_that("`diffAdats()` generates correct output with 1 clin variable missing", {
  # random remove analyte column
  expect_snapshot(diffAdats(adat, adat[, -3L]))
})

test_that("`diffAdats()` generates correct output with 1 clin variable added", {
  # add variable 'foo'
  new <- adat
  new$foo <- "bar"
  expect_snapshot(diffAdats(adat, new))
})

test_that("`diffAdats()` generates correct output with 1 variable changed", {
  # change 'Subarray' variable
  expect_snapshot(
    diffAdats(adat, dplyr::mutate(adat, Subarray = rev(Subarray)))
  )
})

test_that("`diffAdats()` generates correct output 2 random values changed", {
  new <- adat
  new[c(3L, 5L), c(8L, 10L)] <- 999.9
  expect_snapshot(diffAdats(adat, new))
})
