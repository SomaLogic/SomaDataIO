# the `Ops()` group generic generates the expected output

    Code
      expect_error(adat == adat, NA)
    Output
      == Checking ADAT attributes & characteristics ==================================
    Message <rlang_message>
      * Attribute names are identical       v
      * Attributes are identical            v
      * ADAT dimensions are identical       v
      * ADAT row names are identical        v
      * ADATs contain identical Features    v
      * ADATs contain same Meta Fields      v
    Output
      -- Checking the data matrix ----------------------------------------------------
    Message <rlang_message>
      * All Clinical data is identical      v
      * All Feature data is identical       v
    Output
      ================================================================================

