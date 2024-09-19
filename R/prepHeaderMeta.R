#' Clean up Header Meta Data
#'
#' Make the header meta conform to current spec and format
#' in preparation for writing to an external text file.
#' This function an internal to `write_adat()`.
#'
#' @param x A `soma_adat` to be written.
#' @return The ADAT attributes after `Header.Meta` and `Col.Meta` clean up.
#' @author Stu Field
#' @noRd
prepHeaderMeta <- function(data) {

  if ( is_intact_attr(data) ) {
    x <- attributes(data)
    x$Col.Meta$Dilution2 <- NULL   # rm Dilution2
  } else {
    call <- sys.calls()[[max(1L, sys.nframe() - 1L)]]   # get parent call
    obj  <- deparse(call[[2L]])
    if ( interactive() ) {
      cat(
        "\n  Please fix ADAT attributes prior to calling",
        .code(deparse(call)), "\n ",
        .code(sprintf("is_intact_attr(%s)", obj)), "must be", .value("TRUE")
      )
      if ( utils::packageName() == "SomaDataIO" ) {
        cat(
          "\n  Perhaps", .code("createChildAttributes()"),
          "can help?\n  Example:\n   ",
          .code(sprintf("data <- createChildAttributes(%s, parent)", obj))
        )
      }
      cat("\n\n")
    }
    stop("Stopping while you fix the attributes of `", obj, "`.", call. = FALSE)
  }

  key_map_header <- lapply(x$Header.Meta$HEADER, attr, which = "raw_key")
  key_map_col <- lapply(x$Header.Meta$COL_DATA, attr, which = "raw_key")
  key_map_row <- lapply(x$Header.Meta$ROW_DATA, attr, which = "raw_key")
  .map_names  <- function(obj, map) {
    vapply(names(obj), function(.x) map[[.x]] %||% .x, FUN.VALUE = "", USE.NAMES = FALSE)
  }

  # Sync COL_DATA NAME & Type vectors
  type_map <- setNames(as.list(x$Header.Meta$COL_DATA$Type), x$Header.Meta$COL_DATA$Name)
  name_map <- setNames(as.list(x$Header.Meta$COL_DATA$Name), x$Header.Meta$COL_DATA$Name)
  x$Header.Meta$COL_DATA$Name <- .map_names(x$Col.Meta, name_map)
  x$Header.Meta$COL_DATA$Type <- .map_names(x$Col.Meta, type_map)
  names(x$Header.Meta$COL_DATA) <- .map_names(x$Header.Meta$COL_DATA, key_map_col)

  # Update the ROW_DATA -> Name & Type vectors
  meta_df <- data[, getMeta(data)]
  name_map2 <- setNames(as.list(x$Header.Meta$ROW_DATA$Name), x$Header.Meta$ROW_DATA$Name)
  x$Header.Meta$ROW_DATA$Name <- .map_names(meta_df, name_map2)
  # re-create accurate types from actual data object
  x$Header.Meta$ROW_DATA$Type <- vapply(meta_df, typeof, FUN.VALUE = "")
  names(x$Header.Meta$ROW_DATA) <- .map_names(x$Header.Meta$ROW_DATA, key_map_row)

  # zap commas with semicolons in chr Col.Meta
  # nolint start
  #idx <- which(vapply(x$Col.Meta, is.character, NA))
  #for ( i in idx ) x$Col.Meta[[i]] <- gsub(",", ";", x$Col.Meta[[i]])
  # nolint end

  # version number stuff
  if ( !("Version" %in% names(x$Header.Meta$HEADER) &&
         x$Header.Meta$HEADER$Version == "1.2") ) {
    x$Header.Meta$HEADER$Version <- "1.2"
    .done("Updating ADAT version to: {.val 1.2}")
  }

  if ( "CreatedBy" %in% names(x$Header.Meta$HEADER) ) {
    new <- c(paste(x$Header.Meta$HEADER$CreatedBy,
                   sprintf("(%s)", x$Header.Meta$HEADER$CreatedDate)),
             x$Header.Meta$HEADER$CreatedByHistory)
    x$Header.Meta$HEADER$CreatedByHistory <- paste(new, collapse = " | ")
  }

  x$Header.Meta$HEADER$CreatedDate <- format(Sys.time(), "%Y-%m-%d")

  user <- ifelse(grepl("linux|darwin", R.version$platform), Sys.getenv("USER"),
                 Sys.getenv("USERNAME"))
  pkg <- utils::packageName()
  pkg_ver <- utils::packageDescription(pkg, fields = "Version")
  x$Header.Meta$HEADER$CreatedBy <-
    sprintf("User: %s; Package: %s v%s; R %s.%s; OS: %s",
            user, pkg, pkg_ver, R.version$major, R.version$minor, R.version$os)

  # map orig 'key'-names of key-value pairs back to their orig values
  names(x$Header.Meta$HEADER) <- .map_names(x$Header.Meta$HEADER, key_map_header)
  x$Header.Meta$HEADER <- lapply(x$Header.Meta$HEADER, .strip_raw_key)
  x
}
