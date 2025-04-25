devtools::load_all(".")

# originals
data <- example_data
x <- ex_analytes
y <- ex_anno_tbl
z <- ex_target_names
zz <- ex_clin_data

# 'new'
example_data <- read_adat("example_data.adat")  # download via wget
ex_analytes  <- getAnalytes(example_data)
ex_anno_tbl  <- getAnalyteInfo(example_data)
ex_target_names <- getTargetNames(ex_anno_tbl)

withr::with_seed(123, {
  ex_clin_data <- example_data |>
    dplyr::mutate(
      smoking_status = sample(c("Current", "Past", "Never"),
                              size = 192, replace = TRUE),
      alcohol_use    = sample(c("Yes", "No"),
                              size = 192, replace = TRUE)
    ) |>
    dplyr::mutate(smoking_status = ifelse(is.na(Age), NA, smoking_status),
                  alcohol_use    = ifelse(is.na(Age), NA, alcohol_use)) |>
    select(SampleId, smoking_status, alcohol_use) |>
    as_tibble()
})


# 'save only if necessary'
if ( !isTRUE(all.equal(data, example_data)) ) {
  save(example_data, file = "data/example_data.rda", compress = "xz")
}

# 'save only if necessary'
if ( !all(isTRUE(all.equal(x, ex_analytes)),
          isTRUE(all.equal(y, ex_anno_tbl)),
          isTRUE(all.equal(z, ex_target_names)),
          isTRUE(all.equal(zz, ex_clin_data))) ) {
  save(ex_analytes, ex_anno_tbl, ex_target_names, ex_clin_data, file = "data/data_objects.rda", compress = "xz")
}
