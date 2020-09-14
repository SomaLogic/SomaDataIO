
#' These are dplyr verb methods for `soma_adat` class
#' @noRd
#' @importFrom tibble rownames_to_column column_to_rownames
NULL

#' @export
arrange.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
}

#' @export
mutate.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
}

#' @method filter soma_adat
#' @export
filter.soma_adat <- function(.data, ...) {
  atts <- attributes(.data)
  .data %<>% tibble::rownames_to_column()
  .data <- NextMethod()
  .data %>%
    tibble::column_to_rownames() %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
}

#' @export
select.soma_adat <- function(.data, ...) {
  .data <- NextMethod()
  .data %>%
    addClass("soma_adat") %>%
    syncColMeta()
}

#' @export
rename.soma_adat <- function(.data, ...) {
  addClass(NextMethod(), "soma_adat")
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
  structure(x, class = atts$class) %>%   # ensure same class returned
    addAttributes(atts)                  # add back original atts
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
  tbl <- tbl %>%    # duplicate rownames are inevitable if replace = TRUE
    tibble::rownames_to_column("rn")    # must fix them
  tbl <- NextMethod()
  tbl %>%
    dplyr::mutate(rn = remap_dupes(rn)) %>%
    tibble::column_to_rownames("rn") %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
}

#' @export
sample_n.soma_adat <- function(tbl, size, replace = FALSE,
                               weight = NULL, .env, ...) {
  atts <- attributes(tbl)
  tbl <- tbl %>%    # duplicate rownames are inevitable if replace = TRUE
    tibble::rownames_to_column("rn")    # must fix them
  tbl <- NextMethod()
  tbl %>%
    dplyr::mutate(rn = remap_dupes(rn)) %>%
    tibble::column_to_rownames("rn") %>%
    addClass("soma_adat") %>%
    addAttributes(atts)
}

#' Internal remapping for duplidated rownames following resampling.
#' Adds "-*" to the suffix for duplicates
#' @keywords internal
#' @noRd
remap_dupes <- function(x) {
  if ( any(duplicated(x)) ) {
    for ( i in unique(x) ) {
      L <- sum(x %in% i)
      if ( L > 1 ) {
        x[ x %in% i ] <- paste0(x[ x %in% i ], c("", paste0("-", 2:L)))
      }
    }
  }
  return(x)
}
