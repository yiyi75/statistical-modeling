# Description: This script performs exploratory factor analysis (EFA) on well-being items
# and creates simple well-being indices from assessment data.

# Load libraries ----
library(dplyr)
library(tidyr)
library(psych)
library(paran)

# Function to reverse score items
source("helpers.R")

# Load data ----
df <- read.csv("data/assessment1.csv")
# View variable names
names(df)

# 1. Create Simple Well-Being Indices ----
df <- df %>%
  dplyr::mutate(
    NegativeAffect = (PersonalWB_Sadness +
                      PersonalWB_Anger +
                      PersonalWB_Anxiety) / 6,
    PositiveAffect = PersonalWB_Happiness / 2,
    MoodIndex = PositiveAffect - NegativeAffect
  )

# show structure of the data
str(df)

# 2. Exploratory Factor Analysis (EFA): Well-being ----
## 1) Prepare items ---- 
wb_items <- prepare_wellbeing_items(df)

## 2): Determine factors ----
pfit = paran(wb_items,iterations = 1000, graph=TRUE) # 2 components retained
fa.parallel(wb_items, fa = "fa")

# During exploratory factor analysis, warnings related to factor score estimation 
# and Heywood cases were observed. These are common in exploratory settings with 
# correlated affective items and do not affect conclusions regarding factor structure. 
# Factor retention decisions were based on parallel analysis, comparative model fit, 
# and interpretability.

## 3): Compare models ----
efa_1 <- fa(wb_items, 1, rotate = "oblimin")
efa_2 <- fa(wb_items, 2, rotate = "oblimin")
efa_3 <- fa(wb_items, 3, rotate = "oblimin")

anova(efa_1, efa_2, efa_3)
efa_1 # explained 47% of the total variance
efa_2 # explained 57% of the total variance
efa_3 # explained 62% of the total variance
efa_1$RMSEA
efa_2$RMSEA
efa_3$RMSEA
fa.diagram(efa_3)
fa.diagram(efa_2)
fa.diagram(efa_1)

## 4) Select solution ----
# Select final model based on parsimony and interpretability
selected_efa <- efa_2

# Inspect factor composition
print(selected_efa$loadings, cutoff = 0.4)
extract_items(selected_efa$loadings)


# Conclusion: 
# Parallel analysis using principal components suggested a two-component solution, 
# whereas parallel analysis based on common factor extraction suggested a three-factor solution. 
# Examination of the three-factor model indicated that the additional factor 
# primarily split negative affect items (e.g., anger vs. sadness/anxiety) 
# without yielding a substantively distinct construct. 
# Given the high inter-factor correlations and limited interpretability of the third factor, 
# a two-factor solution was selected as the most parsimonious and theoretically 
# coherent representation of well-being.

# 2-Factor EFA Results Interpretation:
# Factor 1: Life Satisfaction + Happiness
# Factor 2: Negative Affect (Angry, Sad, Anxious, Depressed, Worried)


