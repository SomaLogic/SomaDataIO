# `parseHeader()` correctly parses header information of an ADAT

    Code
      header
    Output
      $Header.Meta
      $Header.Meta$HEADER
      $Header.Meta$HEADER$AdatId
      [1] "GID-1234-56-7890-abcdef"
      attr(,"raw_key")
      [1] "!AdatId"
      
      $Header.Meta$HEADER$Version
      [1] "1.2"
      attr(,"raw_key")
      [1] "!Version"
      
      $Header.Meta$HEADER$AssayType
      [1] "PharmaServices"
      attr(,"raw_key")
      [1] "!AssayType"
      
      $Header.Meta$HEADER$AssayVersion
      [1] "V4"
      attr(,"raw_key")
      [1] "!AssayVersion"
      
      $Header.Meta$HEADER$AssayRobot
      [1] "Fluent 1 L-307"
      attr(,"raw_key")
      [1] "!AssayRobot"
      
      $Header.Meta$HEADER$Legal
      [1] "Experiment details and data have been processed to protect Personally Identifiable Information (PII) and comply with existing privacy laws."
      attr(,"raw_key")
      [1] "!Legal"
      
      $Header.Meta$HEADER$CreatedBy
      [1] "PharmaServices"
      attr(,"raw_key")
      [1] "!CreatedBy"
      
      $Header.Meta$HEADER$CreatedDate
      [1] "2020-07-25"
      attr(,"raw_key")
      [1] "!CreatedDate"
      
      $Header.Meta$HEADER$EnteredBy
      [1] "Technician2"
      attr(,"raw_key")
      [1] "!EnteredBy"
      
      $Header.Meta$HEADER$GeneratedBy
      [1] "Px (Build:  : ), Canopy_0.1.1"
      attr(,"raw_key")
      [1] "!GeneratedBy"
      
      $Header.Meta$HEADER$StudyMatrix
      [1] "EDTA Plasma"
      attr(,"raw_key")
      [1] "!StudyMatrix"
      
      $Header.Meta$HEADER$Title
      [1] "Example Adat Set001, Example Adat Set002"
      attr(,"raw_key")
      [1] "!Title"
      
      
      $Header.Meta$COL_DATA
      $Header.Meta$COL_DATA$Name
       [1] "SeqId"                                
       [2] "SeqIdVersion"                         
       [3] "SomaId"                               
       [4] "TargetFullName"                       
       [5] "Target"                               
       [6] "UniProt"                              
       [7] "EntrezGeneID"                         
       [8] "EntrezGeneSymbol"                     
       [9] "Organism"                             
      [10] "Units"                                
      [11] "Type"                                 
      [12] "Dilution"                             
      [13] "PlateScale_Reference"                 
      [14] "CalReference"                         
      [15] "Cal_Example_Adat_Set001"              
      [16] "ColCheck"                             
      [17] "CalQcRatio_Example_Adat_Set001_170255"
      [18] "QcReference_170255"                   
      [19] "Cal_Example_Adat_Set002"              
      [20] "CalQcRatio_Example_Adat_Set002_170255"
      attr(,"raw_key")
      [1] "!Name"
      
      $Header.Meta$COL_DATA$Type
       [1] "String" "String" "String" "String" "String" "String" "String" "String"
       [9] "String" "String" "String" "String" "String" "String" "String" "String"
      [17] "String" "String" "String" "String"
      attr(,"raw_key")
      [1] "!Type"
      
      
      $Header.Meta$ROW_DATA
      $Header.Meta$ROW_DATA$Name
       [1] "PlateId"                "PlateRunDate"           "ScannerID"             
       [4] "PlatePosition"          "SlideId"                "Subarray"              
       [7] "SampleId"               "SampleType"             "PercentDilution"       
      [10] "SampleMatrix"           "Barcode"                "Barcode2d"             
      [13] "SampleName"             "SampleNotes"            "AliquotingNotes"       
      [16] "SampleDescription"      "AssayNotes"             "TimePoint"             
      [19] "ExtIdentifier"          "SsfExtId"               "SampleGroup"           
      [22] "SiteId"                 "TubeUniqueID"           "CLI"                   
      [25] "HybControlNormScale"    "RowCheck"               "NormScale_20"          
      [28] "NormScale_0_005"        "NormScale_0_5"          "ANMLFractionUsed_20"   
      [31] "ANMLFractionUsed_0_005" "ANMLFractionUsed_0_5"   "Age"                   
      [34] "Sex"                   
      attr(,"raw_key")
      [1] "!Name"
      
      $Header.Meta$ROW_DATA$Type
       [1] "character" "character" "character" "character" "double"    "double"   
       [7] "character" "character" "integer"   "character" "logical"   "character"
      [13] "logical"   "logical"   "logical"   "logical"   "logical"   "logical"  
      [19] "logical"   "logical"   "logical"   "logical"   "logical"   "logical"  
      [25] "double"    "character" "double"    "double"    "double"    "double"   
      [31] "double"    "double"    "integer"   "character"
      attr(,"raw_key")
      [1] "!Type"
      
      
      $Header.Meta$TABLE_BEGIN
      [1] "single_sample.adat"
      
      
      $file_specs
      $file_specs$empty_adat
      [1] FALSE
      
      $file_specs$table_begin
      [1] 20
      
      $file_specs$col_meta_start
      [1] 21
      
      $file_specs$col_meta_shift
      [1] 35
      
      $file_specs$data_begin
      [1] 41
      
      $file_specs$old_adat
      [1] FALSE
      
      
      $row_meta
       [1] "PlateId"                "PlateRunDate"           "ScannerID"             
       [4] "PlatePosition"          "SlideId"                "Subarray"              
       [7] "SampleId"               "SampleType"             "PercentDilution"       
      [10] "SampleMatrix"           "Barcode"                "Barcode2d"             
      [13] "SampleName"             "SampleNotes"            "AliquotingNotes"       
      [16] "SampleDescription"      "AssayNotes"             "TimePoint"             
      [19] "ExtIdentifier"          "SsfExtId"               "SampleGroup"           
      [22] "SiteId"                 "TubeUniqueID"           "CLI"                   
      [25] "HybControlNormScale"    "RowCheck"               "NormScale_20"          
      [28] "NormScale_0_005"        "NormScale_0_5"          "ANMLFractionUsed_20"   
      [31] "ANMLFractionUsed_0_005" "ANMLFractionUsed_0_5"   "Age"                   
      [34] "Sex"                   
      

