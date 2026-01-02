# DAILY INTERVENTION STUDY - MULTILEVEL MODELING ANALYSIS ----
# Analysis of longitudinal mindfulness intervention effects on daily well-being

# Load libraries ----
packages <- c("tidyverse", "lme4", "lmerTest", "emmeans", "nlme",
              "ggplot2", "ggpubr", "sjPlot", "performance"
)
# Check if required packages are installed
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
options(readr.num_columns = 0)
for (thispack in packages) {
  library(thispack,character.only=TRUE,quietly=TRUE,verbose=FALSE)
}

# Set directory ----
sourcedir = "E:/statistical-modeling/Multilevel Modeling/"
setwd(sourcedir)

# Load data ----
df <- read.csv("data/intervention_final.csv")

# Display data structure
cat("Data Structure:\n")
str(df)
cat("\nFirst 6 rows:\n")
head(df)
cat("\nSummary statistics:\n")
summary(df)

# 1. Data preparation ----
## Composite variable creation ----
# Create Well-being composite: Positive affect - Negative affect + Satisfaction
df$Wellbeing <- df$PosAffect - df$NegAffect + df$Satisfied

# Create intervention groups
df$InterventionCondition <- df$Condition %in% c("Choice", "Domain")

# Create Decentering composite
# Correlation between components
decentering_cor <- cor(df$Disidentification, df$Nonreactivity, 
                       use = "pairwise.complete.obs")
cat("\nCorrelation between Disidentification and Nonreactivity:", 
    round(decentering_cor, 2), "\n")

# Create total decentering score
df$Decentering <- df$Disidentification + df$Nonreactivity


# 2. Exploratory Data Analysis ----

# Function to create growth curve plots
create_growth_plot <- function(data, y_var, y_label, 
                               conditions = c("Choice", "Control"),
                               color_palette = c("#F08FB8", "#6F91D6")) {
  
  plot_data <- data[data$Condition %in% conditions, ]
  
  ggplot(plot_data, aes(x = StudyDay, y = .data[[y_var]], color = Condition)) +
    geom_smooth(method = "lm", se = TRUE, alpha = 0.1, linewidth = 1.2) +
    scale_color_manual(values = color_palette) +
    labs(x = "Time (days)", y = y_label,
         title = paste(y_label, "Growth by Condition")) +
    theme_pubr(base_size = 14) +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5))
}
# Create growth curve plots for key variables
plots <- list()

# Positive affect comparison
plots$pos_affect <- create_growth_plot(df, "PosAffect", "Positive Affect")

# Decentering growth
plots$decentering <- ggplot(df, aes(x = StudyDay, y = Decentering, color = Condition)) +
  geom_smooth(method = "lm", se = TRUE, alpha = 0.1, linewidth = 1.2) +
  scale_color_manual(values = c("Control" = "#F08FB8", 
                                "Choice" = "#00BA38", 
                                "Value" = "#6F91D6")) +
  labs(x = "Time (days)", y = "Decentering",
       title = "Decentering Growth by Condition") +
  theme_pubr(base_size = 14) +
  theme(legend.position = "right",
        plot.title = element_text(hjust = 0.5))

# Stress reduction (intervention vs control)
plots$stress <- ggplot(df, aes(x = StudyDay, y = Stressed, color = InterventionCondition)) +
  geom_smooth(se = TRUE, alpha = 0.1, linewidth = 1.2) +
  scale_color_manual(values = c("FALSE" = "#F08FB8", "TRUE" = "#6F91D6"),
                     labels = c("Control", "Intervention")) +
  labs(x = "Time (days)", y = "Stress Level",
       title = "Stress Reduction: Intervention vs Control",
       color = "Condition") +
  theme_pubr(base_size = 14) +
  theme(legend.position = "right",
        plot.title = element_text(hjust = 0.5))

# Well-being growth
plots$wellbeing <- create_growth_plot(df, "Wellbeing", "Well-being",
                                      conditions = unique(df$Condition),
                                      color_palette = c("Control" = "#F08FB8",
                                                        "Choice" = "#00BA38",
                                                        "Value" = "#6F91D6"))

# Arrange and display plots
combined_plot <- ggarrange(plotlist = plots, ncol = 2, nrow = 2, 
                           common.legend = FALSE, legend = "right")
print(combined_plot)

# save plots to files
ggsave("figures/growth_plots.png", combined_plot, width = 12, height = 8, dpi = 300)

# 3. Multilevel Modeling Analysis ----

## 1) Preliminary Time Effects ----
cat("PRELIMINARY ANALYSIS: TIME EFFECTS\n")

# Function to fit and summarize basic growth models
fit_growth_model <- function(outcome, data = df) {
  formula <- as.formula(paste(outcome, "~ StudyDay + (1|RandomID)"))
  model <- lmer(formula, data = data, na.action = na.omit)
  
  # Extract key information
  fixed_effects <- fixef(model)
  p_values <- coef(summary(model))[, "Pr(>|t|)"]
  
  return(list(
    outcome = outcome,
    intercept = round(fixed_effects[1], 3),
    slope = round(fixed_effects[2], 3),
    p_value = round(p_values[2], 4),
    model = model
  ))
}

# Test time effects for key outcomes
key_outcomes <- c("PosAffect", "NegAffect", "Stressed", "Wellbeing", 
                  "Decentering", "Reappraisal")

time_effects <- lapply(key_outcomes, fit_growth_model)

# Display results
time_results <- do.call(rbind, lapply(time_effects, function(x) {
  data.frame(
    Outcome = x$outcome,
    Intercept = x$intercept,
    Slope = x$slope,
    P_Value = x$p_value,
    Significant = ifelse(x$p_value < 0.05, "Yes", "No")
  )
}))

print(time_results)

## 2) Main intervention effects: Condition × Time Interactions ----
cat("\nMAIN ANALYSIS: INTERVENTION EFFECTS\n")

# Function to fit condition × time interaction models
fit_condition_model <- function(outcome, data = df) {
  formula <- as.formula(paste(outcome, "~ StudyDay * Condition + (1|RandomID)"))
  model <- lmer(formula, data = data, na.action = na.omit)
  return(model)
}

# Fit models for primary outcomes with explicit formula storage
primary_outcomes <- list()

# Decentering model
primary_outcomes$decentering <- lmer(Decentering ~ StudyDay * Condition + (1|RandomID), 
                                     data = df, na.action = na.omit)

# Well-being model
primary_outcomes$wellbeing <- lmer(Wellbeing ~ StudyDay * Condition + (1|RandomID), 
                                   data = df, na.action = na.omit)

# Stress model
primary_outcomes$stress <- lmer(Stressed ~ StudyDay * Condition + (1|RandomID), 
                                data = df, na.action = na.omit)

# Positive affect model
primary_outcomes$pos_affect <- lmer(PosAffect ~ StudyDay * Condition + (1|RandomID), 
                                    data = df, na.action = na.omit)

# Display model summaries
for (model_name in names(primary_outcomes)) {
  cat("\nModel:", model_name, "\n")
  cat(strrep("-", 40), "\n")
  print(summary(primary_outcomes[[model_name]])$coefficients)
}

# 4. IIntervention vs. Control ----
# Function for intervention vs control analyses
analyze_intervention_effect <- function(outcome, data = df) {
  formula <- as.formula(paste(outcome, "~ StudyDay * InterventionCondition + (1|RandomID)"))
  model <- lmer(formula, data = data, na.action = na.omit)
  
  coef_summary <- coef(summary(model))
  
  # Check for correct interaction term name
  interaction_term <- "StudyDay:InterventionConditionTRUE"
  if (!interaction_term %in% rownames(coef_summary)) {
    # Try alternative naming
    interaction_term <- grep("StudyDay.*InterventionCondition", rownames(coef_summary), value = TRUE)
    if (length(interaction_term) > 0) {
      interaction_term <- interaction_term[1]
    } else {
      # Default to second row if interaction exists
      if (nrow(coef_summary) >= 3) {
        interaction_term <- rownames(coef_summary)[3]
      } else {
        return(list(
          outcome = outcome,
          estimate = NA,
          se = NA,
          t_value = NA,
          p_value = NA,
          model = model
        ))
      }
    }
  }
  
  interaction_effect <- coef_summary[interaction_term, ]
  
  return(list(
    outcome = outcome,
    estimate = round(interaction_effect["Estimate"], 3),
    se = round(interaction_effect["Std. Error"], 3),
    t_value = round(interaction_effect["t value"], 2),
    p_value = round(interaction_effect["Pr(>|t|)"], 4),
    model = model
  ))
}

# Analyze intervention effects on key outcomes
intervention_effects <- list(
  decentering = analyze_intervention_effect("Decentering"),
  wellbeing = analyze_intervention_effect("Wellbeing"),
  pos_affect = analyze_intervention_effect("PosAffect"),
  stress = analyze_intervention_effect("Stressed")
)

# Display results
intervention_results <- do.call(rbind, lapply(intervention_effects, function(x) {
  data.frame(
    Outcome = x$outcome,
    Estimate = x$estimate,
    SE = x$se,
    t = x$t_value,
    P = x$p_value,
    Interpretation = ifelse(!is.na(x$p_value) && x$p_value < 0.05,
                            "Significant Intervention Effect",
                            ifelse(is.na(x$p_value), "Could not compute", "No Significant Effect"))
  )
}))

print(intervention_results)

# 5. Post-hoc Analysis and Simple Slopes----
# Calculate simple slopes for decentering model
decentering_slopes <- emtrends(primary_outcomes$decentering, 
                               specs = ~ Condition, 
                               var = "StudyDay")

cat("\nSimple Slopes for Decentering Growth:\n")
print(decentering_slopes)

# Pairwise comparisons of slopes
cat("\nPairwise Comparisons of Growth Rates:\n")
slope_comparisons <- pairs(decentering_slopes, adjust = "holm")
print(slope_comparisons)

