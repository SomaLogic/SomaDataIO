
# skip if during devtools::check() or rcmdcheck::rcmdcheck()
skip_on_check <- function() {
  on_check <- !identical(Sys.getenv("_R_CHECK_PACKAGE_NAME_"), "")
  testthat::skip_if(on_check, "On devtools::check() / rcmdcheck::rcmdcheck()")
}

# mock up dummy data.frame -> soma_adat
# minimal set of attributes to trick `is_intact_attr()` to be TRUE
mock_adat <- function() {
  data <- data.frame(
    PlateId     = rep_len("Set A", 6),
    SlideId     = (12345 + 0:5),
    Subarray    = rep(1:3, 2),
    SampleId    = sprintf("%03i", 1:6),
    SampleGroup = rep(c("A", "B"), 3),
    TimePoint   = rep(c("before", "after"), each = 3),
    NormScale   = round(withr::with_seed(1, runif(6, 0, 2)), 1L),
    seq.1234.56 = round(withr::with_seed(2, rnorm(6, 2500, 500)), 1L),
    seq.3333.33 = round(withr::with_seed(3, rnorm(6, 3000, 500)), 1L),
    seq.9898.99 = round(withr::with_seed(4, rnorm(6, 3500, 500)), 1L)
  )
  rownames(data) <- genRowNames(data)
  structure(
    data,
    class = c("soma_adat", "data.frame"),
    Header.Meta = list(HEADER   = list(Version      = "1.2",
                                       AssayVersion = "V4",
                                       AssayRobot   = "Fluent 1",
                                       AssayType    = "PharmaServices",
                                       StudyMatrix  = "EDTA Plasma",
                                       Title        = "SL-99-999"),
                       COL_DATA = list(Name = c("SeqId", "UniProt",
                                                "EntrezGeneSymbol", "Target",
                                                "Organism","Units", "Type",
                                                "Dilution", "CalReference"),
                                       Type = rep_len("String", 9)
                                       ),
                       ROW_DATA = list(Name = getMeta(data),
                                       Type = rep_len("String",
                                                      getMeta(data, n = TRUE))
                                       )
                       ),
    Col.Meta = tibble::tibble(
      SeqId            = c("1234-56", "3333-33", "9898-99"),
      UniProt          = paste0("P0", 4321:4323),
      EntrezGeneSymbol = c("MMP1", "MMP2", "MMP3"),
      Target           = c("MMP-1", "MMP-2", "MMP-3"),
      Organism         = rep_len("Human", 3L),
      Units            = rep_len("RFU", 3L),
      Type             = rep_len("Protein", 3L),
      Dilution         = c("0.005", "1", "40"),
      CalReference     = seq(0.4, 0.8, length.out = 3L)),
    file_specs = list(empty_adat     = FALSE,
                      table_begin    = 20,
                      col_meta_start = 21,
                      col_meta_shift = 15,
                      data_begin     = 21 + 9,
                      old_adat       = FALSE),
    row_meta = getMeta(data)
  )
}

# temporarily mask the base::interactive function
# with new value: lgl
with_interactive <- function(lgl, code) {
  old <- base::interactive      # save the old function
  new <- function() return(lgl) # set new hard-coded return value
  unlockBinding("interactive", as.environment("package:base"))  # unlock
  # hack base::interactive with 'new'
  assign("interactive", new, envir = as.environment('package:base'))
  on.exit({
    # undo cleanup when closes
    unlockBinding("interactive", as.environment("package:base"))
    assign("interactive", old, envir = as.environment('package:base'))
  })
  force(code)   # execute code in new state
}

# temporarily modify internal pkg object
# for testing edge cases
with_pkg_object <- function(new, code, obj = "ver_dict") {
  old <- getFromNamespace(obj, ns = "SomaDataIO") # save the old obj
  assignInNamespace(obj, new, ns = "SomaDataIO")
  on.exit(assignInNamespace(obj, old, ns = "SomaDataIO"))
  force(code)
}

# Inspired by `expect_snapshot_file()` documentation
save_png <- function(code, ..., gg = TRUE) {
  path <- figure(tempfile(fileext = ".png"), ...)
  on.exit(close_figure(path))
  if ( gg ) {
    print(force(code))
  } else {
    force(code)
  }
  path
}

expect_snapshot_plot <- function(code, name, ...) {
  name <- paste0(name, ".png")
  withr::defer(unlink(name, force = TRUE))
  # Announce the file before touching `code`. This way, if `code`
  # unexpectedly fails or skips, testthat will not auto-delete the
  # corresponding snapshot file
  announce_snapshot_file(name = name)
  # only run on MacOS
  skip_on_os(c("linux", "windows"))
  path <- save_png(code, ...)
  expect_snapshot_file(path, name)
}

#' Saves a Figure (Plot) to File
#'
#' A wrapper for [png()], [pdf()], or [jpeg()] to save plots to
#' disk. If a file path is passed to [figure()], it
#' opens a plotting device based on the file extension,
#' passing the same file name to [close_figure()].
#' If `file = NULL`, output is directed to the default plotting device.
#'
#' The [figure()] and [close_figure()] functions
#' are most useful when used inside of another function that creates a plot.
#' By adding a `file =` pass-through argument to a function that creates a plot,
#' the user can toggle between plotting to file or to a graphics device.
#' Supported plotting devices:
#'   \itemize{
#'     \item [png()]
#'     \item [pdf()]
#'     \item [jpeg()]
#'     \item [postscript()] (`*.eps`)
#'   }
#'
#' @family base R
#' @param file Character. The path of the output file passed to [png()],
#'   [pdf()], or [jpeg()]. Plot type determined by file extension.
#' @param height Double. The height of the plot in pixels.
#' @param width Double. The width of the plot in pixels.
#' @param scale A re-scaling of the output to resize window better.
#' @param ... Additional arguments passed to [png()], [pdf()], or [jpeg()].
#' @note The `fontsize` of the plots are constant. If you would like to
#'   increase the font size relative to the plot, you can decrease the plot size.
#'   Alternatively, you can pass `pointsize` as an additional argument.
#' @author Stu Field
#' @return The `file` argument, invisibly.
#' @seealso [png()], [pdf()], [dev.off()]
#' @examples
#' # Create enclosing plotting function
#' createPlot <- function(file = NULL) {
#'   figure(file = file)
#'   on.exit(close_figure(file = file))
#'   plot_data <- withr::with_seed(1, matrix(rnorm(30), ncol = 2))
#'   plot(as.data.frame(plot_data), col = unlist(soma_colors), pch = 19, cex = 2)
#' }
#'
#' # default; no file saved
#' createPlot()
#'
#' if ( interactive() ) {
#'   # Save as *.pdf
#'   createPlot("example.pdf")
#'
#'   # Save as *.png
#'   createPlot("example.png")
#' }
#' @importFrom grDevices pdf png jpeg postscript
figure <- function(file, height = 480, width = 480, scale = 1, ...) {
  if ( !is.null(file) ) {
    ext <- file_ext(file)
    if ( isTRUE(ext == "pdf") ) {
      pdf(file = file,
          height = (height / 96) * scale,  # assume 96 px / in
          width = (width / 96) * scale,
          useDingbats = FALSE,
          title = basename(file), ...)
    } else if ( isTRUE(ext == "png") ) {
      png(filename = file,
          height = height * scale,
          width = width * scale, ...)
    } else if ( isTRUE(ext == "eps") ) {
      postscript(file = file,
                 height = height * scale * 100,
                 width = width * scale * 100,
                 horizontal = FALSE,
                 onefile = FALSE,
                 paper = "special", ...)
    } else if ( isTRUE(ext == "jpeg") ) {
      jpeg(filename = file, height = height * scale, width = width * scale, ...)
    } else {
      stop(
        "Could not find file extension ", value(ext),
        " in provided file path: ", value(file), call. = FALSE
      )
    }
  }
  invisible(file)
}


#' Closes the currently active plotting device with a
#'   [dev.off()] call if a file name is passed. If
#'   `file = NULL`, nothing happens. This function is typically used in
#'   conjunction with [figure()] inside the enclosing function. See example.
close_figure <- function(file) {
  if ( !is.null(file) ) {
    grDevices::dev.off()
  }
  invisible(file)
}
