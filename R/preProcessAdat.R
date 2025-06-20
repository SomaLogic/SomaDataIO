#' Pre-Process an ADAT Object for Analysis
#'
#' Pre-process an ADAT file containing raw analyte RFU values in preparation
#' for analysis. For more details please refer to the [pre-processing how-to
#' article](https://somalogic.github.io/SomaDataIO/dev/articles/pre-processing.html)
#'
#' The `soma_adat` object is pre-processed with the following steps:
#'
#' 1. Filter features -> down to human protein analytes
#' 2. Filter samples -> by the following order and criteria:
#'    a) Retain study samples only (dropping buffer, calibrator, and QC samples)
#'    b) Only those that pass default normalization acceptance criteria
#'    c) Those not identified as outliers.
#' 3. Data QC -> plots of normalization scale factors by clinical covariates
#' 4. Transformations -> log10, center, and scale analyte RFU values
#'
#' @param adat A `soma_adat` object created using [read_adat()], including
#' SeqId columns (`seq.xxxxx.xx`) containing raw RFU values.
#' @param filter.features Logical. Should non-human protein features (SeqIds) be
#' dropped? Default is `TRUE`.
#' @param filter.controls Logical. Should SomaScan technical control samples
#' be dropped? If `TRUE`, this retains all samples where `SampleType = "Sample"`
#' (study samples) and discards all others including buffer, calibrator, and
#' QC control samples. Default is `TRUE`.
#' @param filter.qc Logical. If `TRUE` only samples that pass default
#' normalization acceptance criteria will be retained. Default is `TRUE`.
#' @param filter.outliers Logical. Should the `adat` object drop outlier
#' samples? An outlier sample is defined by >= 5% of filtered SeqIds exceeding
#' +/- 6 MAD and 5x fold-change from the median signal. This filter is typically
#' appropriate for studies on plasma, serum, and other biological matrices
#' generally exhibiting homeostatic characteristics. For studies on matrices
#' such as tissue homogenate, cell culture, or study designs containing
#' client-provided background lysis buffer controls (or similar), this filter
#' will likely not be appropriate. Default is `FALSE`. If set to `TRUE`
#' it is highly recommended that `filter.controls` is also set to `TRUE`
#' @param data.qc Character. Character vector of variable names for which data
#' QC plots are desired. Default is `NULL`, which does not generate any QC
#' plots.  Note: These plots are for visual inspection only, no samples or
#' features are dropped from the output `soma_adat` object.
#' @param log.10 Logical. Should the RFU values be log10 transformed?
#' Default is `FALSE`.
#' @param center.scale Logical. Should the RFU values be Z-transformed
#' (centered and scaled)? Default is `FALSE`. If set to set to `TRUE`
#' it is highly recommended that `log.10` is also set to `TRUE`
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
                           filter.controls = TRUE,
                           filter.qc = TRUE,
                           filter.outliers = FALSE,
                           data.qc = NULL,
                           log.10 = FALSE,
                           center.scale = FALSE) {

  stopifnot("`adat` must be a class `soma_adat` object" = is.soma_adat(adat))

  # default feature checks -> filter
  if ( filter.features ) {
    # keep only human proteins from analyte annotations
    human_prots <- getAnalyteInfo(adat) |>
      dplyr::filter(Type == "Protein" & Organism == "Human") |>
      dplyr::filter(!grepl("^Internal Use Only", TargetFullName))

    # Identify SeqIds that differ in the adat object
    discard <- setdiff(grep("^seq\\.", colnames(adat), value = TRUE),
                       human_prots$AptName)

    # Discard non-human, non-protein features
    adat <- adat |> dplyr::select(-all_of(discard))

    # summary information to print
    n_feats_dropped <- length(discard)

    if ( n_feats_dropped > 0 ) {
      .done("{.val {n_feats_dropped}} non-human protein features were removed.")
    }

    if ( "ColCheck" %in% names(human_prots) ) {
      n_feats_flagged <- human_prots |> filter(ColCheck == "FLAG") |> nrow()

      if ( n_feats_flagged > 0 ) {
        .todo("{.val {n_feats_flagged}} human proteins did not pass standard QC
          acceptance criteria and were flagged in `ColCheck`.  These features
          were not removed, as they still may yield useful information in an
          analysis, but further evaluation may be needed.")
      }
    } else {
      .todo("`ColCheck` is missing from the column annotation data. Further
          assessment of the human protein features may be needed to check if
          they pass standard QC acceptance criteria.")
    }
  }

  # default sample level checks -> filter
  if ( filter.controls ) {
    # summary information to print
    n_buffer     <- adat |> filter(SampleType == "Buffer") |> nrow()
    n_calibrator <- adat |> filter(SampleType == "Calibrator") |> nrow()
    n_qc         <- adat |> filter(SampleType == "QC") |> nrow()

    # keep only clinical samples, dropping buffer, calibrator, and QC
    adat <- adat |> filter(SampleType == "Sample")

    if ( n_buffer > 0 ) {
      .done("{.val {n_buffer}} buffer samples were removed.")
    }
    if ( n_calibrator > 0 ) {
      .done("{.val {n_calibrator}} calibrator samples were removed.")
    }
    if (n_qc > 0 ) {
      .done("{.val {n_qc}} QC samples were removed.")
    }
  }

  if ( filter.qc ) {
    n_samples_flagged    <- adat |> filter(!RowCheck == "PASS") |> nrow()

    # drop samples which do not pass standard conservative acceptance criteria
    # for normalization scale factors
    adat <- adat |> filter(RowCheck == "PASS")

    if ( n_samples_flagged > 0 ) {
      .done("{.val {n_samples_flagged}} samples flagged in `RowCheck` did not
            pass standard normalization acceptance criteria (0.4 <= x <= 2.5)
            and were removed.")
    }
  }

  if( filter.outliers ) {
    # get count of sample level outliers by RFU
    rfu_outliers <- suppressMessages(getOutlierIds(calcOutlierMap(adat)))
    n_outliers <- nrow(rfu_outliers)
    adat <- adat |> filter(!dplyr::row_number() %in% rfu_outliers$idx)

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
