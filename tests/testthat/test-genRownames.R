
set.seed(1)
n <- 50
a <- sample(LETTERS, n, replace = TRUE)
b <- sample(1:99, size = n, replace = TRUE)

test_that("genRowNames generates correct rownames to data frame", {
  rn <- data.frame(SlideId = a, Subarray = b) |> genRowNames()
  expect_equal(rn, paste0(a, "_", b))
})

test_that("genRowNames numbers numerically if no SlideId or Subarray", {
  expect_warning(
    df <- data.frame(Slide = a, Sub = b) |> genRowNames(),
    "No SlideId_Subarray found in ADAT. Rows numbered sequentially."
  )
  expect_equal(df, as.character(1:n))
})
