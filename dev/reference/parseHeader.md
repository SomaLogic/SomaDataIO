# SomaLogic ADAT parser

Parses the header section of an ADAT file.

## Usage

``` r
parseHeader(file)
```

## Arguments

- file:

  Character. The elaborated path and file name of the `*.adat` file to
  be loaded into an R workspace environment.

## Value

A list of relevant file information required by
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md)
in order to complete loading the ADAT file, including:

- Header.Meta:

  list of notes and other information about the adat

- Col.Meta:

  list of vectors that contain the column meta data about individual
  analytes, includes information about the target name and calibration
  and QC ratios

- file_specs:

  list of values of the file parsing specifications

- row_meta:

  character vector of the clinical variables; assay information that is
  included in the adat output along with the RFU data

## See also

Other IO:
[`loadAdatsAsList()`](https://somalogic.github.io/SomaDataIO/dev/reference/loadAdatsAsList.md),
[`read_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/read_adat.md),
[`soma_adat`](https://somalogic.github.io/SomaDataIO/dev/reference/soma_adat.md),
[`write_adat()`](https://somalogic.github.io/SomaDataIO/dev/reference/write_adat.md)

## Author

Stu Field

## Examples

``` r
f <- system.file("extdata", "example_data10.adat",
                 package = "SomaDataIO", mustWork = TRUE)
header <- parseHeader(f)
names(header)
#> [1] "Header.Meta" "Col.Meta"    "file_specs"  "row_meta"   

header$Header.Meta
#> $HEADER
#> $HEADER$AdatId
#> [1] "GID-1234-56-789-abcdef"
#> attr(,"raw_key")
#> [1] "!AdatId"
#> 
#> $HEADER$Version
#> [1] "1.2"
#> attr(,"raw_key")
#> [1] "!Version"
#> 
#> $HEADER$AssayType
#> [1] "PharmaServices"
#> attr(,"raw_key")
#> [1] "!AssayType"
#> 
#> $HEADER$AssayVersion
#> [1] "V4"
#> attr(,"raw_key")
#> [1] "!AssayVersion"
#> 
#> $HEADER$AssayRobot
#> [1] "Fluent 1 L-307"
#> attr(,"raw_key")
#> [1] "!AssayRobot"
#> 
#> $HEADER$Legal
#> [1] "Experiment details and data have been processed to protect Personally Identifiable Information (PII) and comply with existing privacy laws."
#> attr(,"raw_key")
#> [1] "!Legal"
#> 
#> $HEADER$CreatedBy
#> [1] "PharmaServices"
#> attr(,"raw_key")
#> [1] "!CreatedBy"
#> 
#> $HEADER$CreatedDate
#> [1] "2020-07-24"
#> attr(,"raw_key")
#> [1] "!CreatedDate"
#> 
#> $HEADER$EnteredBy
#> [1] "Technician1"
#> attr(,"raw_key")
#> [1] "!EnteredBy"
#> 
#> $HEADER$ExpDate
#> [1] "2020-06-18, 2020-07-20"
#> attr(,"raw_key")
#> [1] "!ExpDate"
#> 
#> $HEADER$GeneratedBy
#> [1] "Px (Build:  : ), Canopy_0.1.1"
#> attr(,"raw_key")
#> [1] "!GeneratedBy"
#> 
#> $HEADER$RunNotes
#> [1] "2 columns ('Age' and 'Sex') have been added to this ADAT. Age has been randomly increased or decreased by 1-2 years to protect patient information"
#> attr(,"raw_key")
#> [1] "!RunNotes"
#> 
#> $HEADER$ProcessSteps
#> [1] "Raw RFU, Hyb Normalization, medNormInt (SampleId), plateScale, Calibration, anmlQC, qcCheck, anmlSMP"
#> attr(,"raw_key")
#> [1] "!ProcessSteps"
#> 
#> $HEADER$ProteinEffectiveDate
#> [1] "2019-08-06"
#> attr(,"raw_key")
#> [1] "!ProteinEffectiveDate"
#> 
#> $HEADER$StudyMatrix
#> [1] "EDTA Plasma"
#> attr(,"raw_key")
#> [1] "!StudyMatrix"
#> 
#> $HEADER$PlateType
#> character(0)
#> attr(,"raw_key")
#> [1] "!PlateType"
#> 
#> $HEADER$LabLocation
#> [1] "SLUS"
#> attr(,"raw_key")
#> [1] "!LabLocation"
#> 
#> $HEADER$StudyOrganism
#> character(0)
#> attr(,"raw_key")
#> [1] "!StudyOrganism"
#> 
#> $HEADER$Title
#> [1] "Example Adat Set001, Example Adat Set002"
#> attr(,"raw_key")
#> [1] "!Title"
#> 
#> $HEADER$AssaySite
#> [1] "SW"
#> attr(,"raw_key")
#> [1] "!AssaySite"
#> 
#> $HEADER$CalibratorId
#> [1] "170261"
#> attr(,"raw_key")
#> [1] "!CalibratorId"
#> 
#> $HEADER$ReportConfig
#> [1] "{\"analysisSteps\":[{\"stepType\":\"hybNorm\",\"referenceSource\":\"intraplate\",\"includeSampleTypes\":[\"QC\",\"Calibrator\",\"Buffer\"]},{\"stepName\":\"medNormInt\",\"stepType\":\"medNorm\",\"includeSampleTypes\":[\"Calibrator\",\"Buffer\"],\"referenceSource\":\"intraplate\",\"referenceFields\":[\"SampleId\"]},{\"stepType\":\"plateScale\",\"referenceSource\":\"Reference_v4_Plasma_Calibrator_170261\"},{\"stepType\":\"calibrate\",\"referenceSource\":\"Reference_v4_Plasma_Calibrator_170261\"},{\"stepName\":\"anmlQC\",\"stepType\":\"ANML\",\"effectSizeCutoff\":2.0,\"minFractionUsed\":0.3,\"includeSampleTypes\":[\"QC\"],\"referenceSource\":\"Reference_v4_Plasma_ANML\"},{\"stepType\":\"qcCheck\",\"QCReferenceSource\":\"Reference_v4_Plasma_QC_ANML_170255\",\"tailsCriteriaLower\":0.8,\"tailsCriteriaUpper\":1.2,\"tailThreshold\":15.0,\"QCAdditionalReferenceSources\":[\"Reference_v4_Plasma_QC_ANML_170259\",\"Reference_v4_Plasma_QC_ANML_170260\"],\"prenormalized\":true},{\"stepName\":\"anmlSMP\",\"stepType\":\"ANML\",\"effectSizeCutoff\":2.0,\"minFractionUsed\":0.3,\"includeSampleTypes\":[\"Sample\"],\"referenceSource\":\"Reference_v4_Plasma_ANML\"}],\"qualityReports\":[\"SQS Report\"],\"filter\":{\"proteinEffectiveDate\":\"2019-08-06\"}}"
#> attr(,"raw_key")
#> [1] "!ReportConfig"
#> 
#> $HEADER$HybNormReference
#> [1] "intraplate"
#> attr(,"raw_key")
#> [1] "HybNormReference"
#> 
#> $HEADER$MedNormReference
#> [1] "intraplate"
#> attr(,"raw_key")
#> [1] "MedNormReference"
#> 
#> $HEADER$NormalizationAlgorithm
#> [1] "ANML"
#> attr(,"raw_key")
#> [1] "NormalizationAlgorithm"
#> 
#> $HEADER$PlateScale_ReferenceSource
#> [1] "Reference_v4_Plasma_Calibrator_170261"
#> attr(,"raw_key")
#> [1] "PlateScale_ReferenceSource"
#> 
#> $HEADER$PlateScale_Scalar_Example_Adat_Set001
#> [1] "1.08091554"
#> attr(,"raw_key")
#> [1] "PlateScale_Scalar_Example_Adat_Set001"
#> 
#> $HEADER$PlateScale_PassFlag_Example_Adat_Set001
#> [1] "PASS"
#> attr(,"raw_key")
#> [1] "PlateScale_PassFlag_Example_Adat_Set001"
#> 
#> $HEADER$CalibrationReference
#> [1] "Reference_v4_Plasma_Calibrator_170261"
#> attr(,"raw_key")
#> [1] "CalibrationReference"
#> 
#> $HEADER$CalPlateTailPercent_Example_Adat_Set001
#> [1] "0.1"
#> attr(,"raw_key")
#> [1] "CalPlateTailPercent_Example_Adat_Set001"
#> 
#> $HEADER$PlateTailPercent_Example_Adat_Set001
#> [1] "1.2"
#> attr(,"raw_key")
#> [1] "PlateTailPercent_Example_Adat_Set001"
#> 
#> $HEADER$PlateTailTest_Example_Adat_Set001
#> [1] "PASS"
#> attr(,"raw_key")
#> [1] "PlateTailTest_Example_Adat_Set001"
#> 
#> $HEADER$PlateScale_Scalar_Example_Adat_Set002
#> [1] "1.09915270"
#> attr(,"raw_key")
#> [1] "PlateScale_Scalar_Example_Adat_Set002"
#> 
#> $HEADER$PlateScale_PassFlag_Example_Adat_Set002
#> [1] "PASS"
#> attr(,"raw_key")
#> [1] "PlateScale_PassFlag_Example_Adat_Set002"
#> 
#> $HEADER$CalPlateTailPercent_Example_Adat_Set002
#> [1] "2.6"
#> attr(,"raw_key")
#> [1] "CalPlateTailPercent_Example_Adat_Set002"
#> 
#> $HEADER$PlateTailPercent_Example_Adat_Set002
#> [1] "4.2"
#> attr(,"raw_key")
#> [1] "PlateTailPercent_Example_Adat_Set002"
#> 
#> $HEADER$PlateTailTest_Example_Adat_Set002
#> [1] "PASS"
#> attr(,"raw_key")
#> [1] "PlateTailTest_Example_Adat_Set002"
#> 
#> 
#> $COL_DATA
#> $COL_DATA$Name
#>  [1] "SeqId"                                
#>  [2] "SeqIdVersion"                         
#>  [3] "SomaId"                               
#>  [4] "TargetFullName"                       
#>  [5] "Target"                               
#>  [6] "UniProt"                              
#>  [7] "EntrezGeneID"                         
#>  [8] "EntrezGeneSymbol"                     
#>  [9] "Organism"                             
#> [10] "Units"                                
#> [11] "Type"                                 
#> [12] "Dilution"                             
#> [13] "PlateScale_Reference"                 
#> [14] "CalReference"                         
#> [15] "Cal_Example_Adat_Set001"              
#> [16] "ColCheck"                             
#> [17] "CalQcRatio_Example_Adat_Set001_170255"
#> [18] "QcReference_170255"                   
#> [19] "Cal_Example_Adat_Set002"              
#> [20] "CalQcRatio_Example_Adat_Set002_170255"
#> attr(,"raw_key")
#> [1] "!Name"
#> 
#> $COL_DATA$Type
#>  [1] "String" "String" "String" "String" "String" "String" "String"
#>  [8] "String" "String" "String" "String" "String" "String" "String"
#> [15] "String" "String" "String" "String" "String" "String"
#> attr(,"raw_key")
#> [1] "!Type"
#> 
#> 
#> $ROW_DATA
#> $ROW_DATA$Name
#>  [1] "PlateId"                "PlateRunDate"          
#>  [3] "ScannerID"              "PlatePosition"         
#>  [5] "SlideId"                "Subarray"              
#>  [7] "SampleId"               "SampleType"            
#>  [9] "PercentDilution"        "SampleMatrix"          
#> [11] "Barcode"                "Barcode2d"             
#> [13] "SampleName"             "SampleNotes"           
#> [15] "AliquotingNotes"        "SampleDescription"     
#> [17] "AssayNotes"             "TimePoint"             
#> [19] "ExtIdentifier"          "SsfExtId"              
#> [21] "SampleGroup"            "SiteId"                
#> [23] "TubeUniqueID"           "CLI"                   
#> [25] "HybControlNormScale"    "RowCheck"              
#> [27] "NormScale_20"           "NormScale_0_005"       
#> [29] "NormScale_0_5"          "ANMLFractionUsed_20"   
#> [31] "ANMLFractionUsed_0_005" "ANMLFractionUsed_0_5"  
#> [33] "Age"                    "Sex"                   
#> attr(,"raw_key")
#> [1] "!Name"
#> 
#> $ROW_DATA$Type
#>  [1] "String" "String" "String" "String" "String" "String" "String"
#>  [8] "String" "String" "String" "String" "String" "String" "String"
#> [15] "String" "String" "String" "String" "String" "String" "String"
#> [22] "String" "String" "String" "String" "String" "String" "String"
#> [29] "String" "String" "String" "String" "String" "String"
#> attr(,"raw_key")
#> [1] "!Type"
#> 
#> 
#> $TABLE_BEGIN
#> [1] "example_data10.adat"
#> 

header$file_specs
#> $empty_adat
#> [1] FALSE
#> 
#> $table_begin
#> [1] 45
#> 
#> $col_meta_start
#> [1] 46
#> 
#> $col_meta_shift
#> [1] 35
#> 
#> $data_begin
#> [1] 66
#> 
#> $old_adat
#> [1] FALSE
#> 

header$row_meta
#>  [1] "PlateId"                "PlateRunDate"          
#>  [3] "ScannerID"              "PlatePosition"         
#>  [5] "SlideId"                "Subarray"              
#>  [7] "SampleId"               "SampleType"            
#>  [9] "PercentDilution"        "SampleMatrix"          
#> [11] "Barcode"                "Barcode2d"             
#> [13] "SampleName"             "SampleNotes"           
#> [15] "AliquotingNotes"        "SampleDescription"     
#> [17] "AssayNotes"             "TimePoint"             
#> [19] "ExtIdentifier"          "SsfExtId"              
#> [21] "SampleGroup"            "SiteId"                
#> [23] "TubeUniqueID"           "CLI"                   
#> [25] "HybControlNormScale"    "RowCheck"              
#> [27] "NormScale_20"           "NormScale_0_005"       
#> [29] "NormScale_0_5"          "ANMLFractionUsed_20"   
#> [31] "ANMLFractionUsed_0_005" "ANMLFractionUsed_0_5"  
#> [33] "Age"                    "Sex"                   

head(as.data.frame(header$Col.Meta))
#>      SeqId SeqIdVersion   SomaId
#> 1 10000-28            3 SL019233
#> 2  10001-7            3 SL002564
#> 3 10003-15            3 SL019245
#> 4 10006-25            3 SL019228
#> 5 10008-43            3 SL019234
#> 6 10011-65            3 SL019246
#>                                       TargetFullName Target UniProt
#> 1                                 Beta-crystallin B2  CRBB2  P43320
#> 2 RAF proto-oncogene serine/threonine-protein kinase  c-Raf  P04049
#> 3                             Zinc finger protein 41  ZNF41  P51814
#> 4                ETS domain-containing protein Elk-1   ELK1  P19419
#> 5              Guanylyl cyclase-activating protein 1  GUC1A  P43080
#> 6        Inositol polyphosphate 5-phosphatase OCRL-1   OCRL  Q01968
#>   EntrezGeneID EntrezGeneSymbol Organism Units    Type Dilution
#> 1         1415           CRYBB2    Human   RFU Protein       20
#> 2         5894             RAF1    Human   RFU Protein       20
#> 3         7592            ZNF41    Human   RFU Protein      0.5
#> 4         2002             ELK1    Human   RFU Protein       20
#> 5         2978           GUCA1A    Human   RFU Protein       20
#> 6         4952             OCRL    Human   RFU Protein       20
#>   PlateScale_Reference CalReference Cal_Example_Adat_Set001 ColCheck
#> 1                687.4        687.4              1.01252025     PASS
#> 2                227.8        227.8              1.01605709     PASS
#> 3                126.9        126.9              0.95056180     PASS
#> 4                634.2        634.2              0.99607350     PASS
#> 5                585.0        585.0              0.94051447     PASS
#> 6               2807.1       2807.1              1.05383489     PASS
#>   CalQcRatio_Example_Adat_Set001_170255 QcReference_170255
#> 1                                 1.008              505.4
#> 2                                 0.970              223.9
#> 3                                 1.046              119.6
#> 4                                 1.042              667.2
#> 5                                 1.036              587.5
#> 6                                 0.975             2617.6
#>   Cal_Example_Adat_Set002 CalQcRatio_Example_Adat_Set002_170255
#> 1              1.01476233                                 1.067
#> 2              1.03686846                                 1.007
#> 3              1.15258856                                 0.981
#> 4              0.93581231                                 1.026
#> 5              0.96201283                                 0.998
#> 6              1.03133955                                 1.013
```
