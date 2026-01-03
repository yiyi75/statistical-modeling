# Generalized Linear Models Case Study ----
# CDC BRFSS: Mental & Behavioral Health Outcomes

# 0. Load Packages ----
packages <- c(
  "dplyr",
  "tidyverse",
  "lme4",
  "MASS",
  "emmeans",
  "performance",
  "pscl",
  "survey"
)

if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
options(readr.num_columns = 0)
for (thispack in packages) {
  library(thispack,character.only=TRUE,quietly=TRUE,verbose=FALSE)
}

# Set directory ----
sourcedir = "E:/statistical-modeling/Generalized Linear Models/"
setwd(sourcedir)

# 1. Load Data ----
brfss <- read.csv("data/brfss2022.csv")
names(brfss)

# remove X_ from each column name
names(brfss) <- gsub("^X_", "", names(brfss))
names(brfss)

# 2. Data Cleaning ----
brfss_clean <- brfss %>%
  transmute(
    # Survey weight
    weight = LLCPWT,
    
    # Binary outcome: depression diagnosis
    depressed = case_when(
      ADDEPEV3 == 1 ~ 1,
      ADDEPEV3 == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    
    # Count outcome: poor mental health days (0–30)
    mental_days = ifelse(MENTHLTH %in% 0:30, MENTHLTH, NA),
    
    # Key predictors
    exercise = case_when(
      EXERANY2 == 1 ~ 1,
      EXERANY2 == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    
    sex = factor(SEX, labels = c("Male", "Female")),
    age = AGE80,
    education = EDUCA,
    income = INCOME3,
    
    # Controls
    gen_health = GENHLTH,
    smoker = factor(SMOKER3)
  ) %>%
  drop_na()

# 3. Center Continuous Predictors ----
brfss_clean <- brfss_clean %>%
  mutate(
    c_age = age - mean(age),
    c_education = education - mean(education),
    c_income = income - mean(income)
  )

# 4. Survey Design Object ----
design_brfss <- svydesign(
  ids = ~1,
  weights = ~weight,
  data = brfss_clean
)

# 5. Model Fitting ----
## 1): Logistic Regression ----
# - Model: svyglm (survey-weighted generalized linear model)
# - Outcome: depressed (binary: 1 = yes, 0 = no)
# - Predictors: c_age (centered age), sex (Male/Female), exercise (0/1), 
#               c_income (centered income), c_education (centered education)
# - Design: survey-weighted using BRFSS sampling weights
# - Family: quasibinomial (logistic regression with potential overdispersion)

logit_model <- svyglm(
  depressed ~ c_age + sex + exercise + c_income + c_education,
  design = design_brfss,
  family = quasibinomial()
)

summary(logit_model)

# Odds ratios
exp(coef(logit_model))

### Results ----
# 1. AGE (c_age): 
#    - Estimate = -0.0016, p = 0.00795**
#    - OR = 0.9984 (95% CI not shown but implied by SE)
#    - INTERPRETATION: Each additional year of age is associated with a 0.16% decrease
#      in the odds of depression diagnosis. Although statistically significant, the
#      effect size is very small clinically. The negative direction suggests
#      depression prevalence decreases slightly with age in this sample.

# 2. SEX (sexFemale):
#    - Estimate = 0.5271, p < 2e-16***
#    - OR = 1.6940
#    - INTERPRETATION: Females have 69.4% higher odds of depression diagnosis
#      compared to males (OR = 1.694). This is a substantial and highly significant
#      effect, consistent with epidemiological literature showing higher depression
#      prevalence among women.

# 3. EXERCISE (exercise):
#    - Estimate = -0.4069, p < 2e-16***
#    - OR = 0.6657
#    - INTERPRETATION: Regular exercisers have 33.4% lower odds of depression
#      diagnosis compared to non-exercisers (OR = 0.6657). This protective effect
#      is both statistically and clinically significant, supporting exercise as a
#      potential protective factor against depression.

# 4. INCOME (c_income):
#    - Estimate = -0.0028, p = 3.44e-15***
#    - OR = 0.9972
#    - INTERPRETATION: Higher income is associated with slightly lower odds of
#      depression. Each unit increase in income (relative to mean) corresponds to
#      a 0.28% decrease in depression odds. While statistically significant,
#      the effect size per unit is small.

# 5. EDUCATION (c_education):
#    - Estimate = -0.1220, p < 2e-16***
#    - OR = 0.8852
#    - INTERPRETATION: Higher education level is associated with lower depression
#      odds. Each additional education level (relative to mean) corresponds to
#      an 11.5% decrease in depression odds. This suggests education may be
#      protective against depression.

# MODEL FIT NOTES:
# - All predictors are statistically significant at p < 0.01 level
# - Largest effects: sex (female) increases risk, exercise decreases risk
# - Quasibinomial dispersion = 0.9998 ≈ 1, suggesting minimal overdispersion
# - Survey weights account for BRFSS complex sampling design


## 2): Poisson Regression  ----
# - Model: glm (generalized linear model) - NOT survey-weighted
# - Outcome: mental_days (count variable: 0-30 poor mental health days)
# - Predictors: c_age, sex, exercise, c_income
# - Family: Poisson (for count data)
# - Data: brfss_clean (unweighted)

# poisson regression formula:
# log(μ) = β₀ + β₁*c_age + β₂*sexFemale + β₃*exercise + β₄*c_income
# μ = expected number of mental health days

poisson_model <- glm(
  mental_days ~ c_age + sex + exercise + c_income,
  family = poisson,
  data = brfss_clean
)

summary(poisson_model)

# Overdispersion check
# Poisson assumption: Mean = Variance
# Overdispersion: Variance > Mean

performance::check_overdispersion(poisson_model) # Overdispersion detected.
# dispersion ratio: Variance is 8.988 × Mean
# why is this problematic?
#   1) Standard errors are underestimated -> confidence intervals too narrow
#   2) p-values are too small -> increased Type I errors (false positives)
#   3) Model may identify "significant" effects that aren't real


### Results ----
# 1. AGE (c_age): 
#    - Estimate = -0.00299, p < 2e-16***
#    - IRR = exp(-0.00299) = 0.9970
#    - INTERPRETATION: Each additional year of age is associated with a 0.3%
#      decrease in expected mental health days. Highly significant but small effect.

# 2. SEX (sexFemale):
#    - Estimate = 0.01477, p < 2e-16***
#    - IRR = exp(0.01477) = 1.0149
#    - INTERPRETATION: Females have 1.5% higher expected mental health days
#      compared to males. Statistically significant but small effect size.

# 3. EXERCISE (exercise):
#    - Estimate = -0.3877, p < 2e-16***
#    - IRR = exp(-0.3877) = 0.6788
#    - INTERPRETATION: Regular exercisers have 32.1% fewer expected mental
#      health days compared to non-exercisers. Large and highly significant effect.

# 4. INCOME (c_income):
#    - Estimate = 0.0000516, p = 0.0353*
#    - IRR = exp(0.0000516) = 1.00005
#    - INTERPRETATION: Small positive association between income and mental
#      health days, but effect size is negligible (0.005% increase per unit).

# OVERDISPERSION CHECK:
# - Dispersion ratio = 8.988, p < 0.001
# - INTERPRETATION: Severe overdispersion detected. Poisson assumption of
#   mean = variance is violated ==> Negative binomial model is more appropriate.


## 3): Negative Binomial Regression ----
#     Adds an extra parameter θ (theta)
#     Allows variance = μ + μ²/θ (variance > mean)
#     Smaller θ = more overdispersion
# negative binomial regression formula:
# log(μ) = β₀ + β₁*c_age + β₂*sexFemale + β₃*exercise + β₄*c_income
# Variance = μ + μ²/θ  where θ = 1.324

nb_model <- glm.nb(
  mental_days ~ c_age + sex + exercise + c_income,
  data = brfss_clean
)

summary(nb_model)

### Results ----

# Model: mental_days ~ c_age + sex + exercise + c_income
# Family: Negative Binomial (accounts for overdispersion)
# Theta parameter: 1.324 (measures overdispersion; lower = more overdispersion)

# 1. AGE (c_age): 
#    - Estimate = -0.00315, p < 2e-16***
#    - IRR = exp(-0.00315) = 0.9969
#    - INTERPRETATION: Each year of age associated with 0.31% decrease in
#      expected mental health days. Consistent direction with Poisson model.

# 2. SEX (sexFemale):
#    - Estimate = 0.01435, p = 0.00209**
#    - IRR = exp(0.01435) = 1.0145
#    - INTERPRETATION: Females have 1.45% higher expected mental health days.
#      Still significant but p-value increased from <2e-16 to 0.002 after
#      accounting for overdispersion.

# 3. EXERCISE (exercise):
#    - Estimate = -0.3909, p < 2e-16***
#    - IRR = exp(-0.3909) = 0.6762
#    - INTERPRETATION: Regular exercisers have 32.4% fewer expected mental
#      health days. Highly robust effect across both Poisson and NB models.

# 4. INCOME (c_income):
#    - Estimate = 0.00004465, p = 0.55453
#    - IRR = exp(0.00004465) = 1.00004
#    - INTERPRETATION: Not statistically significant in NB model. The Poisson
#      result was likely a Type I error due to overdispersion.


# 6. Model comparison ----
AIC(poisson_model, nb_model)

# MODEL COMPARISON:
# - AIC(Poisson) = 2,028,510 vs AIC(NB) = 1,126,666
# - NB model fits substantially better (ΔAIC = 901,844).
#   Negative binomial is preferred due to overdispersion.


# 7. Marginal Effects (for exercise) ----
emmeans(nb_model, ~ exercise, type = "response")

## Result ----
# - Non-exercisers: 14.70 expected mental health days (95% CI: 14.57-14.83)
# - Exercisers: 9.94 expected mental health days (95% CI: 9.89-9.99)
# - ==> Regular exercise is associated with 4.76 fewer expected
#   poor mental health days per month (32.4% reduction).
