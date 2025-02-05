#' Load ADAT files as a list
#'
#' Load a series of ADATs and return a list of `soma_adat`
#' objects, one for each ADAT file.
#' [collapseAdats()] concatenates a list of ADATs from [loadAdatsAsList()],
#' while maintaining the relevant attribute entries (mainly the `HEADER`
#' element). This makes writing out the final object possible without the
#' loss of `HEADER` information.
#'
#' \describe{
#'   \item{__Note 1__:}{The default behavior is to "vertically bind"
#'     ([rbind()]) on the  *intersect* of the column variables, with
#'     unique columns silently dropped.}
#'   \item{__Note 2__:}{If "vertically binding" on the column *union* is
#'     desired, use [dplyr::bind_rows()], however this results in `NAs` in
#'     non-intersecting columns. For many files with little variable
#'     intersection, a sparse RFU-matrix will result
#'     (and will likely break ADAT attributes):
#'   ```{r, eval = FALSE}
#'   adats <- loadAdatsAsList(files)
#'   union_adat <- dplyr::bind_rows(adats, .id = "SourceFile")
#'   ```
#'   }
#' }
#'
#' @family IO
#' @param files A character string of files to load.
#' @param collapse Logical. Should the resulting list of ADATs be
#'   collapsed into a single ADAT object?
#' @param verbose Logical. Should the function call be run in *verbose* mode.
#' @param ... Additional arguments passed to [read_adat()].
#' @return A list of ADATs named by `files`, each a `soma_adat` object
#'   corresponding to an individual file in `files`. For [collapseAdats()],
#'   a single, collapsed `soma_adat` object.
#' @author Stu Field
#' @seealso [read_adat()]
#' @examples
#' # only 1 file in directory
#' dir(system.file("extdata", package = "SomaDataIO"))
#'
#' files <- system.file("extdata", package = "SomaDataIO") |>
#'   dir(pattern = "[.]adat$", full.names = TRUE) |> rev()
#'
#' adats <- loadAdatsAsList(files)
#' class(adats)
#'
#' # collapse into 1 ADAT
#' collapsed <- collapseAdats(adats)
#' class(collapsed)
#'
#' # Alternatively use `collapse = TRUE`
#' \donttest{
#'   loadAdatsAsList(files, collapse = TRUE)
#' }
#' @importFrom stats setNames
#' @export
loadAdatsAsList <- function(files, collapse = FALSE, verbose = interactive(), ...) {
  files <- setNames(files, cleanNames(basename(files)))
  res <- lapply(files, function(file) {
    x <- tryCatch(read_adat(file, ...), error = function(e) NULL)
    if ( is.null(x) ) {
      .oops("Failed to load: {.val {file}}")
    } else if ( verbose ) {
      .done("Loading: {.val {file}}")
    }
    x
  })
  res <- Filter(Negate(is.null), res)

  if ( collapse ) {
    collapseAdats(res)
  } else {
    res
  }
}


#' @rdname loadAdatsAsList
#' @param x A list of `soma_adat` class objects returned from
#'   [loadAdatsAsList()].
#' @importFrom dplyr select all_of
#' @export
collapseAdats <- function(x) {
  is_adat <- vapply(x, is.soma_adat, NA)
  stopifnot(
    "All entries in 'list of adats' must be `soma_adat` class." = all(is_adat)
  )
  common <- Reduce(intersect, lapply(x, names))   # common df names
  new <- lapply(x, dplyr::select, all_of(common))
  header_list <- lapply(new, attr, which = "Header.Meta")
  ids <- vapply(header_list, function(.x) {
    hd <- .x$HEADER
    # chain ExpId search ending with file name
    hd$ExpIds %||% hd$Title %||% sub("[.]adat$", "", .x$TABLE_BEGIN) # strip ext
  }, "") |> cleanNames()

  # must do this here, on 'new' not 'x', but before the `do.call()`
  new_colmeta <- .mapply(list(new, ids), FUN = function(.x, .y) {
    structure(attr(.x, "Col.Meta"), expid_chr = .y)
  }, MoreArgs = NULL) |> Reduce(f = combine_colmeta)

  new_header <- lapply(header_list, `[[`, "HEADER") |>
    Reduce(f = combine_header)
  new_header$CollapsedAdats <- paste(names(x), collapse = ", ")

  # unname so rownames are re-constructed via `rbind()`
  new <- do.call(rbind, unname(new))

  attributes(new)$Header.Meta$HEADER <- new_header
  attributes(new)$Col.Meta <- new_colmeta
  nms <- names(attributes(x[[1L]]))         # attr order of 1st adat
  attributes(new) <- attributes(new)[nms]   # orig order
  new
}


# helper to smartly combine header info
# from multiple ADATs
combine_header <- function(x, y) {
  # intersecting entries: to be pasted/merged
  keep <- c("AssayRobot", "CreatedDate", "Title", "ExpDate")
  keep <- intersect(keep, intersect(names(x), names(y)))
  # plate and cal entries: to be pasted/merged
  plt <- intersect(grep("^Plate|^Cal", names(x), value = TRUE),
                   grep("^Plate|^Cal", names(y), value = TRUE))
  # new entries in 'y': to be added
  set_yx <- setdiff(names(y), names(x))
  for ( i in c(keep, plt, set_yx) ) {
    if ( i %in% names(x) ) {
      x[[i]] <- paste_xy(x[[i]], y[[i]]) # maintains attrs of 'x'
    } else {
      x[[i]] <- y[[i]] # new added entries
    }
  }
  x
}

# pastes and maintains attrs
paste_xy <- function(x, y, sep = ", ", ...) {
  atts <- attributes(x)   # maintain attrs of 'x'
  x <- paste(x, y, sep = sep, ...)
  attributes(x) <- atts
  x
}

# helper to smartly combine Col.Meta info
# from multiple ADATs; primarily Calibration SFs and ColCheck
#' @importFrom dplyr any_of all_of
#' @noRd
combine_colmeta <- function(x, y) {
  if ( !setequal(x$SeqId, y$SeqId) ) {
    # this should never happen
    # `dplyr::select()` on the common intersect has already happened
    # and should update the Col.Meta accordingly
    warning("Unable to fully resolve all Col.Meta SeqIds during collapse.",
            call. = FALSE)
    return(x)
  }
  id_y <- paste0("_", attr(y, "expid_chr"))
  cal_names <- grep("^Cal[._]", names(y), value = TRUE) # get CalSFs
  .y <- dplyr::select(y, SeqId, all_of(cal_names),  # select and rename
                      any_of(setNames("ColCheck", paste0("ColCheck", id_y))))
  # suffix 'y' in case `cal_names` is duplicated
  dplyr::left_join(x, .y, by = "SeqId", suffix = c("", id_y))
}
