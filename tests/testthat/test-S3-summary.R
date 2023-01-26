
# Setup ----
adat <- mock_adat()

# get 2 analytes
apts <- c("seq.1234.56", "seq.9898.99")
summ <- summary(adat[, apts])

# Testing ----
test_that("summary method returns correct object", {
  expect_s3_class(summ, "adat_summary")
  expect_length(summ, length(apts))
  expect_equal(dim(summ), c(10, length(apts)))
  expect_equal(dimnames(summ)[[2L]], apts)
})

test_that("summary method returns correct values", {
  true <- data.frame(
    seq.1234.56 = c("Target : MMP-1     ",
                    "Min    : 1934.8    ",
                    "1Q     : 2153.6    ",
                    "Median : 2513.1    ",
                    "Mean   : 2483.1    ",
                    "3Q     : 2585.9    ",
                    "Max    : 3293.9    ",
                    "sd     :  482.4    ",
                    "MAD    :  401.0    ",
                    "IQR    :  432.3    "),
    seq.9898.99 = c("Target : MMP-3     ",
                    "Min    : 3228.8    ",
                    "1Q     : 3655.8    ",
                    "Median : 3821.3    ",
                    "Mean   : 3790.5    ",
                    "3Q     : 3920.3    ",
                    "Max    : 4317.8    ",
                    "sd     :  361.6    ",
                    "MAD    :  250.0    ",
                    "IQR    :  264.5    ")
  ) |> addClass("adat_summary")
  expect_equal(summ, true)
})

test_that("summary method returns correct values when annotations tbl is passed", {
  anno  <- getAnalyteInfo(adat)
  summ2 <- summary(adat[, apts], anno)
  expect_equal(summ, summ2)
})

test_that("the printed output is as expected", {
  withr::with_options(list(width = 50), expect_snapshot_output(summ))
})
