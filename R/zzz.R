
.dummy <- function() { }  # nolint: brace_linter.

.onLoad <- function(libname, pkgname) {
  # this is to make the active binding switch between
  # UTF-8 and ASCII symbol encodings
  # nocov start
  `%enc%` <- function(utf, ascii) {
    if ( getOption("cli.unicode", TRUE) && l10n_info()$`UTF-8` ) {
      utf
    } else {
      ascii
    }
  }
  pkgenv <- environment(.dummy)
  makeActiveBinding("symb_tick", function() "\u2713" %enc% "v", pkgenv)
  makeActiveBinding("symb_cross", function() "\u2716" %enc% "x", pkgenv)
  makeActiveBinding("symb_warn", function() "\u26A0" %enc% "!", pkgenv)
  makeActiveBinding("symb_point", function() "\u276F" %enc% ">", pkgenv)
  makeActiveBinding("symb_info", function() "\u2139" %enc% "i", pkgenv)
  # nocov end
}

.onAttach <- function(libname, pkgname) {
  # Startup Message
  packageStartupMessage(
    cli_rule(right = "Legal", line = 2, col = "magenta"),
    "\n",
    create_legal(),
    "\n",
    cli_rule(line = 2, col = "magenta")
  )
}

create_legal <- function() {
  x <- strwrap(
    paste(
      "SomaDataIO\u2122

      Copyright \u00A9 2025 Standard BioTools, Inc.

      The `SomaDataIO` package is licensed under the MIT license
      (`LICENSE.md`) and is intended solely for research use
      only (\"RUO\") purposes. The code contained herein may *not*
      be used for diagnostic, clinical, therapeutic, or other
      commercial purposes. Further, \"SomaDataIO\" and \"SomaLogic\"
      are trademarks owned by Standard BioTools, Inc. No license
      is hereby granted to these trademarks other than for purposes
      of identifying the origin or source of the Software. The above
      copyright notice and this permission notice shall be included
      in all copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDER(S) BE LIABLE FOR ANY
      CLAIM, DAMAGES, WHETHER DIRECT OR INDIRECT, OR OTHER LIABILITY,
      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
      DEALINGS IN THE SOFTWARE."
    ),
    indent = 0, prefix = "   ", initial = "   "
  )
  paste(x, collapse = "\n")
}
