#' Plot Image Maps
#'
#' Plotting function for objects of the `outlier_map` class. Produces a
#' heatmap-style image using \pkg{ggplot2} syntax, for objects
#' produced by [calcOutlierMap()].
#'
#' @family Calc Map
#' @param x An object of class: `outlier_map`
#' @param color.scheme Which color scheme to use. Typical choices include:
#'   * [gplots::redgreen()]
#'   * [gplots::bluered()]
#'   * [grDevices::heat.colors()]
#'   * [grDevices::terrain.colors()]
#'   * [grDevices::topo.colors()]
#'   * [RColorBrewer::brewer.pal()]
#'   * [viridis::viridis()]
#'   * [viridis::magma()]
#' @param legend.ticks How many ticks to place on the color legend.
#' @param gridlines Numeric vector or logical. Indicates where to draw the _horizontal_
#'   grid lines that can be used to separate samples (rows). This
#'   should be a vector of the cumulative sum of the horizontal lines to be
#'   drawn, typically something like `cumsum(table(data$Sex))`.
#'   Alternatively, `TRUE` can be passed whereby the lines are determined by
#'   the "class.tab" element of `x$class.tab` (if possible).
#' @param gridlinecol Color of the gridlines.
#' @param gridlinelwd Width of the gridlines.
#' @param gridlinelty Line type of the gridlines.
#' @param main Character. Main title for the plot.
#'   See [ggplot2::ggtitle()] for `ggplot2` style graphics.
#' @param x.lab Character. Optional string for the x-axis. Otherwise
#'   one is automatically generated (default).
#' @param y.lab Character. Optional string for the y-axis. Otherwise
#'   one is automatically generated (default).
#' @param flags Numeric in \verb{[0, 1]}.
#'   For an `"outlier_map"`, the proportion of the analytes (columns)
#'   for a given sample that must be outliers for a flag to be placed at the right-axis,
#'   right-axis, thus flagging that sample.
#'   If `NULL` (default), `0.05` (5%) is selected.
#' @param legend.width Width for the color legend.
#' @param legend.height Height for the color legend.
#' @param filename Optional. If provided, the plot will be written to a file.
#'   The file name must also include the desired file type extension;
#'   this will be used to determine the file type,
#'   e.g. a file named `foo.png` will be saved as a `PNG`.
#'   See [ggplot2::ggsave()] for a full list of file type (device) options.
#' @param plot.width If `"filename != NULL"`, the width of the plot image file.
#' @param plot.height If `"filename != NULL"`, the height of the plot image file.
#' @param plot.scale If `"filename != NULL"`, the scale of the plot image file.
#' @param ... Arguments required by the `plot()` generic. Currently unused.
#' @return Plot an image of the passed matrix.
#' @author Stu Field, Amanda Hiser
#' @seealso [ggplot2::ggplot()], [ggplot2::geom_raster()]
#' @examples
#' example_data |>
#'   dplyr::filter(SampleType == "Sample") |>
#'   head(10) |>
#'   calcOutlierMap() |>
#'   plot(flags = 0.05)
#' @importFrom dplyr mutate group_by row_number ungroup
#' @importFrom ggplot2 element_text element_blank element_rect unit
#' @importFrom ggplot2 labs scale_x_discrete scale_x_continuous theme
#' @importFrom ggplot2 guides guide_colorbar guide_legend guide_axis sec_axis
#' @importFrom ggplot2 scale_y_reverse scale_fill_manual scale_fill_gradientn
#' @importFrom ggplot2 ggplot aes geom_raster geom_vline geom_hline ggsave
#' @importFrom tidyr gather
#' @export
plot.Map <- function(x, color.scheme = NULL,
                     legend.ticks = 7, gridlines = NULL,
                     gridlinecol = "red", gridlinelwd = 0.5,
                     gridlinelty = 2, main = NULL,
                     y.lab = NULL, x.lab = NULL,
                     flags = NULL, legend.width = 1,
                     legend.height = 2, filename = NULL,
                     plot.width = 14, plot.height = 8,
                     plot.scale = 1, ...) {

  plot.info <- x[-1L]    # get plot info as list from object
  obj       <- x
  x         <- x$matrix  # get the matrix
  np        <- ncol(x)   # n proteins
  nsamples  <- nrow(x)   # n samples
  max       <- max(x)
  min       <- min(x)

  # declaring labels for the final plot
  x.lab        <- plot.info$x.lab
  flags        <- flags %||% 0.05
  new.ylab     <- plot.info$y.lab %||% "Samples (by Adat)"
  legend.title <- sprintf("Samples: %i\n%s: %i\n\nColor Key", nsamples,
                          plot.info$legend.sub, np)
  legend.labs  <- sprintf("%0.2f", seq(min, max, length = legend.ticks))

  # converting matrix to long-format data frame for ggplot2.
  # "*Count" cols assign a cumulative numeric value to each subject &
  # protein (or other y-axis variable) based on their position in the matrix
  df <- as.data.frame(x) |> rn2col("SubjectId")
  df <- df |>
    mutate(SubjectCount = row_number()) |>
    gather(key = Group, value = Response, -c(SubjectId, SubjectCount)) |>
    group_by(SubjectId) |>
    mutate(GroupCount = row_number()) |>
    ungroup()

  # determine color palette for the final figure
  color.scheme <- color.scheme %||% rev(grDevices::topo.colors(100))
  legend.ticks <- 2        # only 2 are required for boolean data
  star_samples <- getOutlierIds(obj, flags)$idx   # outlier samples to flag

  # define plot title & axis labels for starred samples
  title <- paste0(plot.info$title, "     ",
                  sprintf("(* \u2265 %s%%)", format(flags * 100, digits = 3)))


  # define aesthetic mappings
  # using a cumulative protein count (integer) value for x-axis tick labels
  p <- ggplot(df, aes(x = GroupCount, y = SubjectCount, fill = Response)) +
    scale_x_continuous(expand = c(0, 0), # extend plot area out to the axis line
                       n.breaks = 6)     # must be the desired final value + 1


  # adding geom layers to produce a heatmap, using the
  # aesthetic mappings defined above
  p <- p + geom_raster(vjust = 1) +
    labs(x = x.lab,
         y = new.ylab,
         title = title) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          legend.key.width = unit(1.6, "cm"),
          legend.key.height = unit(12, "mm"),
          axis.text.y.right = element_text(hjust = 0,    # align '*' character
                                           vjust = 0.7,  # with axis ticks
                                           size = 16,
                                           colour = "blue"),
          axis.ticks.x.top = element_blank(),
          panel.border = element_rect(color = "gray50",
                                      fill = NA,
                                      linetype = "solid",
                                      size = 2.5))

  p <- p + guides(fill = guide_legend(title = legend.title)) +
    scale_fill_manual(values = c("TRUE"  = color.scheme[100L], # grab max & min vals
                                 "FALSE" = color.scheme[1L]),  # from color scale
                      breaks = c("TRUE", "FALSE"))             # set order of values

  if ( has_length(star_samples) ) {
    p <- p +
      scale_y_reverse(sec.axis = sec_axis(~ . * 1,
                                          labels = rep_len("*", length(star_samples)),
                                          breaks = star_samples,
                                          guide  = guide_axis(n.dodge = 2)),
                      expand = c(0, 0))
  } else {
    # remove secondary axis ticks if no samples are starred
    p <- p + scale_y_reverse(expand = c(0, 0)) +
      theme(axis.ticks.y.right = element_blank())
  }


  # draws a vertical line to delineate the analytes in each dilution
  if ( "dil.nums" %in% names(plot.info) ) {
    dil.nums <- plot.info$dil.nums
    p <- p + geom_vline(xintercept = cumsum(dil.nums)[-length(dil.nums)],
                        color = "purple", lwd = 1, lty = 2)
  }

  # determines location for horizontal gridlines to add to the plot,
  # if they're supplied by the user
  if ( isTRUE(gridlines) || length(gridlines) > 0L ) {
    if ( .is_int(gridlines) ) {
      gridlines <- gridlines
    } else if ( isTRUE(gridlines) && !is.null(dim(plot.info$class.tab)) ) {
      dd <- dim(plot.info$class.tab)
      if ( length(dd) == 2L ) {
        lines     <- as.numeric(t(plot.info$class.tab))
        lines     <- lines[lines != 0]
        gridlines <- cumsum(lines) |> utils::head(-1L)  # trim last entry
      } else {
        gridlines <- cumsum(plot.info$class.tab) |> utils::head(-1L)
      }
    } else if ( isTRUE(gridlines) && is.na(plot.info$class.tab) ) {
      stop(
        "If `gridlines = TRUE`, ", .value("x$class.tab"), " cannot be NA.\n",
        "Check the ", .value("sample.order"), " argument of the caller function.",
        call. = FALSE
      )
    } else {
      stop(
        "Problem with `gridlines =` argument.\n",
        "Should be a vector of numbers (x-axis intercepts) or a logical (TRUE/FALSE)",
        call. = FALSE
      )
    }

    # drawing the gridlines
    p <- p + geom_hline(yintercept = gridlines,
                        lwd        = gridlinelwd,
                        lty        = gridlinelty,
                        col        = gridlinecol)
  }

  # writing plot out to file (only if user specified a filename)
  if ( !is.null(filename) ) {
    f_ext <- file_ext(filename)
    if ( identical(f_ext, "") ) {
      stop(
        "A file extension must be included when a file name is provided.",
        call. = FALSE
      )
    }
    ggsave(p,
           filename = filename,
           width    = plot.width,
           height   = plot.height,
           scale    = plot.scale,
           device   = f_ext)
  }

  p
}
