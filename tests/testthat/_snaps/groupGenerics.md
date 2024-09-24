# the `Ops()` group generic generates the expected output

    Code
      expect_error(adat == adat, NA)
    Output
      == Checking ADAT attributes & characteristics ==================================
    Message
      > Attribute names are identical       v
      > Attributes are identical            v
      > ADAT dimensions are identical       v
      > ADAT row names are identical        v
      > ADATs contain identical Features    v
      > ADATs contain same Meta Fields      v
    Output
      -- Checking the data matrix ----------------------------------------------------
    Message
      > All Clinical data is identical      v
      > All Feature data is identical       v
    Output
      ================================================================================

# error conditions generate the expected output for deprecated `soma.adat`

    Code
      readLines(catfile)
    Output
      [1] "The 'soma.adat' class is now 'soma_adat' ."                                
      [2] " Please either:"                                                           
      [3] "   1) Re-class with x <- addClass(x, 'soma_adat')"                         
      [4] "   2) Re-call 'x <- read_adat(file)' to pick up the new 'soma_adat' class."

