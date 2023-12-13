# the `median.soma_adat()` method trips correct warning

    Code
      median(adat)
    Condition
      Warning:
      As with the `data.frame` class, numeric data is required for `stats::median()`.
      Please use either:
      
         [90m`median(data.matrix(x[, getAnalytes(x)]))`[39m
      OR
         [90m`apply(x[, getAnalytes(x)] 2, median)`[39m

