# `parseCheck()` prints expected output

    Code
      specs
    Output
       [1] "== Parsing Specs ==============================================================="                                                                  
       [2] "• Table Begin               '45'"                                                                                                                  
       [3] "• Col.Meta Start            '46'"                                                                                                                  
       [4] "• Col.Meta Shift            '35'"                                                                                                                  
       [5] "• Header Row                '66'"                                                                                                                  
       [6] "• Rows of the Col Meta      '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65'"
       [7] "-- Col Meta -------------------------------------------------------------- 20 --"                                                                  
       [8] "i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,"                                                                     
       [9] "i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,"                                                                        
      [10] "i CalReference, Cal_Example_Adat_Set001, ColCheck,"                                                                                                
      [11] "i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,"                                                                                      
      [12] "i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255"                                                                                  
      [13] "-- Row Meta -------------------------------------------------------------- 34 --"                                                                  
      [14] "i PlateId, PlateRunDate, ScannerID, PlatePosition, SlideId, Subarray, SampleId,"                                                                   
      [15] "i SampleType, PercentDilution, SampleMatrix, Barcode, Barcode2d, SampleName,"                                                                      
      [16] "i SampleNotes, AliquotingNotes, SampleDescription, AssayNotes, TimePoint,"                                                                         
      [17] "i ExtIdentifier, SsfExtId, SampleGroup, SiteId, TubeUniqueID, CLI,"                                                                                
      [18] "i HybControlNormScale, RowCheck, NormScale_20, NormScale_0_005, NormScale_0_5,"                                                                    
      [19] "i ANMLFractionUsed_20, ANMLFractionUsed_0_005, ANMLFractionUsed_0_5, Age, Sex"                                                                     
      [20] "-- Empty Strings Detected in Col.Meta ------------------------------------- ! --"                                                                  
      [21] "i They may be missing in: [1] \"'Spuriomers', 'HybControls'\""                                                                                     
      [22] "== Parse Diagnostic Complete ==================================================="                                                                  

