
# Setup ----
# mock up a dummy ADAT object
# smaller than `example_data` for speed/simplicity
data <- mock_adat()


# Testing ----
# count ----
test_that("count method produces expected output", {
  new <- count(data, SampleGroup)
  expect_false(is.soma_adat(new))
  expect_s3_class(new, "tbl_df")
  expect_equal(dim(new), c(2L, 2L))
  expect_named(new, c("SampleGroup", "n"))
  expect_equal(new$n, c(3, 3))

  new <- count(data, SampleGroup, TimePoint)
  expect_false(is.soma_adat(new))
  expect_s3_class(new, "tbl_df")
  expect_equal(new, tibble::tibble(
                      SampleGroup = c("A", "A", "B", "B"),
                      TimePoint   = c("after", "before", "after", "before"),
                      n           = c(1L, 2L, 2L, 1L))
  )
})

# arrange ----
test_that("`arrange()` method produces expected output", {
  new <- arrange(data, NormScale)
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data))
  expect_equal(names(new), names(data))
  new_rn <- rownames(data)[order(data$NormScale)]
  expect_equal(rownames(new), new_rn)
  expect_equal(sort(data$NormScale), new$NormScale)
  expect_true(is_intact_attr(new))
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
  # check the arrange happened correctly
  expect_equal(new$SampleId, c("005", "001", "002", "003", "004", "006"))
})

# rename ----
test_that("`rename()` method produces expected output", {
  new <- rename(data, PID = PlateId)
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_true(is_intact_attr(new))
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data))
  expect_true("PID" %in% names(new))
  expect_false("PlateId" %in% names(new))
  expect_setequal(rownames(new), rownames(data))
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
  expect_warning(   # warning if analyte is renamed
    new2 <- rename(data, PID = PlateId, seq.1111.11 = seq.3333.33),
    "You are renaming analytes. Modify the SomaScan menu with care."
  )
  expect_true(is_intact_attr(new2))
  new_cm <- attr(data, "Col.Meta")
  new_cm[2L, ] <- NA   # 3333-33 is renamed, NAs in Col.Meta row
  expect_equal(attr(new2, "Col.Meta"), new_cm)
})

# filter ----
test_that("`filter()` method produces expected output", {
  new <- filter(data, NormScale > 0.9)
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(names(new), names(data))
  expect_equal(dim(new), c(3L, ncol(data)))
  expect_equal(new$NormScale, c(1.1, 1.8, 1.8))
  expect_true(all(rownames(new) %in% rownames(data)))
  expect_true(is_intact_attr(new))
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
})

# mutate ----
test_that("`mutate()` method produces expected output", {
  new <- mutate(data, Subarray_2x = Subarray * 2)
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_true("Subarray_2x" %in% names(new))    # new column
  expect_equal("Subarray_2x", setdiff(names(new), names(data)))
  expect_equal(dim(new), dim(data) + c(0L, 1L))   # new column
  expect_equal(rownames(new), rownames(data))
  expect_equal(new$Subarray_2x, new$Subarray * 2)
  expect_true(is_intact_attr(new))
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
})

# select ----
test_that("`select()` method produces expected output", {
  apts <- head(getAnalytes(data), 2L)
  meta <- head(getMeta(data), 3L)
  new  <- select(data, all_of(meta), all_of(apts))
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_named(new, c(meta, apts))
  expect_equal(dim(new), c(nrow(data), 5L))
  expect_equal(getAnalytes(new, n = TRUE), length(apts))
  expect_length(setdiff(names(new), getAnalytes(new)), length(meta))
  expect_true(all(rownames(new) %in% rownames(data)))
  expect_true(is_intact_attr(new))
  ad <- attributes(new)$Col.Meta
  expect_equal(dim(ad), c(2L, 9L))
  expect_equal(ad$SeqId, getSeqId(apts))  # apt data sync'd?
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
})

# left-join ----
test_that("`left_join()` method produces expected output", {
  merge_data <- withr::with_seed(101,
                                 data.frame(SampleId = sample(data$SampleId),
                                            NewData  = rnorm(6)))
  new <- left_join(data, merge_data, by = "SampleId")
  expect_true(is.soma_adat(new))
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data) + c(0L, 1L))   # new column
  expect_true("NewData" %in% names(new))        # new column
  expect_equal(rownames(new), rownames(data))
  expect_equal(sum(new$NewData), sum(merge_data$NewData))
  expect_false(all(new$NewData == merge_data$NewData)) # some reordered
  expect_false(setequal(getMeta(new), getMeta(data)))
  expect_equal("NewData", setdiff(getMeta(new), getMeta(data)))
  expect_equal("NewData", tail(names(new), 1))
  expect_equal("NewData", tail(getMeta(new), 1))
  expect_equal(getAnalytes(new), getAnalytes(data))
  expect_true(is_intact_attr(new))
  expect_equal(names(attributes(new)), names(attributes(data))) # atts order preserved
})

test_that("`left_join()` method doesn't fix rownames if there aren't any", {
  x  <- data.frame(id = LETTERS[1:3], a = rnorm(3)) |> addClass("soma_adat")
  y  <- data.frame(id = LETTERS[1:3], b = rnorm(3))
  df <- left_join(x, y, by = "id")
  expect_false(has_rn(df))
  # create non-intersecting IDs for full_join()
  y  <- data.frame(id = LETTERS[3:5], b = rnorm(3))
  df <- full_join(x, y, by = "id")
  expect_false(has_rn(df))
})

# anti-join ----
test_that("`anti_join()` method generates expected output", {
  x  <- data.frame(id = LETTERS[1:3], a = rnorm(3), row.names = letters[1:3]) |>
    addClass("soma_adat")
  y  <- data.frame(id = LETTERS[2:4], b = rnorm(3))
  df <- anti_join(x, y, by = "id")
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_equal(rownames(df), "a")
  expect_equal(class(df), class(x))
})

# slice ----
test_that("`slice()` method is correctly dispatched", {
  new <- slice(data, 1:3)
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), c(3L, ncol(data)))
  expect_equal(rownames(new), c("12345_1", "12346_2", "12347_3"))
  # atts order preserved
  expect_equal(names(attributes(new)), names(attributes(data)))

  # check for duplicate rownames
  new <- slice(data, c(2, 2, 2))   # same row 3x
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), c(3L, ncol(data)))
  expect_equal(rownames(new), c("12346_2", "12346_2-1", "12346_2-2"))
})

# slice_sample ----
test_that("`slice_sample()` method is correctly dispatched", {
  n   <- 4
  new <- withr::with_seed(101, slice_sample(data, n = n))
  expect_true(is.soma_adat(new))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), c(n, ncol(data)))
  expect_equal(rownames(new), c("12345_1", "12350_3", "12346_2", "12347_3"))
  # atts order preserved
  expect_equal(names(attributes(new)), names(attributes(data)))
})

# sample_frac ----
test_that("`sample_frac()` method is correctly dispatched", {
  new <- withr::with_seed(101, sample_frac(data, replace = TRUE))
  rownames(new)
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), dim(data))
  expect_equal(
    rownames(new),
    c("12345_1", "12345_1-1", "12350_3", "12345_1-2", "12346_2", "12349_2")
  )
  # atts order preserved
  expect_equal(names(attributes(new)), names(attributes(data)))
})

# sample_n ----
test_that("`sample_n()` method is correctly dispatched", {
  n   <- 4
  new <- withr::with_seed(101, sample_n(data, size = n))
  expect_s3_class(new, "soma_adat")
  expect_equal(class(new), class(data))
  expect_equal(dim(new), c(n, ncol(data)))
  expect_equal(rownames(new), c("12345_1", "12350_3", "12346_2", "12347_3"))
  # atts order preserved
  expect_equal(names(attributes(new)), names(attributes(data)))
})

# group_by & ungroup ----
test_that("`group_by()` and `ungroup()` methods generates expected output", {
  df <- dplyr::group_by(data, SampleGroup)
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), rownames(data))
  un <- ungroup(df)
  expect_true(is_intact_attr(un))
  expect_s3_class(un, "soma_adat")
  expect_equal(rownames(un), rownames(df))
})

test_that("`grouped_df` objects handled by `nextMethod()` correctly for verbs", {
  # filter
  df <- dplyr::group_by(data, SampleGroup) |>
    dplyr::filter(dplyr::row_number() == 1L)
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), c("12345_1", "12346_2"))
  # mutate
  df <- dplyr::group_by(data, SampleGroup) |>
    dplyr::mutate(foo = "bar")
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), rownames(data))
  # select
  df <- dplyr::group_by(data, SampleGroup) |>
    dplyr::select(-7L)
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), rownames(data))
  # arrange
  df <- dplyr::group_by(data, SampleGroup) |>
    dplyr::arrange(SampleId)
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), rownames(data))
  # rename
  df <- dplyr::group_by(data, SampleGroup) |>
    dplyr::rename(ID = SampleId)
  expect_true(is.soma_adat(df))
  expect_s3_class(df, "soma_adat")
  expect_s3_class(df, "grouped_df")
  expect_true(is_intact_attr(df))
  expect_equal(rownames(df), rownames(data))
})
