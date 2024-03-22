
# map external commercial names to
# internal SomaScan version names
# ----------------------------------
map_ver2k <- c(
  V3   = "1.1k",
  v3   = "1.1k",
  v3.0 = "1.1k",
  V3.2 = "1.3k",
  v3.2 = "1.3k",
  V4   = "5k",
  v4   = "5k",
  v4.0 = "5k",
  V4.1 = "7k",
  v4.1 = "7k",
  V5   = "11k",
  v5   = "11k",
  v5.0 = "11k"
)

map_k2ver <- c(
  "1.1k" = "v3.0",
  "1.3k" = "v3.2",
  "5k"   = "v4.0",
  "7k"   = "v4.1",
  "11k"  = "v5.0"
)

# matrx: either serum or plasma
# bridge: direction of the bridge
.get_lift_ref <- function(matrx = c("plasma", "serum"), bridge) {
  matrx <- match.arg(matrx)
  df <- dplyr::select(lift_master, SeqId, paste0(matrx, "_", bridge))
  df[is.na(df)] <- 1.0  # 1.0 scale factor for NAs
  setNames(df[[2L]], df$SeqId)
}


# Checks ----
# check that SomaScan data has been ANML normalized
# x = Header attributes
.check_anml <- function(x) {
  steps <- x$ProcessSteps
  if ( is.null(steps) | !grepl("ANML", steps, ignore.case = TRUE) ) {
    stop("ANML normalized SOMAscan data is required for lifting.",
         call. = FALSE)
  }
  invisible(NULL)
}

#' @param x the 'from' space.
#' @param y the bridge variable, e.g. '5k_to_7k'.
#' @return The 'to' space, from the 'y' param.
#' @noRd
.check_direction <- function(x, y) {
  x <- tolower(x)
  from <- gsub("(.*)_to_(.*)$", "\\1", y)
  to <- gsub("(.*)_to_(.*)$", "\\2", y)

  if ( isFALSE(x == from) ) {
    stop(
      "You have indicated a bridge from ", .value(from),
      " space, however your RFU data appears to be in ",
      .value(x), " space.", call. = FALSE
    )
  }
  if ( isTRUE(x == to) ) {
    stop(
      "You have indicated a bridge to ", .value(to),
      " space, however your RFU data already appears to be in ",
      .value(x), " space.", call. = FALSE
    )
  }

  invisible(to)
}
