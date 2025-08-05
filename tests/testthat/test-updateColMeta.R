# Setup ----
y <- read_adat(test_path("testdata", "single_sample.adat"))
attributes(y)$Col.Meta <- attributes(y)$Col.Meta |>
  filter(SeqId == "10000-28")
atts <- attributes(y)$Col.Meta

# update to match test-anno.xlsx SeqId
y <- y |>
  select(seq.10101.01 = seq.10000.28)
attributes(y)$Col.Meta <- atts |> mutate(SeqId = "10101-01")

cols <- c('SeqId',
          'SomaId',
          'Target',
          'TargetFullName',
          'UniProt',
          'Type',
          'Organism',
          'EntrezGeneSymbol',
          'EntrezGeneID')

anno <- read_annotations(test_path("testdata", "test-anno.xlsx")) |>
  dplyr::select(dplyr::all_of(cols))

# Testing ----
test_that("`updateColMeta()` updates the Col.Meta data properly", {
  new <- updateColMeta(y, anno)
  truth <- tibble::tibble(
    SeqId            = c("10101-01"),
    SomaId           = c("SL010101"),
    Target           = c("PROT1"),
    TargetFullName   = c("Beta-Alpha2"),
    UniProt          = c("P4321"),
    Type             = c("Protein"),
    Organism         = c("Human"),
    EntrezGeneSymbol = c("ABCD-2"),
    EntrezGeneID     = c("1415")
  )
  expect_equal(truth, attr(new, "Col.Meta") |> dplyr::select(dplyr::all_of(cols)))
})
