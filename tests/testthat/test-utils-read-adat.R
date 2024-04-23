
# Setup ----
file   <- test_path("testdata", "single_sample.adat")
adat   <- read_adat(file)
header <- parseHeader(file)

# Testing ----
# checkHeader ----
test_that("`checkHeader()` prints expected output", {
  expect_silent(checkHeader(header, verbose = FALSE))
  expect_snapshot(checkHeader(header, verbose = TRUE))
})

test_that("`checkHeader()` error conditions are met", {
  idx <- which(names(header) == "Header.Meta")
  expect_error(
    checkHeader(header[-idx]),
    "Could not find `Header.Meta`"
  )
  idx <- which(names(header) == "Col.Meta")
  expect_error(
    checkHeader(header[-idx]),
    "No `Col.Meta` data found in adat"
  )
  idx <- which(names(header) == "file_specs")
  expect_error(
    checkHeader(header[-idx]),
    paste(
      "No `file_specs` entry found in header ...",
      "should be added during file parsing"
    )
  )
})

# catchHeaderMeta ----
test_that("`catchHeaderMeta()` error conditions are met", {
  HM <- header$Header.Meta
  expect_invisible(catchHeaderMeta(HM))

  HM$ROW_DATA$Name <- NULL
  expect_error(
    catchHeaderMeta(HM),
    "Could not find `Name` entry in `ROW_DATA` of `Header.Meta`"
  )

  HM$ROW_DATA$Name <- rep("foo", 2L)
  expect_error(
    catchHeaderMeta(HM),
    "Duplicate row (clinical) meta data fields defined in header `ROW_DATA`",
    fixed = TRUE
  )

  HM$ROW_DATA <- NULL
  expect_warning(
    catchHeaderMeta(HM),
    "`ROW_DATA` is mising from `Header.Meta`"
  )
})

# catchHeaderMeta ----
test_that("`catchColMeta()` error conditions are met", {
  CM <- header$Col.Meta
  expect_invisible(catchColMeta(CM))

  CM$SeqId <- NULL
  expect_warning(
    catchColMeta(CM),
    paste0(
      "No `SeqId` row found in Column Meta Data:\n",
      "SeqIds will be absent from adat Column Meta AND ",
      "`getAnalytes()` cannot function properly"
    ),
    fixed = TRUE
  )
})

# catchFile ----
test_that("`catchFile()` error conditions are met", {
  FS <- header$file_specs
  expect_invisible(catchFile(FS))
  FS$empty_adat <- 1L
  expect_error(
    catchFile(FS),
    "The `empty_adat` entry of `file_specs` should be class logical:"
  )
  FS <- header$file_specs
  FS$table_begin <- "foo"  # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `table_begin` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS$table_begin <- numeric(2) # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `table_begin` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS <- header$file_specs
  FS$old_adat <- 1L # should be logical(1)
  expect_error(
    catchFile(FS),
    "The `old_adat` entry of `file_specs` should be class logical:"
  )
  FS <- header$file_specs
  FS$col_meta_start <- "foo" # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `col_meta_start` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS$col_meta_start <- numeric(2) # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `col_meta_start` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS <- header$file_specs
  FS$col_meta_shift <- "foo" # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `col_meta_shift` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS$col_meta_shift <- numeric(2) # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `col_meta_shift` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS <- header$file_specs
  FS$data_begin <- "foo" # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `data_begin` entry of `file_specs` should be class numeric AND length 1:"
  )
  FS$data_begin <- numeric(2) # should be numeric(1)
  expect_error(
    catchFile(FS),
    "The `data_begin` entry of `file_specs` should be class numeric AND length 1:"
  )
})

# catchDims ----
test_that("`catchDims()` error conditions are met", {
  x <- mock_adat()
  nc <- ncol(x)
  expect_invisible(catchDims(x, nc))
  expect_error(
    catchDims(x, nc - 1L),
    "Number of columns in `rfu_dat` not equal to (meta + aptamers) length",
    fixed = TRUE
  )
})

# verbosity ----
test_that(".verbosity()` prints expected output", {
  expect_snapshot(.verbosity(adat, header))  # `adat` is a single sample ADAT
})
