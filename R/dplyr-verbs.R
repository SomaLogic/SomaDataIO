
#' These are dplyr verb methods for `soma_adat` class
#' @noRd
NULL

#' @importFrom tibble as_tibble
#' @export
count.soma_adat <- function(x, ..., wt = NULL, sort = FALSE, name = "n",
                            .drop = dplyr::group_by_drop_default(x)) {

  x <- as_tibble(data.frame(x))
  NextMethod()
}

#' @export
arrange.soma_adat <- function(.data, ...) {
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".arrange_rn")
  .data <- NextMethod()
  .soma_adat_restore(.data, atts, ".arrange_rn")
}

#' @export
filter.soma_adat <- function(.data, ...) {
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".filter_rn")
  .data <- NextMethod()
  .soma_adat_restore(.data, atts, ".filter_rn")
}

#' @export
mutate.soma_adat <- function(.data, ...) {
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".mutate_rn")
  .data <- NextMethod()
  .soma_adat_restore(.data, atts, ".mutate_rn")
}

#' @export
select.soma_adat <- function(.data, ...) {
  # rownames must be handled differently in select()
  # b/c adding a column of rownames changes ncol() dimension
  atts  <- attributes(.data)
  .data <- NextMethod()
  addAttributes(.data, atts) |>       # do this before sync colmeta
    syncColMeta() |>                  # order sensitive
    .soma_adat_restore(atts, NULL) |> # add back orig attrs
    set_rn(atts$row.names)            # add back rownames
}

#' @export
rename.soma_adat <- function(.data, ...) {
  dots  <- match.call(expand.dots = FALSE)$...
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".rename_rn")
  .data <- NextMethod()
  if ( any(is.apt(dots)) ) {  # re-sync if renamed analytes
    warning(
      "You are renaming analytes. Modify the SomaScan menu with care.",
      call. = FALSE
    )
    .data <- syncColMeta(.data)
  }
  .soma_adat_restore(.data, atts, ".rename_rn")
}

#' @export
left_join.soma_adat <- function(x, y, by = NULL, copy = FALSE,
                                suffix = c(".x", ".y"), ...) {
  if ( !has_rn(x) ) {
    # don't maintain rownames if don't already exist
    x <- NextMethod()
  } else {
    x <- rn2col(x, ".ljoin_rn")
    x <- NextMethod()
    x <- col2rn(x, ".ljoin_rn")
  }
  x
}

#' @export
anti_join.soma_adat <-  function(x, y, by = NULL, copy = FALSE, ...) {
  x <- rn2col(x, ".ajoin_rn")
  x <- NextMethod()
  col2rn(x, ".ajoin_rn")
}

#' @export
right_join.soma_adat <- left_join.soma_adat

#' @export
inner_join.soma_adat <- left_join.soma_adat

#' @export
full_join.soma_adat <- left_join.soma_adat

#' @export
semi_join.soma_adat <- anti_join.soma_adat


#' @export
slice.soma_adat <- function(.data, ..., .preserve = FALSE) {
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".slice_rn")
  .data <- NextMethod()
  .soma_adat_restore(.data, atts, ".slice_rn")
}

#' @export
slice_sample.soma_adat <- function(.data, ..., n, prop, weight_by = NULL,
                                   replace = FALSE) {
  # just a pass-thru; slice() now does the work
  .data <- NextMethod()
  .data
}

#' @export
sample_frac.soma_adat <- function(tbl, size = 1, replace = FALSE,
                                  weight = NULL, .env = NULL, ...) {
  # just a pass-thru; slice() now does the work
  tbl <- NextMethod()
  tbl
}

#' @export
sample_n.soma_adat <- function(tbl, size, replace = FALSE,
                               weight = NULL, .env = NULL, ...) {
  # just a pass-thru; slice() now does the work
  tbl <- NextMethod()
  tbl
}

#' @export
group_by.soma_adat <- function(.data, ..., .add = FALSE,
                               .drop = dplyr::group_by_drop_default(.data)) {
  .rn <- rownames(.data)
  .data <- NextMethod()
  .data <- structure(.data, row.names = .rn,
                     class = c("soma_adat", class(.data)))
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
ungroup.soma_adat <- function(x, ...) {
  atts  <- attributes(x)
  .data <- NextMethod()
  .data <- addAttributes(.data, atts) |> .sort_attr(names(atts))
  .data <- structure(.data, row.names = atts$row.names,
                     class = c("soma_adat", "data.frame"))
  stopifnot(is_intact_attr(.data))
  .data
}


# helper to restore `soma_adat` attributes,
# ensure classes maintained, etc.
# check for intact attributes
.soma_adat_restore <- function(obj, orig_attr, rn_col = NULL) {
  class(obj) <- orig_attr$class            # do this first for dispatch!
  if ( !is.null(rn_col) ) {
    obj <- col2rn(obj, rn_col)             # put back rownames
  }
  obj <- addAttributes(obj, orig_attr)     # add back missing attrs
  obj <- .sort_attr(obj, names(orig_attr)) # maintain orig order
  stopifnot(is_intact_attr(obj))           # sanity check
  obj
}

# maintain original attr order
.sort_attr <- function(x, names) {
  x_names <- names(attributes(x))
  new_order <- match(names, x_names, nomatch = 0L)
  attributes(x) <- attributes(x)[new_order]
  invisible(x)
}
