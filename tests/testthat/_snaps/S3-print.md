# `soma_adat` S3 print method returns known output

    == SomaScan Data ===============================================================
         Attributes intact    v
         Rows                 192
         Columns              5318
         Clinical Data        34
         Features             5284
    -- Column Meta -----------------------------------------------------------------
    i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
    i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
    i CalReference, Cal_Example_Adat_Set001, ColCheck,
    i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
    i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
    -- Tibble ----------------------------------------------------------------------
    # A tibble: 192 x 5,319
       row_names     PlateId Plate~1 Scann~2 Plate~3 SlideId Subar~4 Sampl~5 Sampl~6
       <chr>         <chr>   <chr>   <chr>   <chr>     <dbl>   <dbl> <chr>   <chr>  
     1 258495800012~ Exampl~ 2020-0~ SG1521~ H9      2.58e11       3 1       Sample 
     2 258495800004~ Exampl~ 2020-0~ SG1521~ H8      2.58e11       7 2       Sample 
     3 258495800010~ Exampl~ 2020-0~ SG1521~ H7      2.58e11       8 3       Sample 
     4 258495800003~ Exampl~ 2020-0~ SG1521~ H6      2.58e11       4 4       Sample 
     5 258495800009~ Exampl~ 2020-0~ SG1521~ H5      2.58e11       4 5       Sample 
     6 258495800012~ Exampl~ 2020-0~ SG1521~ H4      2.58e11       8 6       Sample 
     7 258495800001~ Exampl~ 2020-0~ SG1521~ H3      2.58e11       3 7       Sample 
     8 258495800004~ Exampl~ 2020-0~ SG1521~ H2      2.58e11       8 8       Sample 
     9 258495800001~ Exampl~ 2020-0~ SG1521~ H12     2.58e11       8 9       Sample 
    10 258495800004~ Exampl~ 2020-0~ SG1521~ H11     2.58e11       3 170261  Calibr~
    # ... with 182 more rows, 5,310 more variables: PercentDilution <int>,
    #   SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
    #   SampleNotes <lgl>, AliquotingNotes <lgl>, SampleDescription <chr>,
    #   AssayNotes <lgl>, TimePoint <lgl>, ..., and abbreviated variable names
    #   1: PlateRunDate, 2: ScannerID, 3: PlatePosition, 4: Subarray, 5: SampleId,
    #   6: SampleType
    ================================================================================

---

    == SomaScan Data ===============================================================
         Attributes intact    v
         Rows                 6
         Columns              5318
         Clinical Data        34
         Features             5284
    -- Column Meta -----------------------------------------------------------------
    i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
    i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
    i CalReference, Cal_Example_Adat_Set001, ColCheck,
    i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
    i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
    -- Tibble ----------------------------------------------------------------------
    # A tibble: 6 x 5,319
      row_names      PlateId Plate~1 Scann~2 Plate~3 SlideId Subar~4 Sampl~5 Sampl~6
      <chr>          <chr>   <chr>   <chr>   <chr>     <dbl>   <dbl> <chr>   <chr>  
    1 258495800012_3 Exampl~ 2020-0~ SG1521~ H9      2.58e11       3 1       Sample 
    2 258495800004_7 Exampl~ 2020-0~ SG1521~ H8      2.58e11       7 2       Sample 
    3 258495800010_8 Exampl~ 2020-0~ SG1521~ H7      2.58e11       8 3       Sample 
    4 258495800003_4 Exampl~ 2020-0~ SG1521~ H6      2.58e11       4 4       Sample 
    5 258495800009_4 Exampl~ 2020-0~ SG1521~ H5      2.58e11       4 5       Sample 
    6 258495800012_8 Exampl~ 2020-0~ SG1521~ H4      2.58e11       8 6       Sample 
    # ... with 5,310 more variables: PercentDilution <int>, SampleMatrix <chr>,
    #   Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>, SampleNotes <lgl>,
    #   AliquotingNotes <lgl>, SampleDescription <chr>, AssayNotes <lgl>,
    #   TimePoint <lgl>, ..., and abbreviated variable names 1: PlateRunDate,
    #   2: ScannerID, 3: PlatePosition, 4: Subarray, 5: SampleId, 6: SampleType
    ================================================================================

---

    == SomaScan Data ===============================================================
         Attributes intact    v
         Rows                 192
         Columns              5318
         Clinical Data        34
         Features             5284
    -- Column Meta -----------------------------------------------------------------
    i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
    i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
    i CalReference, Cal_Example_Adat_Set001, ColCheck,
    i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
    i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
    -- Header Data -----------------------------------------------------------------
    # A tibble: 35 x 2
       Key                  Value                                                   
       <chr>                <chr>                                                   
     1 AdatId               GID-1234-56-789-abcdef                                  
     2 Version              1.2                                                     
     3 AssayType            PharmaServices                                          
     4 AssayVersion         V4                                                      
     5 AssayRobot           Fluent 1 L-307                                          
     6 Legal                Experiment details and data have been processed to prot~
     7 CreatedBy            PharmaServices                                          
     8 CreatedDate          2020-07-24                                              
     9 EnteredBy            Technician1                                             
    10 ExpDate              2020-06-18, 2020-07-20                                  
    11 GeneratedBy          Px (Build:  : ), Canopy_0.1.1                           
    12 RunNotes             2 columns ('Age' and 'Sex') have been added to this ADA~
    13 ProcessSteps         Raw RFU, Hyb Normalization, medNormInt (SampleId), plat~
    14 ProteinEffectiveDate 2019-08-06                                              
    15 StudyMatrix          EDTA Plasma                                             
    # ... with 20 more rows
    ================================================================================

---

    == SomaScan Data ===============================================================
         Attributes intact    x
         Rows                 192
         Columns              5318
         Clinical Data        34
         Features             5284
    -- Header Data -----------------------------------------------------------------
         No Header.Meta       ! ADAT columns were probably modified !
    -- Tibble ----------------------------------------------------------------------
    # A tibble: 192 x 5,319
       row_names     PlateId Plate~1 Scann~2 Plate~3 SlideId Subar~4 Sampl~5 Sampl~6
       <chr>         <chr>   <chr>   <chr>   <chr>     <dbl>   <dbl> <chr>   <chr>  
     1 258495800012~ Exampl~ 2020-0~ SG1521~ H9      2.58e11       3 1       Sample 
     2 258495800004~ Exampl~ 2020-0~ SG1521~ H8      2.58e11       7 2       Sample 
     3 258495800010~ Exampl~ 2020-0~ SG1521~ H7      2.58e11       8 3       Sample 
     4 258495800003~ Exampl~ 2020-0~ SG1521~ H6      2.58e11       4 4       Sample 
     5 258495800009~ Exampl~ 2020-0~ SG1521~ H5      2.58e11       4 5       Sample 
     6 258495800012~ Exampl~ 2020-0~ SG1521~ H4      2.58e11       8 6       Sample 
     7 258495800001~ Exampl~ 2020-0~ SG1521~ H3      2.58e11       3 7       Sample 
     8 258495800004~ Exampl~ 2020-0~ SG1521~ H2      2.58e11       8 8       Sample 
     9 258495800001~ Exampl~ 2020-0~ SG1521~ H12     2.58e11       8 9       Sample 
    10 258495800004~ Exampl~ 2020-0~ SG1521~ H11     2.58e11       3 170261  Calibr~
    # ... with 182 more rows, 5,310 more variables: PercentDilution <int>,
    #   SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
    #   SampleNotes <lgl>, AliquotingNotes <lgl>, SampleDescription <chr>,
    #   AssayNotes <lgl>, TimePoint <lgl>, ..., and abbreviated variable names
    #   1: PlateRunDate, 2: ScannerID, 3: PlatePosition, 4: Subarray, 5: SampleId,
    #   6: SampleType
    ================================================================================

