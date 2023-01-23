
# Setup ----
# this ensures the list.files() call sorts the same across test() and check()
# must set the local collation order
# use 'C', the default during check(); 'en_US.UTF-8' common in SLIDE
withr::local_collate("C")

test_that("the default collation order has been set properly", {
  expect_equal(Sys.getlocale("LC_COLLATE"), "C")
})

files <- system.file("example", package = "SomaDataIO") |>
  list.files(pattern = "[.]adat$", full.names = TRUE) |>
  normalizePath()

adats <- loadAdatsAsList(files)
foo   <- collapseAdats(adats)
atts  <- attributes(foo)

# Testing ----
test_that("adats list is named properly", {
  expect_named(adats, cleanNames(basename(files)))
  expect_equal(lapply(adats, dim),
               list(example_data.adat = c(192L, 5318L),
                    single_sample.adat = c(1L, 5318L))
  )
})

# loadAdatsAsList() -----
test_that("throws warning when failure to load adat", {
  expect_message(
    bad <- loadAdatsAsList(c(files, "fail.adat")),
    "Failed to load: 'fail.adat'", fixed = TRUE
  )
  # failed file names are not returned
  expect_equal(bad, adats)

  # two invalid files
  expect_message(
    expect_message(
      bad2 <- loadAdatsAsList(c("a.adat", "b.adat")),
      "Failed to load: 'a.adat'", fixed = TRUE
    ),
    "Failed to load: 'b.adat'", fixed = TRUE
  )
  expect_named(bad2, character(0))
  expect_length(bad2, 0L)
})

test_that("collapse argument works same as collapseAdats(x)", {
  foo2 <- system.file("example", package = "SomaDataIO") |>
    list.files(pattern = "[.]adat$", full.names = TRUE) |>
    normalizePath() |>
    loadAdatsAsList(collapse = TRUE)
  expect_equal(foo2, foo)
})

test_that("collapsed ADATs dimensions are correct", {
  expect_equal(dim(foo), c(sum(vapply(adats, nrow, integer(1))),
                           length(intersect(names(adats[[1L]]),
                                            names(adats[[2L]])))
                           )
               )
  expect_s3_class(foo, "soma_adat")
})

test_that("collapsed ADATs attributes (HEADER) are correctly merged", {
  expect_type(atts, "list")
  expect_named(atts, c("names", "class", "row.names", "Header.Meta",
                       "Col.Meta", "file_specs", "row_meta"))
  expect_named(atts$Header.Meta,
               c("HEADER", "COL_DATA", "ROW_DATA", "TABLE_BEGIN"))
  HD <- atts$Header.Meta$HEADER
  expect_type(HD, "list")
  expect_length(HD, 49L)
  expect_equal(
    c(table(names(HD))),
    c("AdatId" = 2L,
      "AssayRobot" = 2L,
      "AssaySite" = 1L,
      "AssayType" = 2L,
      "AssayVersion" = 2L,
      "CalPlateTailPercent_Example_Adat_Set001" = 1L,
      "CalPlateTailPercent_Example_Adat_Set002" = 1L,
      "CalibrationReference" = 1L,
      "CalibratorId" = 1L,
      "CreatedBy" = 2L,
      "CreatedDate" = 2L,
      "EnteredBy" = 2L,
      "ExpDate" = 1L,
      "GeneratedBy" = 2L,
      "HybNormReference" = 1L,
      "LabLocation" = 1L,
      "Legal" = 2L,
      "MedNormReference" = 1L,
      "NormalizationAlgorithm" = 1L,
      "PlateScale_PassFlag_Example_Adat_Set001" = 1L,
      "PlateScale_PassFlag_Example_Adat_Set002" = 1L,
      "PlateScale_ReferenceSource" = 1L,
      "PlateScale_Scalar_Example_Adat_Set001" = 1L,
      "PlateScale_Scalar_Example_Adat_Set002" = 1L,
      "PlateTailPercent_Example_Adat_Set001" = 1L,
      "PlateTailPercent_Example_Adat_Set002" = 1L,
      "PlateTailTest_Example_Adat_Set001" = 1L,
      "PlateTailTest_Example_Adat_Set002" = 1L,
      "PlateType" = 1L,
      "ProcessSteps" = 1L,
      "ProteinEffectiveDate" = 1L,
      "ReportConfig" = 1L,
      "RunNotes" = 1L,
      "StudyMatrix" = 2L,
      "StudyOrganism" = 1L,
      "Title" = 2L,
      "Version" = 2L
    )
  )
})
