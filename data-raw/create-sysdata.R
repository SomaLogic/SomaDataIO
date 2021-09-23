#' -----------------------------------------
#' Create internals for functions necessary
#' to run exported functions in `SomaDataIO`
#' Functions originate from SomaLogic code base
#' save all in an environment within 'R/sysdata.rda'
#' -----------------------------------------
library(here)
local({
  io_int <- list()
  f <- list(
    c("addAttributes",  "SomaReadr"),
    c("addClass",       "SomaReadr"),
    c("cleanNames",     "SomaReadr"),
    c("squish",         "SomaReadr"),
    c("convertColMeta", "SomaReadr"),
    c("genRowNames",    "SomaReadr"),
    c("getAdatVersion", "SomaReadr"),
    c("parseCheck",     "SomaReadr"),
    c("syncColMeta",    "SomaReadr"),
    c("scaleAnalytes",  "SomaNormalization")
  )
  for (i in f) {
    # this is necessary to decouple the function from the namespace
    # avoids loading of source package when sysdata.rda is loaded
    # this is a bit hacky and could probably be improved
    fn   <- i[1L]
    ns   <- i[2L]
    func <- getFromNamespace(fn, ns = ns)   # get function
    func <- deparse1(func, collapse = "\n") # convert to text
    io_int[[fn]] <- eval(str2lang(func))    # re-create func
  }
  save(io_int, file = here("R", "sysdata.rda"))#, compress = "xz")
})
