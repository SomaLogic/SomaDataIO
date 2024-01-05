
# generate mock `soma_adat`
df <- mock_adat()

# silence signalling for below tests
withr::local_options(list(usethis.quiet = TRUE))

test_that("TRUE returned when attributes look good", {
  expect_true(is_intact_attr(df))
})

test_that("FALSE returned when attributes <= 3 in length", {
  df <- data.frame(df)
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE returned when Header.Meta is missing", {
  x <- df
  attributes(x)$Col.Meta <- NULL
  expect_false(is_intact_attr(x, TRUE))
})

test_that("FALSE returned when Col.Meta is missing", {
  x <- df
  attributes(x)$Header.Meta <- NULL
  expect_false(is_intact_attr(x, TRUE))
})

test_that("FALSE when Header.Meta has elements missing", {
  attributes(df)$Header.Meta <- c("this", "should", "fail")
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE when Col.Meta has elements missing", {
  attributes(df)$Col.Meta <- c("SeqId", "Target", "DUMMY", "Units")
  expect_false(is_intact_attr(df, TRUE))
})

test_that("FALSE when Col.Meta is not a tibble", {
  attr(df, "Col.Meta") <- as.list(attr(df, "Col.Meta"))
  expect_false(is_intact_attr(df, TRUE))
})

test_that("user defined `verbose =` param overrides internal logic as expected", {
  withr::local_options(list(usethis.quiet = FALSE))   # allow oops
  expect_snapshot( is_intact_attr(iris, verbose = TRUE) )
  expect_snapshot( is_intact_attr(iris, verbose = FALSE) )
})

test_that("verbosity is triggered only when called directly", {
  withr::local_options(list(usethis.quiet = FALSE))  # allow oops
  .env <- parent.frame(sys.nframe())        # env at top of the stack
  # assign functions for use in local scope below
  .env$with_interactive <- with_interactive
  .env$f1 <- function(x) is_intact_attr(x)  # 1 level
  .env$f2 <- function(x) f1(x)              # 2 levels

  local(envir = .env, {
    # direct call (signals >> oops)
    with_interactive(TRUE, expect_snapshot(is_intact_attr(iris)))
  })

  local(envir = .env, {
    with_interactive(TRUE, expect_snapshot(f1(iris))) # 1 level away
  })

  local(envir = .env, {
    with_interactive(TRUE, expect_snapshot(f2(iris))) # 2 levels away
  })

  rm(f1, f2, with_interactive, envir = .env)  # clean up leftover functions
  expect_equal(ls(envir = .env), character(0))  # test successful cleanup

})
