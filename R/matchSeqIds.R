#' Match SeqIds
#'
#' @describeIn SeqId
#'   matches two character vectors on the basis of their
#'   intersecting `SeqIds`. Note that elements in `y` not
#'   containing a `SeqId` regular expression are silently dropped.
#'
#' @param y Character. A second vector of `AptNames` containing `SeqIds`
#'   to match against those in contained in `x`.
#'   For [matchSeqIds()] these values are returned if there are matching elements.
#' @param order.by.x Logical. Order the returned character string by
#'   the `x` (first) argument?
#' @return [matchSeqIds()]: a character string corresponding to values
#'   in `y` of the intersect of `x` and `y`. If no matches are
#'   found, `character(0)`.
#' @seealso [intersect()]
#' @examples
#'
#' # SeqId Matching
#' x <- c("seq.4554.56", "seq.3714.49", "PlateId")
#' y <- c("Group", "3714-49", "Assay", "4554-56")
#' matchSeqIds(x, y)
#' matchSeqIds(x, y, order.by.x = FALSE)
#'
#' @importFrom stats setNames
#' @export
matchSeqIds <- function(x, y, order.by.x = TRUE) {
  # getSeqId() returns NA for non-Aptamer elements
  x_seqIds <- getSeqId(x, TRUE)
  x_seqIds <- x_seqIds[!is.na(x_seqIds)] # rm NAs in 'x'
  y_seqIds <- getSeqId(y, TRUE)
  y_lookup <- setNames(y, y_seqIds)      # create hashmap
  y_seqIds <- y_seqIds[!is.na(y_seqIds)] # rm NAs in 'y'
  if ( order.by.x ) {
    order_seqs <- intersect(x_seqIds, y_seqIds)
  } else {
    order_seqs <- intersect(y_seqIds, x_seqIds)
  }
  if ( length(order_seqs) == 0L ) {
    return(character(0))
  }
  unname(y_lookup[order_seqs])
}


#' Get SeqId Matches
#'
#' @describeIn SeqId
#'   matches two character vectors on the basis of their intersecting *SeqIds*
#'   only (irrespective of the `GeneID`-prefix). This produces a two-column
#'   data frame which then can be used as to map between the two sets.
#'
#'   The final order of the matches/rows is by the input
#'   corresponding to the *first* argument (`x`).
#'
#'   By default the data frame is invisibly returned to
#'   avoid dumping excess output to the console (see the `show =` argument.)
#'
#' @param show Logical. Return the data frame visibly?
#' @return [getSeqIdMatches()]: a \eqn{n x 2} data frame, where `n` is the
#'   length of the intersect of the matching `SeqIds`.
#'   The data frame is named by the passed arguments, `x` and `y`.
#' @examples
#' # vector of features
#' feats <- getAnalytes(example_data)
#'
#' match_df <- getSeqIdMatches(feats[1:100], feats[90:500])  # 11 overlapping
#' match_df
#'
#' a <- utils::head(feats, 15)
#' b <- withr::with_seed(99, sample(getSeqId(a)))   # => SeqId & shuffle
#' (getSeqIdMatches(a, b))                          # sorted by first vector "a"
#' @importFrom stats setNames
#' @export
getSeqIdMatches <- function(x, y, show = FALSE) {
  # getSeqId() returns NA for non-Aptamer matches
  x_seqIds <- getSeqId(x, trim.version = TRUE)
  x_seqIds <- unique(x_seqIds[!is.na(x_seqIds)])
  y_seqIds <- getSeqId(y, trim.version = TRUE)
  y_seqIds <- unique(y_seqIds[!is.na(y_seqIds)])
  inter    <- intersect(x_seqIds, y_seqIds)
  L1       <- matchSeqIds(inter, x, order.by.x = TRUE)
  L2       <- matchSeqIds(inter, y, order.by.x = TRUE)

  if ( length(c(L1, L2)) == 0L ) {
    .oops("No matches between lists")
    show <- TRUE
  }

  nms <- c(match.call()$x, match.call()$y)
  M   <- setNames(data.frame(L1, L2, stringsAsFactors = FALSE), nms)

  if ( show ) {
    M
  } else {
    invisible(M)
  }
}
