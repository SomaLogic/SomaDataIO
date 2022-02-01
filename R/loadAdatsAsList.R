#' Load ADAT files as a list
#'
#' Load a series of ADATs and return a list of `soma_adat`
#' objects, one for each ADAT file.
#' [collapseAdats()] concatenates a list of ADATs from [loadAdatsAsList()],
#' while maintaining the relevant attribute entries (mainly the `HEADER`
#' element). This makes writing out the final object possible without the
#' loss of `HEADER` information.
#'
#' @family IO
#' @param files A character string of files to load.
#' @param collapse Logical. Should the resulting list of ADATs be
#' collapsed into a single ADAT object?
#' @param verbose Logical. Should the function call be run in *verbose*
#' mode.
#' @param ... Additional arguments passed to [read_adat()].
#' @return A list of ADATs, each a `soma_adat` object corresponding to a file
#' in of the argument `files`. The list names are derived from the file names.
#' @author Stu Field
#' @seealso [read_adat()]
#' @examples
#' files <- system.file("example", package = "SomaDataIO") %>%
#'   dir(pattern = "[.]adat$", full.names = TRUE) %>% rev()
#'
#' # 2 files in directory
#' files
#'
#' adats <- loadAdatsAsList(files)
#'
#' # collapse into 1 ADAT
#' all <- collapseAdats(adats)
#'
#' # Alternativly use the `collapse = TRUE`
#' coll <- loadAdatsAsList(files, collapse = TRUE)
#'
#' identical(coll, all)
#'
#' # Lastly, `rbind` on the `union` of columns also possible
#' # but produces numerous NAs for missing cells
#' # And will break the ADAT attributes
#' union_adat <- dplyr::bind_rows(adats, .id = "SourceFile")
#' @importFrom stats setNames
#' @export
loadAdatsAsList <- function(files, collapse = FALSE, verbose = interactive(), ...) {
  files <- setNames(files, cleanNames(basename(files)))
  res <- lapply(files, function(.file) {
    x <- tryCatch(read_adat(.file, ...), error = function(e) NULL)
    if ( is.null(x) ) {
      .oops("Failed to load: {.value(.file)}")
    } else if ( verbose ) {
      .done("Loading: {.value(.file)}")
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
#' @details
#' __Note 1:__ the `rbind` occurs on the  *intersect* of the common columns
#' names, unique columns are silently dropped.
#'
#' __Note 2:__ If `rbind` on the *union* is desired, use [bind_rows()],
#' however this results in `NAs` in non-intersecting columns. For many files
#' with little variable intersection, a sparse RFU-matrix will result.
#' See `Examples` below.
#'
#' @param x A list of `soma_adat` class objects loaded via [loadAdatsAsList()].
#' @importFrom dplyr select
#' @export
collapseAdats <- function(x) {
  is_adat <- vapply(x, is.soma_adat, FUN.VALUE = NA)
  stopifnot(all(is_adat))
  common <- Reduce(intersect, lapply(x, names))   # nolint common df names
  # rm names so rownames are re-constructed via `rbind()`
  new <- lapply(unname(x), function(.x) dplyr::select(.x, common))
  new <- do.call(rbind, new)
  new_header <- lapply(x, attr, which = "Header.Meta") %>%
    lapply(`[[`, "HEADER")
  attributes(new)$Header.Meta$HEADER <- Reduce(`c`, new_header)
  nms <- names(attributes(x[[1L]]))         # attr order or 1st adat
  attributes(new) <- attributes(new)[nms]   # orig order
  new
}
