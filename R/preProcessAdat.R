#' Pre-Process an ADAT Object for Analysis
#'
#' Pre-process an ADAT file containing raw analyte RFU values in preparation
#' for analysis.
#'
#' The `soma_adat` object is pre-processed with the following steps:
#'
#' 1. Filter features -> down to human protein analytes
#' 2. Filter samples -> down to clinical samples (dropping buffer, calibrator, and
#'    QC samples) that pass default normalization acceptance criteria, and
#'    dropping sample-level outliers by RFU values.
#' 3. Data QC -> plots of normalization scale factors by clinical covariates
#' 4. Transformations -> log10, center, and scale analyte RFU values
#'
#' @param adat A `soma_adat` object created using [read_adat()], including
#' SeqId columns (`seq.xxxxx.xx`) containing raw RFU values.
#' @param filter.features Logical. Should non-human protein features be
#' dropped? Default is `TRUE`.
#' @param filter.samples Logical. Should buffer, calibrator, and QC samples be
#' dropped, along with samples that do not pass default normalization acceptance
#' criteria or are identified as sample level RFU outliers?  Default is `TRUE`.
#' @param data.qc Character. Character vector of variable names for which data
#' QC plots are desired. Default is `NULL`, which does not generate any QC
#' plots.  Note: These plots are for visual inspection only, no samples or
#' features are dropped from the output `soma_adat` object.
#' @param log.10 Logical. Should the RFU values be log10 transformed?
#' Default is `TRUE`.
#' @param center.scale Logical. Should the RFU values be Z-transformed
#' (centered and scaled)? Default is `TRUE`.
#' @return A `soma_adat` object.
#' @author Caleb Scheidel
#' @examples
#' preProcessAdat(example_data, data.qc = c("Age", "Sex"))
#' @importFrom dplyr across all_of mutate row_number select
#' @importFrom ggplot2 aes facet_wrap ggplot geom_boxplot geom_hline geom_point
#' @importFrom ggplot2 scale_color_manual scale_fill_manual theme theme_bw ylim
#' @importFrom tidyr pivot_longer
#' @export
preProcessAdat <- function(adat,
                           filter.features = TRUE,
                           filter.samples = TRUE,
                           data.qc = NULL,
                           log.10 = TRUE,
                           center.scale = TRUE) {

  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

  # default feature checks -> filter
  if ( filter.features ) {
    # keep only human proteins from analyte annotations
    human_prots <- getAnalyteInfo(adat) |>
      filter(Type == "Protein" & Organism == "Human")

    # Identify SeqIds that differ in the adat object
    discard <- setdiff(grep("^seq\\.", colnames(adat), value = TRUE),
                       human_prots$AptName)

    # Discard non-human, non-protein features
    adat <- adat |> dplyr::select(-all_of(discard))

    # summary information to print
    n_feats_dropped <- length(discard)
    n_feats_flagged <- human_prots |> filter(ColCheck == "FLAG") |> nrow()

    if ( n_feats_dropped > 0 ) {
      .done("{.val {n_feats_dropped}} non-human protein features were removed.")
    }

    if ( n_feats_flagged > 0 ) {
      .todo("{.val {n_feats_flagged}} human proteins did not pass standard QC
          acceptance criteria and were flagged in `ColCheck`.  These features
          were not removed, as they still may yield useful information in an
          analysis, but further evaluation may be needed.")
    }
  }

  # default sample level checks -> filter
  if ( filter.samples ) {
    # summary information to print
    n_buffer     <- adat |> filter(SampleType == "Buffer") |> nrow()
    n_calibrator <- adat |> filter(SampleType == "Calibrator") |> nrow()
    n_qc         <- adat |> filter(SampleType == "QC") |> nrow()
    n_samples_flagged    <- adat |> filter(RowCheck == "FLAG") |> nrow()

    # keep only clinical samples, dropping buffer, calibrator, and QC
    adat <- adat |> filter(SampleType == "Sample")

    # drop samples which do not pass standard conservative acceptance criteria
    # for normalization scale factors
    adat <- adat |> filter(RowCheck == "PASS")

    # get count of sample level outliers by RFU
    rfu_outliers <- suppressMessages(getFlaggedIds(calcOutlierMap(adat)))
    n_outliers <- nrow(rfu_outliers)
    adat <- adat |> filter(!dplyr::row_number() %in% rfu_outliers$idx)

    if ( n_buffer > 0 ) {
      .done("{.val {n_buffer}} buffer samples were removed.")
    }
    if ( n_calibrator > 0 ) {
      .done("{.val {n_calibrator}} calibrator samples were removed.")
    }
    if (n_qc > 0 ) {
      .done("{.val {n_qc}} QC samples were removed.")
    }
    if ( n_samples_flagged > 0 ) {
      .done("{.val {n_samples_flagged}} samples flagged in `RowCheck` did not
            pass standard normalization acceptance criteria (0.4 <= x <= 2.5)
            and were removed.")
    }
    if ( n_outliers > 0 ) {
      .done("{.val {n_outliers}} samples were detected as outliers by RFU values
            using the default flagging proportion of 0.05, and were removed.")
    }

  }

  # default log10 transformations
  if ( log.10 ) {
    adat <- log10(adat)

    .done("RFU features were log-10 transformed.")
  }

  # default center scale transformations
  if ( center.scale ) {
    # center/scale
    center_scale <- function(.x) {    # .x = numeric vector
      out <- .x - mean(.x)  # center
      out / sd(out)         # scale
    }

    adat <- adat |>
      mutate(across(getAnalytes(adat), center_scale))

    .done("RFU features were centered and scaled.")
  }

  # default QC plots
  if ( !is.null(data.qc) ) {
    # stop if passed variables are not in adat
    stopifnot(
      "All variable names passed in `data.qc` argument must exist in `adat`" =
      lapply(data.qc, function(.x) .x %in% colnames(adat)) |> unlist() |> all()
    )

    # variable types - character or numeric
    vars <- lapply(data.qc, function(.x) class(adat[[.x]]))
    names(vars) <- data.qc

    # pull normalization scale factor variable names from ADAT
    norm_vars <- grep("^[Nn]orm[Ss]cale|^Med\\.Scale\\.",
                      names(adat), value = TRUE)

    .todo("Data QC plots were generated:")
    plts <- list()
    for ( i in data.qc ) {
      v <- as.symbol(i)
      if ( is.numeric(adat[[i]]) ) {
        plts[[i]] <- adat |>
          select(SampleId, !!v, all_of(norm_vars)) |>
          tidyr::pivot_longer(!c(SampleId, !!v),
                              names_to = "Normalization Scale Factor",
                              values_to = "Value") |>
          ggplot(aes(x = !!v, y = Value, color = `Normalization Scale Factor`)) +
          geom_point() +
          ylim(0, 2.6) +
          geom_hline(yintercept  = 0.4, linetype = "dashed", color = "red") +
          geom_hline(yintercept  = 2.5, linetype = "dashed", color = "red") +
          theme_bw() +
          scale_color_manual(values = c("#4067E2", "#59CFDB", "#DB40EF")) +
          facet_wrap(~`Normalization Scale Factor`) +
          theme(legend.position = "none")
      } else if ( is.character(adat[[i]]) ) {
        plts[[i]] <- adat |>
          select(SampleId, !!v, all_of(norm_vars)) |>
          tidyr::pivot_longer(!c(SampleId, !!v),
                              names_to = "Normalization Scale Factor",
                              values_to = "Value") |>
          ggplot(aes(x = `Normalization Scale Factor`, y = Value, fill = !!v)) +
          geom_boxplot() +
          ylim(0, 2.6) +
          geom_hline(yintercept  = 0.4, linetype = "dashed", color = "red") +
          geom_hline(yintercept  = 2.5, linetype = "dashed", color = "red") +
          theme_bw() +
          scale_fill_manual(values = c("#4067E2", "#59CFDB"))
      } else {
        stop("Variables passed in `data.qc` argument must be either character
             or numeric!", call. = FALSE)
      }
    }

    print(plts)
  }

  return(adat)
}
