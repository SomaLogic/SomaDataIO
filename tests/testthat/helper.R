
# skip if during devtools::check() or rcmdcheck::rcmdcheck()
skip_on_check <- function() {
  on_check <- !identical(Sys.getenv("_R_CHECK_PACKAGE_NAME_"), "")
  testthat::skip_if(on_check, "On devtools::check() / rcmdcheck::rcmdcheck()")
}

# mock up dummy data.frame -> soma_adat
# minimal set of attributes to trick `is_intact_attr()` to be TRUE
mock_adat <- function() {
  data <- data.frame(
    PlateId     = rep_len("Set A", 6),
    SlideId     = (12345 + 0:5),
    Subarray    = rep(1:3, 2),
    SampleId    = sprintf("%03i", 1:6),
    SampleGroup = rep(c("A", "B"), 3),
    TimePoint   = rep(c("before", "after"), each = 3),
    NormScale   = round(withr::with_seed(1, runif(6, 0, 2)), 1L),
    seq.1234.56 = round(withr::with_seed(2, rnorm(6, 2500, 500)), 1L),
    seq.3333.33 = round(withr::with_seed(3, rnorm(6, 3000, 500)), 1L),
    seq.9898.99 = round(withr::with_seed(4, rnorm(6, 3500, 500)), 1L)
  )
  rownames(data) <- genRowNames(data)
  structure(
    data,
    class = c("soma_adat", "data.frame"),
    Header.Meta = list(HEADER   = list(Version      = "1.2",
                                       AssayVersion = "V4",
                                       AssayRobot   = "Fluent 1",
                                       AssayType    = "PharmaServices",
                                       StudyMatrix  = "EDTA Plasma",
                                       Title        = "SL-99-999"),
                       COL_DATA = list(Name = c("SeqId", "UniProt",
                                                "EntrezGeneSymbol", "Target",
                                                "Organism","Units", "Type",
                                                "Dilution", "CalReference"),
                                       Type = rep_len("String", 9)
                                       ),
                       ROW_DATA = list(Name = getMeta(data),
                                       Type = rep_len("String",
                                                      getMeta(data, n = TRUE))
                                       )
                       ),
    Col.Meta = tibble::tibble(
      SeqId            = c("1234-56", "3333-33", "9898-99"),
      UniProt          = paste0("P0", 4321:4323),
      EntrezGeneSymbol = c("MMP1", "MMP2", "MMP3"),
      Target           = c("MMP-1", "MMP-2", "MMP-3"),
      Organism         = rep_len("Human", 3L),
      Units            = rep_len("RFU", 3L),
      Type             = rep_len("Protein", 3L),
      Dilution         = c("0.005", "1", "40"),
      CalReference     = seq(0.4, 0.8, length.out = 3L)),
    file_specs = list(empty_adat     = FALSE,
                      table_begin    = 20,
                      col_meta_start = 21,
                      col_meta_shift = 15,
                      data_begin     = 21 + 9,
                      old_adat       = FALSE),
    row_meta = getMeta(data)
  )
}
