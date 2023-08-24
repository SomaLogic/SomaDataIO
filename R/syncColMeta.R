#' Synchronize Col.Meta Attribute
#'
#' Uses `SeqId` matching to synchronize the attributes of
#' a `soma_adat` object that has extra `Col.Meta` in its attributes.
#'
#' @param data A `soma_adat` data object to update attributes.
#' @return An identical object to `data` with `Col.Meta` trimmed
#'   to match those in its columns.
#' @author Stu Field
#' @noRd
syncColMeta <- function(data) {
  col_meta <- attr(data, "Col.Meta")
  # no trim leading whitespace if 'else' below is to perform pattern match
  ft <- trimws(getAnalytes(data), which = "right")
  # if all features have `seq.` format; no need to match (speed)
  if ( all(grepl("^seq[.]", ft)) ) {
    new_seq <- gsub("^seq[.]", "", ft)
  } else {
    df <- locateSeqId(ft)
    new_seq <- substr(df$x, df$start, df$stop)
  }
  new_seq <- sub("\\.", "-", new_seq)
  k       <- match(new_seq, col_meta$SeqId)
  # Update the attributes -> Col.Meta information
  structure(data, Col.Meta = col_meta[k, ])
}
