
.dummy <- function() { }  # nolint

.onLoad <- function(libname, pkgname) {
  # this is to make the active binding switch between
  # UTF-8 and ASCII symbol encodings
  switch_enc <- function(utf, ascii) {
    if ( getOption("cli.unicode", TRUE) && l10n_info()$`UTF-8` ) {
      utf
    } else {
      ascii
    }
  }
  pkgenv <- environment(.dummy)
  makeActiveBinding("symb_tick", function() switch_enc("\u2713", "v"), pkgenv)
  makeActiveBinding("symb_cross", function() switch_enc("\u2716", "x"), pkgenv)
  makeActiveBinding("symb_warn", function() switch_enc("\u26A0", "!"), pkgenv)
  makeActiveBinding("symb_point", function() switch_enc("\u276F", ">"), pkgenv)
  makeActiveBinding("symb_info", function() switch_enc("\u2139", "i"), pkgenv)
  invisible()
}

.onAttach <- function(libname, pkgname) {
  # Startup Message
  packageStartupMessage(
    rule(right = "Legal", line = 2, col = "magenta"),
    "\n",
    stringr::str_glue(
      "
         SomaDataIO\u2122

         Copyright \u00A9 2021 SomaLogic, Inc.

         Permission is hereby granted, free of charge, to any person obtaining
         a copy of the SomaDataIO software and associated documentation files
         (the \"Software\"), to deal in the Software without restriction,
         including without limitation the rights to use, copy, modify, merge,
         publish, distribute, sublicense, and/or sell copies of the Software,
         and to permit persons to whom the Software is furnished to do so,
         subject to the following conditions outlined below.  Further,
         SomaDataIO and SomaLogic are trademarks owned by SomaLogic, Inc.  No
         license is hereby granted to these trademarks other than for purposes
         of identifying the origin or source of the Software.

         The above copyright notice and this permission notice shall be
         included in all copies or substantial portions of the Software.

         THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
         EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
         MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
         IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDER(S) BE LIABLE FOR
         ANY CLAIM, DAMAGES, WHETHER DIRECT OR INDIRECT, OR OTHER LIABILITY,
         WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
         OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
         IN THE SOFTWARE.
      "
      ),
    "\n",
    rule(line = 2, col = "magenta")
  )
}
