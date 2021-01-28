
#' These are dplyr verb methods for `soma_adat` class
#' @noRd
#' @importFrom tibble rownames_to_column column_to_rownames
NULL

#' @export
arrange.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data <- .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  .data
}

#' @export
mutate.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data <- .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  .data
}

#' @method filter soma_adat
#' @export
filter.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data <- .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
  attributes(.data) <- attributes(.data)[names(atts)]   # orig order
  .data
}

#' @export
select.soma_adat <- function(.data, ...) {
  nms   <- names(attributes(.data))
  .data <- NextMethod()
  .data <- .data %>%
    addClass("soma_adat") %>%
    syncColMeta()
  attributes(.data) <- attributes(.data)[nms]   # orig order
  .data
}

#' @export
rename.soma_adat <- function(.data, ...) {
  nms   <- names(attributes(.data))
  .data <- NextMethod()
  .data <- addClass(.data, "soma_adat")
  attributes(.data) <- attributes(.data)[nms]   # orig order
  .data
}

#' @export
ungroup.soma_adat <- function(x, ...) {
  .data <- NextMethod()
  structure(.data, class = c("soma_adat", "data.frame"))
}

#' @export
left_join.soma_adat <- function(x, y, by = NULL, copy = FALSE,
                                suffix = c(".x", ".y"), ...) {
  atts <- attributes(x)
  # don't maintain rownames if they're implicit
  if ( is.na(.row_names_info(x, type = 0L)[1L]) ) {
    x <- NextMethod()
  } else {
    x %<>% tibble::rownames_to_column()
    x <- NextMethod()
    x %<>% tibble::column_to_rownames()
  }
  x <- structure(x, class = atts$class) %>%   # ensure same class returned
    addAttributes(atts)                       # add back original atts
  attributes(x) <- attributes(x)[names(atts)]   # orig order
  x
}

#' @export
right_join.soma_adat <- left_join.soma_adat

#' @export
inner_join.soma_adat <- left_join.soma_adat

#' @export
full_join.soma_adat  <- left_join.soma_adat

#' @export
anti_join.soma_adat <-  function(x, y, by = NULL, copy = FALSE, ...) {
  x %<>% tibble::rownames_to_column()
  x <- NextMethod()
  x %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat")
}

#' @export
semi_join.soma_adat <- anti_join.soma_adat

#' @export
sample_frac.soma_adat <- function(tbl, size = 1, replace = FALSE,
                                  weight = NULL, .env, ...) {
  atts <- attributes(tbl)
  tbl <- tbl %>%    # duplicate rownames can occur if replace = TRUE
    tibble::rownames_to_column("rn")
  tbl <- NextMethod()
  tbl <- tbl %>%
    dplyr::mutate(rn = make.unique(rn, "-")) %>%  # fix them here
    tibble::column_to_rownames("rn") %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
  attributes(tbl) <- attributes(tbl)[names(atts)]   # orig order
  tbl
}

#' @export
sample_n.soma_adat <- function(tbl, size, replace = FALSE,
                               weight = NULL, .env, ...) {
  atts <- attributes(tbl)
  tbl <- tbl %>%    # duplicate rownames can occur if replace = TRUE
    tibble::rownames_to_column("rn")
  tbl <- NextMethod()
  tbl <- tbl %>%
    dplyr::mutate(rn = make.unique(rn, "-")) %>%  # fix them here
    tibble::column_to_rownames("rn") %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
  attributes(tbl) <- attributes(tbl)[names(atts)]   # orig order
  tbl
}
