devtools::load_all(".")

# originals
data <- example_data
x <- ex_analytes
y <- ex_anno_tbl
z <- ex_target_names

# 'new'
example_data <- read_adat("example_data.adat")
ex_analytes  <- getAnalytes(example_data)
ex_anno_tbl  <- getAnalyteInfo(example_data)
ex_target_names <- getTargetNames(ex_anno_tbl)

# 'save only if necessary'
if ( !isTRUE(all.equal(data, example_data)) ) {
  save(example_data, file = "data/example_data.rda", compress = "xz")
}

# 'save only if necessary'
if ( !all(isTRUE(all.equal(x, ex_analytes)),
          isTRUE(all.equal(y, ex_anno_tbl)),
          isTRUE(all.equal(z, ex_target_names))) {
  save(ex_analytes, ex_anno_tbl, ex_target_names, file = "data/data_objects.rda", compress = "xz")
}
