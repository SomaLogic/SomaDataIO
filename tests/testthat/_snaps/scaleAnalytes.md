# no matches returns identical object, with a 1 message & 2 warnings

    Code
      new <- scaleAnalytes(short_adat, ref)
    Message
      x No matches between lists
    Condition
      Warning:
      Missing scalar value for (3) analytes. They will not be transformed.
      Please check the reference or its named SeqIds.
      Warning:
      There are extra scaling values (1) in the reference.
      They will be ignored.

# `scaleAnalytes()` only accepts the `soma_adat` class

    Code
      scaleAnalytes(bad_adat)
    Condition
      Error:
      ! `scaleAnalytes()` must be called on a 'soma_adat' object, not a 'data.frame'.
      Perhaps: [90m`scaleAnalytes(.data = addClass(bad_adat, "soma_adat"))`[39m?

