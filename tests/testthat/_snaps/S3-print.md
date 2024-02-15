# `soma_adat` S3 print method returns known output

    == SomaScan Data ===============================================================
         SomaScan version     V4 (5k)
         Signal Space         5k
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
       row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId Subarray
       <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>    <dbl>
     1 258495800012_3 Example~ 2020-06-18   SG152144~ H9            2.58e11        3
     2 258495800004_7 Example~ 2020-06-18   SG152144~ H8            2.58e11        7
     3 258495800010_8 Example~ 2020-06-18   SG152144~ H7            2.58e11        8
     4 258495800003_4 Example~ 2020-06-18   SG152144~ H6            2.58e11        4
     5 258495800009_4 Example~ 2020-06-18   SG152144~ H5            2.58e11        4
     6 258495800012_8 Example~ 2020-06-18   SG152144~ H4            2.58e11        8
     7 258495800001_3 Example~ 2020-06-18   SG152144~ H3            2.58e11        3
     8 258495800004_8 Example~ 2020-06-18   SG152144~ H2            2.58e11        8
     9 258495800001_8 Example~ 2020-06-18   SG152144~ H12           2.58e11        8
    10 258495800004_3 Example~ 2020-06-18   SG152144~ H11           2.58e11        3
    # i 182 more rows
    # i 5,312 more variables: SampleId <chr>, SampleType <chr>,
    #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
    #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
    #   SampleDescription <chr>, ...
    ================================================================================

---

    == SomaScan Data ===============================================================
         SomaScan version     V4 (5k)
         Signal Space         5k
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
      row_names      PlateId   PlateRunDate ScannerID PlatePosition SlideId Subarray
      <chr>          <chr>     <chr>        <chr>     <chr>           <dbl>    <dbl>
    1 258495800012_3 Example ~ 2020-06-18   SG152144~ H9            2.58e11        3
    2 258495800004_7 Example ~ 2020-06-18   SG152144~ H8            2.58e11        7
    3 258495800010_8 Example ~ 2020-06-18   SG152144~ H7            2.58e11        8
    4 258495800003_4 Example ~ 2020-06-18   SG152144~ H6            2.58e11        4
    5 258495800009_4 Example ~ 2020-06-18   SG152144~ H5            2.58e11        4
    6 258495800012_8 Example ~ 2020-06-18   SG152144~ H4            2.58e11        8
    # i 5,312 more variables: SampleId <chr>, SampleType <chr>,
    #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
    #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
    #   SampleDescription <chr>, ...
    ================================================================================

---

    == SomaScan Data ===============================================================
         SomaScan version     V4 (5k)
         Signal Space         5k
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
    # i 20 more rows
    ================================================================================

---

    == SomaScan Data ===============================================================
         SomaScan version     V4 (5k)
         Signal Space         5k
         Attributes intact    v
         Rows                 192
         Columns              5318
         Clinical Data        34
         Features             5284
         Groups               SampleType [4]
    -- Column Meta -----------------------------------------------------------------
    i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
    i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
    i CalReference, Cal_Example_Adat_Set001, ColCheck,
    i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
    i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
    -- Tibble ----------------------------------------------------------------------
    # A tibble: 192 x 5,318
       PlateId        PlateRunDate ScannerID PlatePosition SlideId Subarray SampleId
       <chr>          <chr>        <chr>     <chr>           <dbl>    <dbl> <chr>   
     1 Example Adat ~ 2020-06-18   SG152144~ H9            2.58e11        3 1       
     2 Example Adat ~ 2020-06-18   SG152144~ H8            2.58e11        7 2       
     3 Example Adat ~ 2020-06-18   SG152144~ H7            2.58e11        8 3       
     4 Example Adat ~ 2020-06-18   SG152144~ H6            2.58e11        4 4       
     5 Example Adat ~ 2020-06-18   SG152144~ H5            2.58e11        4 5       
     6 Example Adat ~ 2020-06-18   SG152144~ H4            2.58e11        8 6       
     7 Example Adat ~ 2020-06-18   SG152144~ H3            2.58e11        3 7       
     8 Example Adat ~ 2020-06-18   SG152144~ H2            2.58e11        8 8       
     9 Example Adat ~ 2020-06-18   SG152144~ H12           2.58e11        8 9       
    10 Example Adat ~ 2020-06-18   SG152144~ H11           2.58e11        3 170261  
    # i 182 more rows
    # i 5,311 more variables: SampleType <chr>, PercentDilution <int>,
    #   SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>, SampleName <lgl>,
    #   SampleNotes <lgl>, AliquotingNotes <lgl>, SampleDescription <chr>,
    #   AssayNotes <lgl>, ...
    ================================================================================

---

    == SomaScan Data ===============================================================
         SomaScan version     unknown (NA)
         Signal Space         NA
         Attributes intact    x
         Rows                 192
         Columns              5318
         Clinical Data        34
         Features             5284
    -- Header Data -----------------------------------------------------------------
         No Header.Meta       ! ADAT columns were probably modified !
    -- Tibble ----------------------------------------------------------------------
    # A tibble: 192 x 5,319
       row_names      PlateId  PlateRunDate ScannerID PlatePosition SlideId Subarray
       <chr>          <chr>    <chr>        <chr>     <chr>           <dbl>    <dbl>
     1 258495800012_3 Example~ 2020-06-18   SG152144~ H9            2.58e11        3
     2 258495800004_7 Example~ 2020-06-18   SG152144~ H8            2.58e11        7
     3 258495800010_8 Example~ 2020-06-18   SG152144~ H7            2.58e11        8
     4 258495800003_4 Example~ 2020-06-18   SG152144~ H6            2.58e11        4
     5 258495800009_4 Example~ 2020-06-18   SG152144~ H5            2.58e11        4
     6 258495800012_8 Example~ 2020-06-18   SG152144~ H4            2.58e11        8
     7 258495800001_3 Example~ 2020-06-18   SG152144~ H3            2.58e11        3
     8 258495800004_8 Example~ 2020-06-18   SG152144~ H2            2.58e11        8
     9 258495800001_8 Example~ 2020-06-18   SG152144~ H12           2.58e11        8
    10 258495800004_3 Example~ 2020-06-18   SG152144~ H11           2.58e11        3
    # i 182 more rows
    # i 5,312 more variables: SampleId <chr>, SampleType <chr>,
    #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
    #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
    #   SampleDescription <chr>, ...
    ================================================================================

