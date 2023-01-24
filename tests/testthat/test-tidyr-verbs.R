
# Setup ----
data   <- mock_adat()
data$a <- LETTERS[1:6]
data$d <- as.character(1:6)
data$b <- paste0(data$a, "-", data$d)


# Testing ----
test_that("separate() method produces expected output", {
  new <- separate(data, b, into = c("b", "c"))
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data) + c(0, 1))   # 1 new column
  expect_true("c" %in% names(new))
  expect_true("b" %in% names(new))
  expect_equal(rownames(new), rownames(data))
  expect_equal(new$a, new$b)
  expect_equal(new$c, new$d)
  expect_true(is.soma_adat(new))
})

test_that("lazy eval works identically among 3 main inputs for `col=`", {
  x <- separate(data, "b", into = c("b", "c")) # quoted string
  v <- "b"
  y <- separate(data, v, into = c("b", "c")) # variable
  z <- separate(data, b, into = c("b", "c")) # unquoted string
  expect_equal(x, y)
  expect_equal(x, z)
  expect_equal(y, z)
})

test_that("unite() method produces expected output", {
  new <- unite(data, "combo", c("a", "d"), sep = "-")
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data) + c(0, -1))   # 1 less column
  expect_true("combo" %in% names(new))
  expect_false("a" %in% names(new))
  expect_false("d" %in% names(new))
  expect_equal(rownames(new), rownames(data))
  expect_equal(new$combo, new$b)
  expect_true(is.soma_adat(new))
})
