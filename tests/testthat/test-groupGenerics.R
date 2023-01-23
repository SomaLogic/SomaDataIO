
# Setup ----
adat <- mock_adat()
meta <- getMeta(adat)

# Testing ----
test_that("the `log()` generic generates correct results", {
  base10 <- log10(adat)
  base_e <- log(adat)
  expect_equal(base10, log(adat, base = 10))
  expect_equal(base_e, log(adat, base = exp(1)))
  expect_equal(base10$seq.1234.56, log10(adat$seq.1234.56))
  expect_equal(base10$seq.1234.56,
               c(3.3120715213029, 3.4137020127811, 3.5177104102231,
                 3.2866360787164, 3.3909174524973, 3.4092905006405))
  expect_equal(base_e$seq.1234.56,
               c(7.6263265118822, 7.8603393665536, 8.0998275520497,
                 7.5677592409488, 7.8078759776937, 7.8501814844609))
  expect_equal(base10[, meta], adat[, meta])   # meta untouched
})

test_that("the `exp()` generic generates correct results", {
  e <- exp(log(adat))
  expect_equal(e$seq.1234.56, exp(log(adat$seq.1234.56)))
  expect_equal(e[, meta], adat[, meta])   # meta untouched
})

test_that("the `sqrt()` generic generates correct results", {
  root <- sqrt(adat)
  expect_equal(root$seq.1234.56, sqrt(adat$seq.1234.56))
  expect_equal(root$seq.1234.56,
               c(45.293487390573, 50.915616464892, 57.392508221893,
                 43.986361522636, 49.597378963006, 50.657674640670))
  expect_equal(root[, meta], adat[, meta])   # meta untouched
})

test_that("the `floor()` and `round()` generics generate correct results", {
  round <- round(adat)
  floor <- floor(adat)
  expect_equal(round$seq.1234.56, round(adat$seq.1234.56))
  expect_equal(floor$seq.1234.56, floor(adat$seq.1234.56))
  expect_false(all(floor$seq.1234.56 == round$seq.1234.56))
  expect_equal(floor$seq.1234.56, c(2051, 2592, 3293, 1934, 2459, 2566))
  expect_equal(round$seq.1234.56, c(2052, 2592, 3294, 1935, 2460, 2566))
  expect_equal(round[, meta], adat[, meta])   # meta untouched
  expect_equal(floor[, meta], adat[, meta])  # meta untouched
})

test_that("the `tan()` generic generates correct results", {
  tan <- tan(adat)
  expect_equal(tan$seq.1234.56, tan(adat$seq.1234.56))
  expect_equal(tan$seq.1234.56,
               c(0.040018548385454, 0.663865445376258, 16.675275912665480,
                 -0.447862083484393, 0.032964171438384, -0.522134474108074))
  expect_equal(tan[, meta], adat[, meta])   # meta untouched
})

test_that("the `antilog()` generic inverts the log of any base", {
  expect_equal(adat, antilog(log10(adat)))
  expect_equal(adat, antilog(log2(adat), 2L))
  expect_equal(adat, antilog(log(adat), exp(1)))
  expect_equal(antilog(1:4), c(10, 100, 1000, 10000))
  expect_equal(antilog(1, 2), 2)
  expect_equal(antilog(1, exp(1)), 2.718281828459)
  expect_equal(antilog(NA), NA_real_)
  expect_equal(antilog(TRUE), 10)
  expect_equal(antilog(1L), 10)
  expect_equal(antilog(1L), antilog(1))
  expect_equal(antilog(1), antilog(1.0))
  expect_equal(antilog(data.frame(a = 1)), data.frame(a = 10))
  expect_equal(antilog(NULL), numeric())
  err_msg <- "non-numeric argument to binary operator"
  expect_error(antilog(""), err_msg)
  expect_error(antilog(NA_character_), err_msg)
})

test_that("the `Ops()` group generic generates the expected output", {
  # 'Arith' group
  expect_type((adat + 5)$seq.1234.56, "double")
  expect_type((adat - 5)$seq.1234.56, "double")
  expect_type((adat * 5)$seq.1234.56, "double")
  expect_type((adat / 5)$seq.1234.56, "double")
  expect_type((adat * 5)$seq.1234.56, "double")
  expect_equal((adat + 1)$seq.1234.56, adat$seq.1234.56 + 1)
  expect_equal((adat - 1)$seq.1234.56, adat$seq.1234.56 - 1)
  expect_equal((adat * 2)$seq.1234.56, adat$seq.1234.56 * 2)
  expect_equal((adat / 2)$seq.1234.56, adat$seq.1234.56 / 2)
  expect_equal((adat ^ 2)$seq.1234.56, adat$seq.1234.56 ^ 2)

  # 'Compare' group
  expect_type((adat > 5)$seq.1234.56, "logical")
  expect_type((adat < 5)$seq.1234.56, "logical")
  expect_type((adat == 5)$seq.1234.56, "logical")
  expect_type((adat != 5)$seq.1234.56, "logical")
  expect_type((adat >= 5)$seq.1234.56, "logical")
  expect_type((adat <= 5)$seq.1234.56, "logical")
  expect_equal((adat > 2500)$seq.1234.56,  c(FALSE, TRUE, TRUE, FALSE, FALSE, TRUE))
  expect_equal((adat < 2500)$seq.1234.56, !c(FALSE, TRUE, TRUE, FALSE, FALSE, TRUE))
  expect_equal((adat == 2566.2)$seq.1234.56,  c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
  expect_equal((adat != 2566.2)$seq.1234.56, !c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
  expect_equal((adat >= 2566.2)$seq.1234.56, c(FALSE, TRUE, TRUE, FALSE, FALSE, TRUE))
  expect_equal((adat <= 2566.2)$seq.1234.56, c(TRUE, FALSE, FALSE, TRUE, TRUE, TRUE))

  expect_equal(sum(adat > 3000), 10)
  expect_equal(sum(adat < 3000), 8)

  # meta  ata untouched
  ops <- adat + 10
  expect_s3_class(ops, "soma_adat")
  expect_equal(ops[, meta], adat[, meta])

  # cannot pass `soma_adat` as RHS unless `==`
  expect_error(
    adat + adat,
    "The RHS ('adat') of `+` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat - adat,
    "The RHS ('adat') of `-` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat * adat,
    "The RHS ('adat') of `*` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat / adat,
    "The RHS ('adat') of `/` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat^adat,
    "The RHS ('adat') of `^` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat != adat,
    "The RHS ('adat') of `!=` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat > adat,
    "The RHS ('adat') of `>` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat >= adat,
    "The RHS ('adat') of `>=` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat < adat,
    "The RHS ('adat') of `<` cannot be a `soma_adat` class.", fixed = TRUE
  )
  expect_error(
    adat <= adat,
    "The RHS ('adat') of `<=` cannot be a `soma_adat` class.", fixed = TRUE
  )

  expect_snapshot(
    expect_error(adat == adat, NA)   # expect error-free; invokes `diffAdats()`
  )

  foo <- adat[, getAnalytes(adat)]
  bar <- data.frame(1:6, 1:6, 1:6)
  expect_error(                                   # soma_adat <-> data.frame; error
    expect_warning(foo + bar, "Incompatible methods"), # soma_adat <-> data.frame; warn
    "non-numeric argument to binary operator"
  )
  expect_error(data.frame(foo) + bar, NA) # data.frame <-> data.frame; no error
})

test_that("the `Summary()` group generic generates the expected output", {
  expect_equal(range(adat), c(1934.8, 4317.8))
  expect_equal(range(adat, 5000), c(1934.8, 5000))
  expect_equal(range(adat, 500), c(500, 4317.8))
  expect_equal(sum(adat), 54680.9)
  expect_equal(sum(adat, 1), 54681.9)   # `+` 1
  expect_equal(sum(adat, -1), 54679.9)  # `-` 1
  expect_equal(min(adat), 1934.8)
  expect_equal(min(adat, 100), 100)
  expect_equal(min(adat, -999), -999)
  expect_equal(max(adat), 4317.8)
  expect_equal(max(adat, 4906), 4906)
  expect_equal(max(adat, Inf), Inf)
})
