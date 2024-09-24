# adats list is named properly and has proper dimensions

    Code
      lapply(adats, dim)
    Output
      $example_data10.adat
      [1]   10 5318
      
      $single_sample.adat
      [1]    1 5318
      

# throws warning when failure to load adat

    Code
      bad <- loadAdatsAsList(c(files, "fail.adat"))
    Message
      x Failed to load: "fail.adat"

---

    Code
      bad2 <- loadAdatsAsList(c("a.adat", "b.adat"))
    Message
      x Failed to load: "a.adat"
      x Failed to load: "b.adat"

# collapsed ADATs attributes (HEADER) are correctly merged

    Code
      atts$Header.Meta$HEADER
    Output
      $AdatId
      [1] "GID-1234-56-789-abcdef"
      attr(,"raw_key")
      [1] "!AdatId"
      
      $Version
      [1] "1.2"
      attr(,"raw_key")
      [1] "!Version"
      
      $AssayType
      [1] "PharmaServices"
      attr(,"raw_key")
      [1] "!AssayType"
      
      $AssayVersion
      [1] "V4"
      attr(,"raw_key")
      [1] "!AssayVersion"
      
      $AssayRobot
      [1] "Fluent 1 L-307, Fluent 1 L-307"
      attr(,"raw_key")
      [1] "!AssayRobot"
      
      $Legal
      [1] "Experiment details and data have been processed to protect Personally Identifiable Information (PII) and comply with existing privacy laws."
      attr(,"raw_key")
      [1] "!Legal"
      
      $CreatedBy
      [1] "PharmaServices"
      attr(,"raw_key")
      [1] "!CreatedBy"
      
      $CreatedDate
      [1] "2020-07-24, 2020-07-25"
      attr(,"raw_key")
      [1] "!CreatedDate"
      
      $EnteredBy
      [1] "Technician1"
      attr(,"raw_key")
      [1] "!EnteredBy"
      
      $ExpDate
      [1] "2020-06-18, 2020-07-20"
      attr(,"raw_key")
      [1] "!ExpDate"
      
      $GeneratedBy
      [1] "Px (Build:  : ), Canopy_0.1.1"
      attr(,"raw_key")
      [1] "!GeneratedBy"
      
      $RunNotes
      [1] "2 columns ('Age' and 'Sex') have been added to this ADAT. Age has been randomly increased or decreased by 1-2 years to protect patient information"
      attr(,"raw_key")
      [1] "!RunNotes"
      
      $ProcessSteps
      [1] "Raw RFU, Hyb Normalization, medNormInt (SampleId), plateScale, Calibration, anmlQC, qcCheck, anmlSMP"
      attr(,"raw_key")
      [1] "!ProcessSteps"
      
      $ProteinEffectiveDate
      [1] "2019-08-06"
      attr(,"raw_key")
      [1] "!ProteinEffectiveDate"
      
      $StudyMatrix
      [1] "EDTA Plasma"
      attr(,"raw_key")
      [1] "!StudyMatrix"
      
      $PlateType
      character(0)
      attr(,"raw_key")
      [1] "!PlateType"
      
      $LabLocation
      [1] "SLUS"
      attr(,"raw_key")
      [1] "!LabLocation"
      
      $StudyOrganism
      character(0)
      attr(,"raw_key")
      [1] "!StudyOrganism"
      
      $Title
      [1] "Example Adat Set001, Example Adat Set002, Example Adat Set001, Example Adat Set002"
      attr(,"raw_key")
      [1] "!Title"
      
      $AssaySite
      [1] "SW"
      attr(,"raw_key")
      [1] "!AssaySite"
      
      $CalibratorId
      [1] "170261"
      attr(,"raw_key")
      [1] "!CalibratorId"
      
      $ReportConfig
      [1] "{\"analysisSteps\":[{\"stepType\":\"hybNorm\",\"referenceSource\":\"intraplate\",\"includeSampleTypes\":[\"QC\",\"Calibrator\",\"Buffer\"]},{\"stepName\":\"medNormInt\",\"stepType\":\"medNorm\",\"includeSampleTypes\":[\"Calibrator\",\"Buffer\"],\"referenceSource\":\"intraplate\",\"referenceFields\":[\"SampleId\"]},{\"stepType\":\"plateScale\",\"referenceSource\":\"Reference_v4_Plasma_Calibrator_170261\"},{\"stepType\":\"calibrate\",\"referenceSource\":\"Reference_v4_Plasma_Calibrator_170261\"},{\"stepName\":\"anmlQC\",\"stepType\":\"ANML\",\"effectSizeCutoff\":2.0,\"minFractionUsed\":0.3,\"includeSampleTypes\":[\"QC\"],\"referenceSource\":\"Reference_v4_Plasma_ANML\"},{\"stepType\":\"qcCheck\",\"QCReferenceSource\":\"Reference_v4_Plasma_QC_ANML_170255\",\"tailsCriteriaLower\":0.8,\"tailsCriteriaUpper\":1.2,\"tailThreshold\":15.0,\"QCAdditionalReferenceSources\":[\"Reference_v4_Plasma_QC_ANML_170259\",\"Reference_v4_Plasma_QC_ANML_170260\"],\"prenormalized\":true},{\"stepName\":\"anmlSMP\",\"stepType\":\"ANML\",\"effectSizeCutoff\":2.0,\"minFractionUsed\":0.3,\"includeSampleTypes\":[\"Sample\"],\"referenceSource\":\"Reference_v4_Plasma_ANML\"}],\"qualityReports\":[\"SQS Report\"],\"filter\":{\"proteinEffectiveDate\":\"2019-08-06\"}}"
      attr(,"raw_key")
      [1] "!ReportConfig"
      
      $HybNormReference
      [1] "intraplate"
      attr(,"raw_key")
      [1] "HybNormReference"
      
      $MedNormReference
      [1] "intraplate"
      attr(,"raw_key")
      [1] "MedNormReference"
      
      $NormalizationAlgorithm
      [1] "ANML"
      attr(,"raw_key")
      [1] "NormalizationAlgorithm"
      
      $PlateScale_ReferenceSource
      [1] "Reference_v4_Plasma_Calibrator_170261"
      attr(,"raw_key")
      [1] "PlateScale_ReferenceSource"
      
      $PlateScale_Scalar_Example_Adat_Set001
      [1] "1.08091554"
      attr(,"raw_key")
      [1] "PlateScale_Scalar_Example_Adat_Set001"
      
      $PlateScale_PassFlag_Example_Adat_Set001
      [1] "PASS"
      attr(,"raw_key")
      [1] "PlateScale_PassFlag_Example_Adat_Set001"
      
      $CalibrationReference
      [1] "Reference_v4_Plasma_Calibrator_170261"
      attr(,"raw_key")
      [1] "CalibrationReference"
      
      $CalPlateTailPercent_Example_Adat_Set001
      [1] "0.1"
      attr(,"raw_key")
      [1] "CalPlateTailPercent_Example_Adat_Set001"
      
      $PlateTailPercent_Example_Adat_Set001
      [1] "1.2"
      attr(,"raw_key")
      [1] "PlateTailPercent_Example_Adat_Set001"
      
      $PlateTailTest_Example_Adat_Set001
      [1] "PASS"
      attr(,"raw_key")
      [1] "PlateTailTest_Example_Adat_Set001"
      
      $PlateScale_Scalar_Example_Adat_Set002
      [1] "1.09915270"
      attr(,"raw_key")
      [1] "PlateScale_Scalar_Example_Adat_Set002"
      
      $PlateScale_PassFlag_Example_Adat_Set002
      [1] "PASS"
      attr(,"raw_key")
      [1] "PlateScale_PassFlag_Example_Adat_Set002"
      
      $CalPlateTailPercent_Example_Adat_Set002
      [1] "2.6"
      attr(,"raw_key")
      [1] "CalPlateTailPercent_Example_Adat_Set002"
      
      $PlateTailPercent_Example_Adat_Set002
      [1] "4.2"
      attr(,"raw_key")
      [1] "PlateTailPercent_Example_Adat_Set002"
      
      $PlateTailTest_Example_Adat_Set002
      [1] "PASS"
      attr(,"raw_key")
      [1] "PlateTailTest_Example_Adat_Set002"
      
      $CollapsedAdats
      [1] "example_data10.adat, single_sample.adat"
      

