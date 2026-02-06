# Binary Classification

------------------------------------------------------------------------

## Classification via Logistic Regression

Although targeted statistical analyses are beyond the scope of the
`SomaDataIO` package, below is an example analysis that typical
users/customers would perform on ‘SomaScan’ data.

It is not intended to be a definitive guide in statistical analysis and
existing packages do exist in the `R` ecosystem that perform parts or
extensions of these techniques. Many variations of the workflow below
exist, however the framework highlights how one could perform standard
*preliminary* analyses on ‘SomaScan’ data.

## Load Libraries

``` r
library(SomaDataIO)
library(dplyr)
library(tidyr)
library(purrr)
```

## Data Preparation

``` r
# the `example_data` .adat object
# download from `SomaLogic-Data` repo or directly via bash command:
# `wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/main/example_data.adat`
# then read in to R with:
# example_data <- read_adat("example_data.adat")
dim(example_data)
#> [1]  192 5318

table(example_data$SampleType)
#> 
#>     Buffer Calibrator         QC     Sample 
#>          6         10          6        170

# prepare data set for analysis using `preProcessAdat()`
cleanData <- example_data |>
  preProcessAdat(
    filter.features = TRUE,      # remove non-human protein features
    filter.controls = TRUE,      # remove control samples
    filter.rowcheck = TRUE,      # retain only passing samples
    log.10          = TRUE,      # log10 transform
    center.scale    = TRUE       # center/scale analytes
  )
#> ✔ 305 non-human protein features were removed.
#> → 214 human proteins did not pass standard QC
#> acceptance criteria and were flagged in `ColCheck`.
#> ✔ 6 buffer samples were removed.
#> ✔ 10 calibrator samples were removed.
#> ✔ 6 QC samples were removed.
#> ✔ 2 samples flagged in `RowCheck` did not
#> pass standard normalization acceptance criteria (0.4 <= x <= 2.5)
#> and were removed.
#> ✔ RFU features were log-10 transformed.
#> ✔ RFU features were centered and scaled.

# drop any missing values in Sex, and convert to binary 0/1 variable
cleanData <- cleanData |> 
  drop_na(Sex) |>                              # rm NAs if present
  mutate(Group = as.numeric(factor(Sex)) - 1)  # map Sex -> 0/1

table(cleanData$Sex)
#> 
#>  F  M 
#> 85 83

table(cleanData$Group)    # F = 0; M = 1
#> 
#>  0  1 
#> 85 83
```

## Set up Train/Test Data

``` r
# idx = hold-out 
# seed resulting in 50/50 class balance
idx   <- withr::with_seed(3, sample(1:nrow(cleanData), size = nrow(cleanData) - 50))
train <- cleanData[idx, ]
test  <- cleanData[-idx, ]

# assert no overlap
isTRUE(
  all.equal(intersect(rownames(train), rownames(test)), character(0))
)
#> [1] TRUE
```

## Logistic Regression

We use the `cleanData`, `train`, and `test` data objects from above.

### Predict Sex

``` r
LR_tbl <- getAnalyteInfo(train) |>
  select(AptName, SeqId, Target = TargetFullName, EntrezGeneSymbol, UniProt) |>
  mutate(
    formula  = map(AptName, ~ as.formula(paste("Group ~", .x))),  # create formula
    model    = map(formula, ~ stats::glm(.x, data = train, family = "binomial", model = FALSE)),  # fit glm()
    beta_hat = map(model, coef) |> map_dbl(2L),     # pull out coef Beta
    p.value  = map2_dbl(model, AptName, ~ {
      summary(.x)$coefficients[.y, "Pr(>|z|)"] }),  # pull out p-values
    fdr      = p.adjust(p.value, method = "BH")     # FDR correction multiple testing
  ) |>
  arrange(p.value) |>            # re-order by `p-value`
  mutate(rank = row_number())    # add numeric ranks

LR_tbl
#> # A tibble: 4,979 × 11
#>    AptName      SeqId   Target EntrezGeneSymbol UniProt formula   model
#>    <chr>        <chr>   <chr>  <chr>            <chr>   <list>    <lis>
#>  1 seq.6580.29  6580-29 Pregn… PZP              P20742  <formula> <glm>
#>  2 seq.5763.67  5763-67 Beta-… DEFB104A         Q8WTQ1  <formula> <glm>
#>  3 seq.7926.13  7926-13 Kunit… SPINT3           P49223  <formula> <glm>
#>  4 seq.3032.11  3032-11 Folli… CGA FSHB         P01215… <formula> <glm>
#>  5 seq.7139.14  7139-14 SLIT … SLITRK4          Q8IW52  <formula> <glm>
#>  6 seq.16892.23 16892-… Ecton… ENPP2            Q13822  <formula> <glm>
#>  7 seq.2953.31  2953-31 Lutei… CGA LHB          P01215… <formula> <glm>
#>  8 seq.9282.12  9282-12 Cyste… CRISP2           P16562  <formula> <glm>
#>  9 seq.4914.10  4914-10 Human… CGA CGB          P01215… <formula> <glm>
#> 10 seq.2474.54  2474-54 Serum… APCS             P02743  <formula> <glm>
#> # ℹ 4,969 more rows
#> # ℹ 4 more variables: beta_hat <dbl>, p.value <dbl>, fdr <dbl>,
#> #   rank <int>
```

### Fit Model \| Calculate Performance

Next, select features for the model fit. We have a good idea of
reasonable `Sex` markers from prior knowledge (`CGA*`), and fortunately
many of these are highly ranked in `LR_tbl`. Below we fit a 4-marker
logistic regression model from cherry-picked gender-related features:

``` r
# AptName is index key between `LR_tbl` and `train`
feats <- LR_tbl$AptName[c(1L, 3L, 5L, 7L)]
form  <- as.formula(paste("Group ~", paste(feats, collapse = "+")))
fit   <- glm(form, data = train, family = "binomial", model = FALSE)
pred  <- tibble(
  true_class = test$Sex,                                         # orig class label
  pred       = predict(fit, newdata = test, type = "response"),  # prob. 'Male'
  pred_class = ifelse(pred < 0.5, "F", "M"),                     # class label
)
conf <- table(pred$true_class, pred$pred_class, dnn = list("Actual", "Predicted"))
tp   <- conf[2L, 2L]
tn   <- conf[1L, 1L]
fp   <- conf[1L, 2L]
fn   <- conf[2L, 1L]

# Confusion matrix
conf
#>       Predicted
#> Actual  F  M
#>      F 27  1
#>      M  4 18

# Classification metrics
tibble(Sensitivity = tp / (tp + fn),
       Specificity = tn / (tn + fp),
       Accuracy    = (tp + tn) / sum(conf),
       PPV         = tp / (tp + fp),
       NPV         = tn / (tn + fn)
)
#> # A tibble: 1 × 5
#>   Sensitivity Specificity Accuracy   PPV   NPV
#>         <dbl>       <dbl>    <dbl> <dbl> <dbl>
#> 1       0.818       0.964      0.9 0.947 0.871
```
