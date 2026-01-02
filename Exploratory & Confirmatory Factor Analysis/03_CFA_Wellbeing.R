# Validate a two-factor well-being structure (Positive vs Negative) 
# derived from EFA in Assessment 1 using independent data (Assessment 2).

# Load libraries ----
library(lavaan)
library(dplyr)
library(semTools)

# Load data ----
df2 <- read.csv("data/assessment2.csv")
names(df2)

# Function to reverse score items
source("helpers.R")

# Prepare well-being items for CFA ----
wb_cfa_data <- prepare_wellbeing_items(df2)
names(wb_cfa_data)
cat("Sample size for CFA:", nrow(wb_cfa_data), "\n")

# Define CFA model ----
# Two-factor model (Positive vs Negative Well-being)
wb_cfa_model <- '  # Latent variables
  Positive_WB =~ LifeSatisfaction1 + LifeSatisfaction2 + LifeSatisfaction3 + Happy
  Negative_WB =~ Angry + Sad + Anxious + Depressed + Worried
  
  # Correlated errors (based on modification indices if needed)
  # LifeSatisfaction1 ~~ LifeSatisfaction2
  # LifeSatisfaction2 ~~ LifeSatisfaction3
'

# Fit CFA model
# wb_cfa_fit <- cfa(wb_cfa_model, data = wb_cfa_data)
wb_cfa_fit <- cfa(
  wb_cfa_model, 
  data = wb_cfa_data,
  estimator = "ML",  # Maximum Likelihood
  missing = "fiml"   # Full Information ML for missing data
)

# Visualize CFA model ----
semPaths(
  wb_cfa_fit,
  what = "std",           # show standardized estimates
  whatLabels = "std",     # label with standardized values
  layout = "tree",        # tree layout
  edge.label.cex = 1.2,   # edge label size
  sizeMan = 7,
  sizeLat = 9,
  nCharNodes = 0,        # don't truncate node names
  mar = c(5, 5, 5, 5),
  color = list(
    lat = rgb(0.2, 0.4, 0.8, 0.8),   # blue for latent
    man = rgb(0.8, 0.4, 0.2, 0.8)    # orange for manifest
  ),
  title = FALSE,
  curvePivot = TRUE
)

# Summarize CFA results ----
cat("CONFIRMATORY FACTOR ANALYSIS RESULTS\n")

# Model fit summary
fit_summary <- summary(wb_cfa_fit, 
                       fit.measures = TRUE, 
                       standardized = TRUE,
                       rsquare = TRUE)

## Extract and display key fit indices ----
cat("MODEL FIT INDICES:\n")
cat(sprintf("Chi-square: χ²(%.0f) = %.2f, p = %.4f\n",
            fit_summary$test$standard$df,
            fit_summary$test$standard$stat,
            fit_summary$test$standard$pvalue))

cat(sprintf("CFI:  %.3f\n", fitMeasures(wb_cfa_fit, "cfi")))
cat(sprintf("TLI:  %.3f\n", fitMeasures(wb_cfa_fit, "tli")))
cat(sprintf("RMSEA: %.3f (90%% CI: %.3f-%.3f)\n",
            fitMeasures(wb_cfa_fit, "rmsea"),
            fitMeasures(wb_cfa_fit, "rmsea.ci.lower"),
            fitMeasures(wb_cfa_fit, "rmsea.ci.upper")))
cat(sprintf("SRMR: %.3f\n", fitMeasures(wb_cfa_fit, "srmr")))

## Factor loadings with interpretation ----
cat("\nFACTOR LOADINGS (Standardized):\n")

loadings <- parameterEstimates(wb_cfa_fit, standardized = TRUE)
loadings <- loadings[loadings$op == "=~", c("lhs", "rhs", "std.all", "pvalue")]

# Format for display
for(i in 1:nrow(loadings)) {
  star <- ifelse(loadings$pvalue[i] < 0.001, "***",
                 ifelse(loadings$pvalue[i] < 0.01, "**",
                        ifelse(loadings$pvalue[i] < 0.05, "*", "")))
  cat(sprintf("%-15s =~ %-20s %.3f%s\n",
              loadings$lhs[i],
              loadings$rhs[i],
              loadings$std.all[i],
              star))
}

## Factor correlations ---- 
cat("\nFACTOR CORRELATIONS:\n")
corrs <- lavInspect(wb_cfa_fit, "cor.lv")
print(corrs)

## Modification indices (top 5) ----
cat("\nTOP 5 MODIFICATION INDICES:\n")
mod_indices <- modificationIndices(wb_cfa_fit, sort = TRUE)
print(head(mod_indices, 5))

## R-squared values ----
cat("\nR-SQUARED (Variance Explained):\n")
r2 <- inspect(wb_cfa_fit, "r2")
for(item in names(r2)) {
  cat(sprintf("%-20s: %.3f\n", item, r2[item]))
}

## Save results for reporting ----
results <- list(
  fit_measures = fitMeasures(wb_cfa_fit),
  loadings = loadings,
  factor_correlations = corrs,
  r_squared = r2,
  modification_indices = head(mod_indices, 10),
  sample_size = nrow(wb_cfa_data),
  model_syntax = wb_cfa_model
)

print(results)

# Print summary of results ----
cat("CFA SUMMARY\n")
cat(sprintf("Sample: N = %d\n", nrow(wb_cfa_data)))
cat(sprintf("Model fit: χ²(%d) = %.2f, p = %.4f\n", 
            fit_summary$test$standard$df,
            fit_summary$test$standard$stat,
            fit_summary$test$standard$pvalue))
cat(sprintf("CFI = %.3f, TLI = %.3f, RMSEA = %.3f, SRMR = %.3f\n",
            fitMeasures(wb_cfa_fit, "cfi"),
            fitMeasures(wb_cfa_fit, "tli"),
            fitMeasures(wb_cfa_fit, "rmsea"),
            fitMeasures(wb_cfa_fit, "srmr")))


# Revised model with suggested modifications ----
wb_cfa_model_revised <- '
  Positive_WB =~ LifeSatisfaction1 + LifeSatisfaction2 + LifeSatisfaction3 + Happy
  Negative_WB =~ Angry + Sad + Anxious + Depressed + Worried
  
  # Add suggested error covariances
  Angry ~~ Depressed
  Sad ~~ Depressed
  Sad ~~ Worried
  LifeSatisfaction1 ~~ LifeSatisfaction3
'
# Fit revised CFA model
wb_cfa_fit_revised <- cfa(
  wb_cfa_model_revised, 
  data = wb_cfa_data,
  estimator = "ML",  
  missing = "fiml"   
)
# Summarize revised CFA results ----
cat("\nREVISED CFA RESULTS\n")
# Model fit summary
fit_summary_revised <- summary(wb_cfa_fit_revised, 
                       fit.measures = TRUE, 
                       standardized = TRUE,
                       rsquare = TRUE)
## Extract and display key fit indices ----
cat("REVISED MODEL FIT INDICES:\n")
cat(sprintf("Chi-square: χ²(%.0f) = %.2f, p = %.4f\n",
            fit_summary_revised$test$standard$df,
            fit_summary_revised$test$standard$stat,
            fit_summary_revised$test$standard$pvalue))
cat(sprintf("CFI:  %.3f\n", fitMeasures(wb_cfa_fit_revised, "cfi")))
cat(sprintf("TLI:  %.3f\n", fitMeasures(wb_cfa_fit_revised, "tli")))
cat(sprintf("RMSEA: %.3f (90%% CI: %.3f-%.3f)\n",
            fitMeasures(wb_cfa_fit_revised, "rmsea"),
            fitMeasures(wb_cfa_fit_revised, "rmsea.ci.lower"),
            fitMeasures(wb_cfa_fit_revised, "rmsea.ci.upper")))

