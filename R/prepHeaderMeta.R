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

  if ( is.intact.attributes(data) ) {
    x <- attributes(data)
    x$Col.Meta$Dilution2 <- NULL   # rm Dilution2
  } else {
    call <- sys.calls()[[max(1L, sys.nframe() - 1L)]]   # get parent call
    obj  <- deparse(call[[2L]])
    if ( interactive() ) {
      cat(
        "\n  Please fix ADAT attributes prior to calling",
        .code(deparse(call)), "\n ",
        .code(sprintf("is.intact.attributes(%s)", obj)), "must be", .value("TRUE")
      )
      if ( utils::packageName() == "SomaReadr" ) {
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
  #idx <- which(vapply(x$Col.Meta, is.character, NA))
  #for ( i in idx ) x$Col.Meta[[i]] <- gsub(",", ";", x$Col.Meta[[i]])

  if ( "CreatedByHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedByHistory <-
      paste0(x$Header.Meta$HEADER$CreatedBy, "|",
             x$Header.Meta$HEADER$CreatedByHistory)
  } else {
    idx <- which(names(x$Header.Meta$HEADER) == "CreatedBy")
    x$Header.Meta$HEADER <- append(x$Header.Meta$HEADER,
                                   list(CreatedByHistory = x$Header.Meta$HEADER$CreatedBy),
                                   after = idx)
  }

  if ( "CreatedDateHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedDateHistory <-
      paste0(x$Header.Meta$HEADER$CreatedDate, "|",
             x$Header.Meta$HEADER$CreatedDateHistory)
  } else {
    idx <- which(names(x$Header.Meta$HEADER) == "CreatedDate")
    x$Header.Meta$HEADER <- append(x$Header.Meta$HEADER,
                                   list(CreatedDateHistory = x$Header.Meta$HEADER$CreatedDate),
                                   after = idx)
  }

  # version number stuff
  if ( !("Version" %in% names(x$Header.Meta$HEADER) &&
         x$Header.Meta$HEADER$Version == "1.2") ) {
    x$Header.Meta$HEADER$Version <- "1.2"
    .done("Updating ADAT version to: {.value('1.2')}")
  }

  x$Header.Meta$HEADER$CreatedDate <- format(Sys.time(), "%Y-%m-%d")
  user <- ifelse(grepl("linux|darwin", R.version$platform), Sys.getenv("USER"),
                 Sys.getenv("USERNAME"))
  pkg <- utils::packageName()
  pkg_ver <- as.character(utils::packageVersion(pkg))

  x$Header.Meta$HEADER$CreatedBy <-
    sprintf("User: %s; Package: %s_%s; using %s; Platform: %s",
            user, pkg, pkg_ver, R.version$version.string, R.version$system)

  # map orig 'key'-names of key-value pairs back to their orig values
  names(x$Header.Meta$HEADER) <- .map_names(x$Header.Meta$HEADER, key_map_header)
  x$Header.Meta$HEADER <- lapply(x$Header.Meta$HEADER, .strip_raw_key)
  x
}
