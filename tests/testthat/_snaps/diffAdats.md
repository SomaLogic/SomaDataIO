# `diffAdats()` generates 'all-passing' output with equal ADATs

    Code
      diffAdats(adat, adat)
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

# `diffAdats()` generates correct output with 1 analyte missing

    Code
      diffAdats(adat, adat[, -9L])
    Output
      == Checking ADAT attributes & characteristics ==================================
    Message
      > Attribute names are identical       v
      > Attributes are identical            x
      > ADAT dimensions are identical       x
      >   ADATs have same # of rows         v
      >   ADATs have same # of columns      x
      >   ADATs have same # of features     x
      >   ADATs have same # of meta data    v
      > ADAT row names are identical        v
      > ADATs contain identical Features    x
      > ADATs contain same Meta Fields      v
    Output
      Features in 'adat' but not 'adat[, -9L]':
               seq.3333.33
      
    Message
      v Continuing on the "*INTERSECT*" of ADAT columns
    Output
      -- Checking the data matrix ----------------------------------------------------
    Message
      > All Clinical data is identical      v
      > All Feature data is identical       v
    Output
      ================================================================================

# `diffAdats()` generates correct output with 1 clin variable missing

    Code
      diffAdats(adat, adat[, -3L])
    Output
      == Checking ADAT attributes & characteristics ==================================
    Message
      > Attribute names are identical       v
      > Attributes are identical            x
      > ADAT dimensions are identical       x
      >   ADATs have same # of rows         v
      >   ADATs have same # of columns      x
      >   ADATs have same # of features     v
      >   ADATs have same # of meta data    x
      > ADAT row names are identical        v
      > ADATs contain identical Features    v
      > ADATs contain same Meta Fields      x
    Output
      Meta data in 'adat' but not 'adat[, -3L]':
                  Subarray
      
    Message
      v Continuing on the "*INTERSECT*" of ADAT columns
    Output
      -- Checking the data matrix ----------------------------------------------------
    Message
      > All Clinical data is identical      v
      > All Feature data is identical       v
    Output
      ================================================================================

# `diffAdats()` generates correct output with 1 clin variable added

    Code
      diffAdats(adat, new)
    Output
      == Checking ADAT attributes & characteristics ==================================
    Message
      > Attribute names are identical       v
      > Attributes are identical            x
      > ADAT dimensions are identical       x
      >   ADATs have same # of rows         v
      >   ADATs have same # of columns      x
      >   ADATs have same # of features     v
      >   ADATs have same # of meta data    x
      > ADAT row names are identical        v
      > ADATs contain identical Features    v
      > ADATs contain same Meta Fields      x
    Output
      Meta data in 'new' but not 'adat':
                       foo
      
    Message
      v Continuing on the "*INTERSECT*" of ADAT columns
    Output
      -- Checking the data matrix ----------------------------------------------------
    Message
      > All Clinical data is identical      v
      > All Feature data is identical       v
    Output
      ================================================================================

# `diffAdats()` generates correct output with 1 variable changed

    Code
      diffAdats(adat, dplyr::mutate(adat, Subarray = rev(Subarray)))
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
      > All Clinical data is identical      x
    Output
          No. fields that differ            1
      -- Clinical data diffs ---------------------------------------------------------
      [1] "'Subarray'"
    Message
      > All Feature data is identical       v
    Output
      ================================================================================

# `diffAdats()` generates correct output 2 random values changed

    Code
      diffAdats(adat, new)
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
      > All Feature data is identical       x
    Output
          No. fields that differ            2
      -- Feature data diffs ----------------------------------------------------------
      [1] "'seq.1234.56', 'seq.9898.99'"
      ================================================================================

