
# internal helpers similar to `usethis` functions
.value <- function(x) {
  if ( identical(Sys.getenv("TESTTHAT"), "true") ) {
    paste(encodeString(x, quote = "'"), collapse = ", ")
  } else {
    cli::cli_text("{.val {x}}")
  }
}

.strip_raw_key <- function(x) {
  attr(x, "raw_key") <- NULL
  x
}

.code <- function(x) {
  paste0("\033[90m", encodeString(x, quote = "`"), "\033[39m")
}

# borrow from cli for internal use
# without explicitly importing the package in NAMESPACE file
# avoid R CMD check NOTE:
#   "Namespace in Imports field not imported from: 'pkg'"
.todo <- cli::cli_alert
.done <- cli::cli_alert_success
.oops <- cli::cli_alert_danger
# -------------------------- #
cli_rule  <- cli::rule
# -------------------------- #
cr_bold   <- cli::style_bold
cr_green  <- cli::col_green
cr_cyan   <- cli::col_cyan
cr_red    <- cli::col_red
cr_blue   <- cli::col_blue
cr_yellow <- cli::col_yellow


# wrapper around padding; default to right side padding
.pad <- function(x, width, side = c("right", "left")) {
  side <- match.arg(side)
  just <- switch(side, right = "left", left = "right")
  encodeString(x, width = width, justify = just)
}

# friendly version of ifelse
`%||%` <- function(x, y) {
  if ( is.null(x) || length(x) <= 0L ) {
    y
  } else {
    x
  }
}

# kinder version of identical
`%==%` <- function(x, y) {
  isTRUE(all.equal(x, y))
}

# easily test inequality of R objects
`%!=%` <- function(x, y) {
  !isTRUE(all.equal(x, y))
}

# A friendly version of `attr(x, y)`. `y` can be unquoted.
`%@@%` <- function(x, y) {
  name <- as.character(substitute(y))
  attr(x, which = name, exact = TRUE)
}

has_length <- function(x) {
  length(x) > 0L
}

.is_int <- function(x) {
  if ( !is.numeric(x) ) {
    return(FALSE)
  }
  all(floor(x) == x, na.rm = TRUE)
}

file_ext <- function(x) {
  gsub("(.+)([.])([^.]+)$", "\\3", basename(x), perl = TRUE)
}

.refactorData <- function(data) {
  lgl <- vapply(data[getMeta(data)], is.factor, NA, USE.NAMES = TRUE)
  nms <- names(lgl[lgl])
  for ( meta in nms ) {
    levs <- levels(data[[meta]])
    data[[meta]] <- droplevels(data[[meta]])
    sdiff <- setdiff(levs, levels(data[[meta]]))
    if ( length(sdiff) > 0L && interactive() ) {
      .todo("Dropping levels {.val {sdiff}} from {.val {meta}}")
    }
  }
  data
}

# this is a clone of `getAptamerDilution()` from internal source code
# hard-coded to drop-hybs
.getDilList <- function(ad) {
  ad <- dplyr::filter(ad, !grepl("^Hybridization", Type))
  stopifnot("Dilution" %in% names(ad), "AptName" %in% names(ad))
  split(ad$AptName, ad$Dilution)
}

# Group analytes by the scale factor column that normalizes them.
# Plasma/serum use one group per `Dilution` (e.g. "20", "0_5", "0_005"); assays
# with normalization groups (urine and CSF) use one group per
# `Dilution` x `NormGroup` (e.g. "75_S1"). The returned named list of AptNames
# carries a "sf_cols" attribute holding the actual `NormScale_*` column name for
# each group, because deliverables differ in how they write dilutions in
# the column names ("NormScale_0_5" vs "NormScale_0.3"). Groups without an
# existing column map to "NormScale_<group>". Also attached: "n_dilutions"
# (number of distinct dilutions) and "has_norm_groups".
.getNormGroups <- function(adat, apt_data = getAnalyteInfo(adat)) {

  if ( !"Dilution" %in% names(apt_data) ) {
    stop("Dilution information not found in analyte data", call. = FALSE)
  }

  # hybridization controls are not scaled by median normalization
  # (identified by `Type`, or by their "0" dilution if `Type` is unavailable)
  is_hyb <- if ( "Type" %in% names(apt_data) ) {
    grepl("^Hybridization", apt_data$Type, ignore.case = TRUE)
  } else {
    as.character(apt_data$Dilution) %in% "0"
  }
  apt_data <- apt_data[!is_hyb, , drop = FALSE]
  key <- as.character(apt_data$Dilution)
  n_dilutions <- length(unique(key))

  has_norm_groups <- FALSE
  if ( "NormGroup" %in% names(apt_data) ) {
    ng  <- as.character(apt_data$NormGroup)
    has <- !is.na(ng) & nzchar(ng)
    key[has] <- paste(key[has], ng[has], sep = "_")
    has_norm_groups <- any(has)
  }

  groups <- split(apt_data$AptName, key)
  names(groups) <- .cleanNormKey(names(groups))

  if ( anyDuplicated(names(groups)) ) {
    stop(
      "Distinct `Dilution`/`NormGroup` values map to the same scale factor ",
      "group: ", paste(unique(names(groups)[duplicated(names(groups))]), collapse = ", "),
      call. = FALSE
    )
  }

  existing  <- grep("^NormScale_", names(adat), value = TRUE)
  ex_key    <- .cleanNormKey(sub("^NormScale_", "", existing))
  sf_cols   <- existing[match(names(groups), ex_key)]
  missing   <- is.na(sf_cols)
  sf_cols[missing] <- paste0("NormScale_", names(groups)[missing])
  attr(groups, "sf_cols")         <- stats::setNames(sf_cols, names(groups))
  attr(groups, "n_dilutions")     <- n_dilutions
  attr(groups, "has_norm_groups") <- has_norm_groups
  groups
}

# standardize dilution strings so they can be matched to column names
# e.g. "20%" -> "20", "20.0" -> "20", "0.5" -> "0_5"
.cleanNormKey <- function(x) {
  x <- gsub("%", "", x)
  x <- sub("[.]0$", "", x)
  gsub("\\.", "_", x)
}

# `NormScale*` column name for a group returned by `.getNormGroups()`
.getScaleCol <- function(groups, name) {
  attr(groups, "sf_cols")[[name]]
}

# this is adapted from `getOutliers()` and only retains nonparametric-type
# calculations
#' @importFrom stats mad median
.getOutliers <- function(x, fold.crit = 5) {
  med       <- median(x, na.rm = TRUE)
  stat_bool <- abs( x - med ) > 6 * mad(x, constant = 1) # stat criterion
  fold_bool <- (x / med > fold.crit) | (med / x > fold.crit)    # FC criterion
  which(stat_bool & fold_bool)
}
