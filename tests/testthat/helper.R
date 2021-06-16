
# mock up dummy data.frame -> soma_adat
# minimal set of attributes to trick `is.intact.attributes()` to be TRUE
mock_adat <- function() {
  data <- data.frame(
    PlateId     = rep("Set A", 6),
    SlideId     = 253856411709:253856411714,
    Subarray    = rep(1:3, 2),
    SampleId    = sprintf("%03i", 1:6),
    SampleGroup = rep(c("M", "F"), 3),
    TimePoint   = rep(c("before", "after"), each = 3),
    NormScale   = withr::with_seed(1, rnorm(6)),
    seq.1234.56 = withr::with_seed(2, rnorm(6)),
    seq.3333.33 = withr::with_seed(3, rnorm(6)),
    seq.9898.99 = withr::with_seed(4, rnorm(6))
  )
  rownames(data) <- genRowNames(data)
  structure(data,
            class = c("soma_adat", "data.frame"),
            Header.Meta = list(HEADER   = list(Version = "1.2", Title = "SL-99-999"),
                               COL_DATA = list(Name = "SeqId", Type = "String"),
                               ROW_DATA = list(Name = "PlateId", Type = "String")),
            Col.Meta = tibble::tibble(SeqId    = c("1234-56", "3333-33", "9898-99"),
                                      Target   = c("MMP-1", "MMP-2", "MMP-3"),
                                      Dilution = c("0.005", "1", "40"),
                                      Units    = rep("RFU", 3))
  )
}
