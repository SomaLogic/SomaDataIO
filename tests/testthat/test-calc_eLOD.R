# Setup ----
# soma_adat input filtered to "Buffer" samples
buffer_samples <- example_data |> filter(SampleType == "Buffer")

drop_seqs <- length(getAnalytes(example_data)) - 10
drop_seqs <- getAnalytes(example_data)[1:drop_seqs]

buffer_samples <- buffer_samples |> select(-all_of(drop_seqs))

# data.frame input
df <- withr::with_seed(101, {
  data.frame(
    SampleType = rep(c("Sample", "Buffer"), each = 10),
    SampleId = paste0("Sample_", 1:20),
    seq.20.1.100 = runif(20, 1, 100),
    seq.21.1.100 = runif(20, 1, 100),
    seq.22.2.100 = runif(20, 1, 100)
  )
})
sample_ids <- paste0("Sample_", 11:20)
selected_samples <- df |> filter(SampleId %in% sample_ids)

# Testing ----
test_that("`calc_eLOD` produces a warning when it should", {
  expect_warning(
    calc_eLOD(example_data),
    "Ensure input data includes buffer samples only!"
  )
})

test_that("`calc_eLOD` produces an error when it should", {
  expect_error(
    calc_eLOD(list(SampleId = 1:3, seq.1000.123 = 100:102)),
    "`data` must be a soma_adat, tibble, or data.frame"
  )
})

test_that("`calc_eLOD` works on a soma_adat input filtered to buffer samples", {
  out <- calc_eLOD(buffer_samples)

  expect_s3_class(out, "tbl_df")
  expect_equal(dim(out), c(10L, 2L))
  expect_equal(
    head(out, 3),
    tibble(SeqId = c("seq.9981.18", "seq.9983.97", "seq.9984.12"),
               eLOD  = c(45.08555, 52.98848, 123.02824)),
    tolerance = 0.00001
  )
})

test_that("`calc_eLOD` works on a data.frame input", {
  out <- calc_eLOD(selected_samples)

  expect_s3_class(out, "tbl_df")
  expect_equal(dim(out), c(3L, 2L))
  expect_equal(
    head(out, 3),
    tibble(SeqId = c("seq.20.1.100", "seq.21.1.100", "seq.22.2.100"),
           eLOD  = c(168.0601, 130.7047, 115.9958)),
    tolerance = 0.0001
  )
})
