# a warning is triped if reference is missing any features

    Code
      new <- scaleAnalytes(adat, ref)
    Condition
      Warning:
      Missing scalar value for (3) analytes. They will not be transformed.
      Please check the reference or its named SeqIds.

# `scaleAnalytes()` only accepts the `soma_adat` class

    Code
      scaleAnalytes(bad_adat)
    Condition
      Error:
      ! `scaleAnalytes()` must be called on a 'soma_adat' object, not a 'data.frame'.
      Perhaps: [90m`scaleAnalytes(.data = addClass(bad_adat, "soma_adat"))`[39m?

