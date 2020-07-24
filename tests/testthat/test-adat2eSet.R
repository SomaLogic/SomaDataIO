
suppressPackageStartupMessages(library(Biobase))

sub_adat <- sample.adat[1:10, c(1:5, 25:27)]

test_that("adat2eset unit test", {
  eSet <- adat2eSet(sub_adat)
  expect_is(eSet, "ExpressionSet")
  expect_is(eSet@assayData$exprs, "matrix")
  expect_equal(dim(eSet@assayData$exprs), c(3, 10))
  expect_is(eSet@experimentData@other, "list")
  expect_equal(eSet@experimentData@url, "www.somalogic.com")
  expect_equal(eSet@experimentData@title, "SL-01-999")
  expect_equal(eSet@experimentData@lab, "SomaLogic, Inc.")
  expect_equal(eSet@experimentData@title, "SL-01-999")
  expect_equal(eSet@experimentData@other$Version, "1.2")
  expect_equal(eSet@experimentData@other$ExpDate, "2014-10-21")
  expect_equal(eSet@experimentData@title, eSet@experimentData@other$Title)
  ad <- getFeatureData(sub_adat) %>% data.frame() %>%
    tibble::column_to_rownames("AptName")
  expect_equal(rownames(eSet@featureData@varMetadata), names(ad))
  expect_equal(rownames(eSet@featureData@data), get_features(names(sub_adat)))
  expect_equal(eSet@featureData@data, ad)
  expect_equal(rownames(eSet@phenoData@data), rownames(sub_adat))
  expect_named(eSet@phenoData@data, getMeta(sub_adat))
  expect_equal(eSet@phenoData@data, data.frame(sub_adat[, getMeta(sub_adat)]))
  expect_equal(eSet@phenoData@dimLabels, c("sampleNames", "sampleColumns"))
  expect_equal(eSet@featureData@dimLabels, c("featureNames", "featureColumns"))
  expect_equal(colnames(eSet@assayData$exprs), rownames(sub_adat))
  expect_equal(rownames(eSet@assayData$exprs), rownames(ad))
  expect_equal(rownames(eSet@assayData$exprs), get_features(names(sub_adat)))
  expect_equal(rownames(eSet@assayData$exprs), rownames(eSet@featureData@data))
})
