# `checkHeader()` prints expected output

    Code
      checkHeader(header, verbose = TRUE)
    Message
      v Header passed checks and traps

# .verbosity()` prints expected output

    Code
      .verbosity(adat, header)
    Output
      == Parsing Diagnostics =========================================================
    Message
      v ADAT version              > 1.2
      v Header skip               > 41
      v Table begin               > 20
      v Col.Meta start            > 21
      v Col.Meta shift            > 35
      v Is old ADAT               > FALSE
      v no. clinical variables    > 34
      v no. RFU variables         > 5284
      v Dim data matrix           > 1 x 5318
      v Dim Col.Meta (annot.)     > 5284 x 20
    Output
      -- Head Col Meta ---------------------------------------------------------------
      # A tibble: 6 x 20
        SeqId    SeqIdVersion SomaId   TargetFullName      Target UniProt EntrezGeneID
        <chr>    <chr>        <chr>    <chr>               <chr>  <chr>   <chr>       
      1 10000-28 3            SL019233 Beta-crystallin B2  CRBB2  P43320  1415        
      2 10001-7  3            SL002564 RAF proto-oncogene~ c-Raf  P04049  5894        
      3 10003-15 3            SL019245 Zinc finger protei~ ZNF41  P51814  7592        
      4 10006-25 3            SL019228 ETS domain-contain~ ELK1   P19419  2002        
      5 10008-43 3            SL019234 Guanylyl cyclase-a~ GUC1A  P43080  2978        
      6 10011-65 3            SL019246 Inositol polyphosp~ OCRL   Q01968  4952        
      # i 13 more variables: EntrezGeneSymbol <chr>, Organism <chr>, Units <chr>,
      #   Type <chr>, Dilution <chr>, PlateScale_Reference <chr>, CalReference <chr>,
      #   Cal_Example_Adat_Set001 <chr>, ColCheck <chr>,
      #   CalQcRatio_Example_Adat_Set001_170255 <chr>, QcReference_170255 <chr>,
      #   Cal_Example_Adat_Set002 <chr>, CalQcRatio_Example_Adat_Set002_170255 <chr>
      -- Trailing 2 RFU features -----------------------------------------------------
      # A tibble: 1 x 2
        seq.9997.12 seq.9999.1
              <dbl>      <dbl>
      1      11983.      1741.
      ================================================================================

