# `preProcessAdat` applies default arguments as expected

    Code
      preProcessAdat(example_data)
    Message
      v 305 non-human protein features were removed.
      > 214 human proteins did not pass standard QC
      acceptance criteria and were flagged in `ColCheck`.  These features
      were not removed, as they still may yield useful information in an
      analysis, but further evaluation may be needed.
      v 6 buffer samples were removed.
      v 10 calibrator samples were removed.
      v 6 QC samples were removed.
      v 2 samples flagged in `RowCheck` did not
      pass standard normalization acceptance criteria (0.4 <= x <= 2.5)
      and were removed.
    Output
      == SomaScan Data ===============================================================
           SomaScan version     V4 (5k)
           Signal Space         5k
           Attributes intact    v
           Rows                 168
           Columns              5013
           Clinical Data        34
           Features             4979
      -- Column Meta -----------------------------------------------------------------
      i SeqId, SeqIdVersion, SomaId, TargetFullName, Target, UniProt, EntrezGeneID,
      i EntrezGeneSymbol, Organism, Units, Type, Dilution, PlateScale_Reference,
      i CalReference, Cal_Example_Adat_Set001, ColCheck,
      i CalQcRatio_Example_Adat_Set001_170255, QcReference_170255,
      i Cal_Example_Adat_Set002, CalQcRatio_Example_Adat_Set002_170255, Dilution2
      -- Tibble ----------------------------------------------------------------------
      # A tibble: 168 x 5,014
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
      10 258495800009_8 Example~ 2020-06-18   SG152144~ H10           2.58e11        8
      # i 158 more rows
      # i 5,007 more variables: SampleId <chr>, SampleType <chr>,
      #   PercentDilution <int>, SampleMatrix <chr>, Barcode <lgl>, Barcode2d <chr>,
      #   SampleName <lgl>, SampleNotes <lgl>, AliquotingNotes <lgl>,
      #   SampleDescription <chr>, ...
      ================================================================================

