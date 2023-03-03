
# Setup ----
f <- test_path("testdata", "single_sample.adat")
adat <- read_adat(f)
withr::local_options(list(usethis.quiet = TRUE))  # silence ui signalling

# Testing ----
test_that("`write_adat()` produces unchanged out -> in -> out", {
  f_check <- tempfile("write-", fileext = ".adat")
  true_lines <- readLines(f)
  write_adat(adat, file = f_check)
  test_lines <- readLines(f_check)
  # certain lines are expected change:
  #   the *History lines in HEADER; CreatedBy & CreatedDate changes
  test_lines <- grep("^!?Created[DB][ay]", test_lines,
                     invert = TRUE, value = TRUE)
  true_lines <- grep("^!?Created[DB][ay]", true_lines,
                     invert = TRUE, value = TRUE)
  expect_equal(true_lines, test_lines)
  unlink(f_check)
})

test_that("`write_adat()` produces unchanged in -> out -> in", {
  f_check <- tempfile("write-", fileext = ".adat")
  write_adat(adat, file = f_check)
  # some attributes are expected to be false:
  #   TABLE_BEGIN will shift due to CreatedBy & CreatedDate changes
  expect_equal(read_adat(f_check), adat, ignore_attr = TRUE)
  unlink(f_check)
})

test_that("`write_adat()` throws error when no file name is passed", {
  expect_error(write_adat(adat), "Must provide output file name ...")
})

test_that("`write_adat()` throws warning when passing invalid file format", {
  bad_ext <- tempfile("write-", fileext = ".txt")
  if (  tolower(Sys.info()[["sysname"]]) == "windows" ) {
    # path sep '\` on windows gets messy with the warning match
    match <- "File extension is not `*.adat`"
  } else {
    match <- paste0(
      "File extension is not `*.adat` ('", bad_ext, "'). ",
      "Are you sure this is the correct file extension?"
    )
  }
  expect_warning(write_adat(adat, file = bad_ext), match, fixed = TRUE)
  unlink(bad_ext)
})

test_that("`write_adat()` shifts Col.Meta correctly when clinical data added/removed", {
  # rm meta data
  f_check <- tempfile("write-", fileext = ".adat")
  short   <- dplyr::select(head(adat),
                           SlideId, Subarray, SampleGroup,
                           seq.2182.54, seq.2190.55)
  write_adat(short, file = f_check)
  expect_equal(read_adat(f_check), short, ignore_attr = TRUE)
  expect_equal(getMeta(short), getMeta(read_adat(f_check)))
  unlink(f_check)

  # add meta data
  f_check2 <- tempfile("write-", fileext = ".adat")
  long     <- head(adat)
  long$foo <- "bar"
  write_adat(long, file = f_check2)  # write_adat() re-orders meta to come 1st!
  new <- read_adat(f_check2)
  expect_equal(new[, getMeta(new)], long[, getMeta(long)], ignore_attr = TRUE)
  expect_equal(new[, getAnalytes(new)], long[, getAnalytes(long)], ignore_attr = TRUE)
  unlink(f_check2)
})
