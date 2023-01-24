
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
  # the `[.soma_adat` method fixes attr for us here
  .data <- rn2col(.data, ".arrange_rn")
  .data <- NextMethod()
  .data <- col2rn(.data, ".arrange_rn")
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
filter.soma_adat <- function(.data, ...) {
  # the `[.soma_adat` method fixes attr for us here
  .data <- rn2col(.data, ".filter_rn")
  .data <- NextMethod()
  .data <- col2rn(.data, ".filter_rn")
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
mutate.soma_adat <- function(.data, ...) {
  atts  <- attributes(.data)
  .data <- rn2col(.data, ".mutate_rn")
  .data <- NextMethod()
  .data <- addAttributes(.data, atts)
  .data <- col2rn(.data, ".mutate_rn")
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
select.soma_adat <- function(.data, ...) {
  # the `[.soma_adat` method fixes rn for us here
  atts  <- attributes(.data)
  .data <- NextMethod()
  .data <- syncColMeta(addAttributes(.data, atts))
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
rename.soma_adat <- function(.data, ...) {
  dots  <- match.call(expand.dots = FALSE)$...
  .data <- NextMethod()
  if ( any(is.apt(dots)) ) {  # re-sync if renamed analytes
    warning(
      "You are renaming analytes. Modify the SomaScan menu with care.",
      call. = FALSE
    )
    .data <- syncColMeta(.data)
  }
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
left_join.soma_adat <- function(x, y, by = NULL, copy = FALSE,
                                suffix = c(".x", ".y"), ...) {
  # don't maintain rownames if they don't exist to begin with
  if ( !has_rn(x) ) {
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
  .data <- rn2col(.data, ".slice_rn")
  .data <- NextMethod()
  .data <- col2rn(.data, ".slice_rn")
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
slice_sample.soma_adat <- function(.data, ..., n, prop, weight_by = NULL,
                                   replace = FALSE) {
  # now just a pass-thru; slice() does the work; just check atts
  .data <- NextMethod()
  stopifnot(is_intact_attr(.data))
  .data
}

#' @export
sample_frac.soma_adat <- function(tbl, size = 1, replace = FALSE,
                                  weight = NULL, .env = NULL, ...) {
  # now just a pass-thru; slice() does the work; just check atts
  tbl     <- NextMethod()
  stopifnot(is_intact_attr(tbl))
  tbl
}

#' @export
sample_n.soma_adat <- function(tbl, size, replace = FALSE,
                               weight = NULL, .env = NULL, ...) {
  # now just a pass-thru; slice() does the work; just check atts
  tbl <- NextMethod()
  stopifnot(is_intact_attr(tbl))
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
  addClass(.data, "soma_adat")
}

#' @export
ungroup.soma_adat <- function(x, ...) {
  atts  <- attributes(x)
  .data <- NextMethod()
  .data <- addAttributes(.data, atts)
  .data <- structure(.data, row.names = atts$row.names,
                     class = c("soma_adat", "data.frame"))
  stopifnot(is_intact_attr(.data))
  .data
}
