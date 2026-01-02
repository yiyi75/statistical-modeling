# SEM / Path Analysis Portfolio Project --------
# Testing Psychological Mechanisms in Mindfulness-Based Interventions

## 0. Load libraries------------------------------------------------------------
packages <- c(
  "tidyverse", "lavaan", "semPlot", "semTools", "psych",
  "ggplot2", "ggpubr", "sjPlot", "performance", "corrplot",
  "lme4", "lmerTest", "emmeans", "haven"
)

# Check if required packages are installed
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
options(readr.num_columns = 0)
for (thispack in packages) {
  library(thispack,character.only=TRUE,quietly=TRUE,verbose=FALSE)
}

## Set directory
setwd("E:/statistical-modeling/SEM Path Analysis/")

dirs <- c("data", "figures", "results", "tables")
for (d in dirs) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

## 1. Load Data -----
daily_df     <- read.csv("data/intervention_final.csv")
baseline_df  <- read.csv("data/baseline1.csv")
poststudy_df <- read.csv("data/poststudy1.csv")

cat("Daily observations:", nrow(daily_df), "\n")
cat("Participants:", length(unique(daily_df$RandomID)), "\n")

## 2. Data Preparation -----
daily_df <- daily_df %>%
  mutate(
    Wellbeing   = PosAffect - NegAffect + Satisfied,
    Decentering = Disidentification + Nonreactivity,
    Condition_Choice = as.numeric(Condition == "Choice"),
    Condition_Value  = as.numeric(Condition == "Value"),
    Condition_Domain = as.numeric(Condition == "Domain")
  )

cat("Composite variables created.\n")
names(daily_df)

## 3. EFA: Construct Validation -----
wb_items <- daily_df %>% dplyr::select(PosAffect, NegAffect, Satisfied)
dc_items <- daily_df %>% dplyr::select(Disidentification, Nonreactivity)

fa.parallel(wb_items, fa = "fa")
efa_wb <- fa(wb_items, nfactors = 1, fm = "ml", rotate = "oblimin")

fa.parallel(dc_items, fa = "fa")
efa_dc <- fa(dc_items, nfactors = 1, fm = "ml", rotate = "oblimin")

cat("Well-being omega:", round(omega(wb_items)$omega.tot, 3), "\n")

## 4. Descriptives & Correlations -----
key_vars <- c(
  "Wellbeing", "Decentering", "Reappraisal",
  "PosAffect", "NegAffect", "Stressed"
)

desc_stats <- daily_df %>%
  group_by(Condition) %>%
  dplyr::summarise(across(all_of(key_vars),
                   list(M = ~mean(., na.rm = TRUE),
                        SD = ~sd(., na.rm = TRUE)),
                   .names = "{.col}_{.fn}"))

write.csv(desc_stats, "results/descriptive_statistics.csv", row.names = FALSE)

cor_mat <- cor(daily_df[, key_vars], use = "pairwise.complete.obs")

png("figures/correlation_matrix.png", 900, 900)
corrplot(cor_mat, method = "color", type = "upper", tl.col = "black")
dev.off()

## 5. CFA Models -----
wb_cfa <- '
  Wellbeing_latent =~ PosAffect + NegAffect + Satisfied
  Wellbeing_latent ~~ 1*Wellbeing_latent
'

dc_cfa <- '
  Decentering_latent =~ Disidentification + Nonreactivity
  Decentering_latent ~~ 1*Decentering_latent
'

wb_fit <- cfa(wb_cfa, data = daily_df, estimator = "MLR", missing = "ML")
dc_fit <- cfa(dc_cfa, data = daily_df, estimator = "MLR", missing = "ML")

png("figures/cfa_measurement_model.png", 1200, 800)
semPaths(wb_fit,
         what = "std", 
         layout = "tree", 
         title = FALSE,          
         edge.label.cex = 1.2,
         sizeMan = 8,
         sizeLat = 10)
dev.off() # SAVES the plot and closes the PNG device

## 6. Mediation Model -----
med_model <- '
  Reappraisal ~ a*Decentering
  Wellbeing ~ b*Reappraisal + c*Decentering

  Indirect := a*b
  Total := c + (a*b)
'

med_fit <- sem(med_model, data = daily_df, estimator = "MLR", missing = "ML")

med_results <- parameterEstimates(med_fit, standardized = TRUE)
write.csv(med_results, "results/mediation_results.csv", row.names = FALSE)

png("figures/mediation_model.png", width = 1200, height = 800, res = 150)
semPaths(med_fit, what = "std", layout = "tree",
         title = FALSE,
         edge.label.cex = 1.2,
         sizeMan = 8,
         sizeLat = 10)
dev.off()

## 7. Multiple Mediator Model -----

multi_model <- '
  Reappraisal ~ a1*Decentering
  PosAffect   ~ a2*Decentering
  Stressed    ~ a3*Decentering

  Wellbeing ~ b1*Reappraisal + b2*PosAffect + b3*Stressed + c*Decentering

  Ind_Reapp := a1*b1
  Ind_Pos   := a2*b2
  Ind_Stress := a3*b3
'

multi_fit <- sem(multi_model, data = daily_df, estimator = "MLR", missing = "ML")
multi_results <- parameterEstimates(multi_fit, standardized = TRUE)

write.csv(multi_results, "results/multiple_mediators_results.csv", row.names = FALSE)

png("figures/multiple_mediators_model.png", 1400, 900)
semPaths(multi_fit, what = "std", layout = "tree2",
         title = FALSE,
         edge.label.cex = 1.2,
         sizeMan = 8,
         sizeLat = 10)
dev.off()

## 8. Full SEM with Latent Variables -----

full_sem <- '
  Wellbeing_latent =~ PosAffect + NegAffect + Satisfied
  Decentering_latent =~ Disidentification + Nonreactivity

  Reappraisal ~ a*Decentering_latent
  Wellbeing_latent ~ b*Reappraisal + c*Decentering_latent

  Indirect := a*b
'

full_fit <- sem(full_sem, data = daily_df, estimator = "MLR", missing = "ML")

png("figures/full_sem_model.png", 1400, 1000)
semPaths(full_fit, what = "std", layout = "spring",
         title = FALSE,
         edge.label.cex = 1.2,
         sizeMan = 8,
         sizeLat = 10)
dev.off()

# saveRDS(
#   list(
#     Mediation = med_fit,
#     MultipleMediators = multi_fit,
#     FullSEM = full_fit,
#     CFA_WB = wb_fit,
#     CFA_DC = dc_fit
#   ),
#   file = "results/sem_models.rds"
# )

