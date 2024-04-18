
# Testing ----
test_that("`.bullets()` prints expected output", {
  expect_snapshot(.bullets("prepare"))
  expect_snapshot(.bullets("submit"))
  expect_snapshot(.bullets("wait"))
})

test_that("`.ver_type()` returns expected release types", {
  expect_equal(.ver_type("1.0.0"), "major")
  expect_equal(.ver_type("0.1.0"), "minor")
  expect_equal(.ver_type("0.0.1"), "patch")
  expect_equal(.ver_type("0.0.0.1"), "dev")
})

test_that("`.create_checklist()` prints expected output", {
  expect_snapshot(.create_checklist("1.0.0"))
})
