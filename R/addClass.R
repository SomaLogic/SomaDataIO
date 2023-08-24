#' Add a Class to an Object
#'
#' Utility to add (prepend) a class(es) to existing objects.
#'
#' @param x The object to receive new class(es).
#' @param class Character. The name of additional class(es).
#' @return An object with new classes.
#' @author Stu Field
#' @seealso [class()], [typeof()], [structure()]
#' @examples
#' class(iris)
#'
#' addClass(iris, "new") |> class()
#'
#' addClass(iris, c("A", "B")) |> class()    # 2 classes
#'
#' addClass(iris, c("A", "data.frame")) |> class()    # no duplicates
#'
#' addClass(iris, c("data.frame", "A")) |> class()    # re-orders if exists
#' @export
addClass <- function(x, class) {
  if ( is.null(class) ) {
    warning("Passing `class = NULL` leaves class(x) unchanged.", call. = FALSE)
  }
  if ( any(is.na(class)) ) {
    stop("The `class` param cannot contain `NA`: ", .value(class), call. = FALSE)
  }
  new_class <- union(class, class(x))
  structure(x, class = new_class)
}
