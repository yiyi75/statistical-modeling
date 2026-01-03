# CDC BRFSS: Mental Health & Behavioral Determinants Analysis
This project demonstrates the application of **generalized linear models** to analyze behavioral risk factors and mental health outcomes.

The analysis employs survey-weighted logistic regression, poisson regression, and negative binomial regression to model depression diagnosis and poor mental health days, with particular attention to addressing overdispersion and complex survey design (negative binomial regression > poisson regression).

## Key Findings (TL;DR)

- **Exercise is strongly protective**: Regular exercisers have 33% lower odds of depression diagnosis and 32% fewer poor mental health days per month.
- **Gender differences are significant**: Females have 69% higher odds of depression and report slightly more mental health days than males.
- **Education is protective**: Higher education levels are associated with 12% lower depression odds per education level.
- **Income effects are negligible**: After correcting for overdispersion, income shows no significant relationship with mental health days.
- **Statistical methods matter**: Poisson regression produced misleading results (Type I error for income) that were corrected by negative binomial regression.

## Data Overview
- **Source**: CDC Behavioral Risk Factor Surveillance System (BRFSS) 2022
- **Sample size**: 164,521 observations (after cleaning)
- **Survey design**: Complex probability sampling requiring survey weights
- **Weight variable**: LLCPWT (final analytic weight)
- **Outcomes**:
    - Binary: Depression diagnosis (ADDEPEV3)
    - Count: Poor mental health days in past 30 (MENTHLTH: 0-30)
- **Predictors**:
    - Demographic: Age, Sex, Education, Income
    - Behavioral: Regular exercise (EXERANY2)
- **Modeling approach**:
    - Survey-weighted logistic regression (depression diagnosis)
    - Negative binomial regression (mental health days, corrected for overdispersion)
    - Continuous predictors centered for interpretability


## Methodological Insights
- **Importance of Addressing Overdispersion**:
    - Poisson assumption violation: Count data in health/social sciences often overdispersed
    - Consequences of ignoring overdispersion:
        Standard errors underestimated by factor of √8.988 ≈ 3×
        Increased Type I errors (false positives)
        Example: Income appeared significant in Poisson (p = 0.035) but not in NB (p = 0.555)
    - Solution: Negative binomial regression adds dispersion parameter θ

- **Importance of Survey Weights**:
    - BRFSS uses complex sampling: Stratified, clustered design
    - Without weights: Results only represent sample, not US population
    - Weight variable: LLCPWT accounts for sampling probabilities and post-stratification
    - Impact: Changes standard errors and potentially significance levels


## Public Health Implications
- **Strong Evidence for Intervention Targets**:

    1. Exercise promotion: Strongest, most consistent protective effect
    - 33% lower depression odds
    - 32% fewer mental health days

    2. Gender-specific approaches: Females at higher risk
    - 69% higher depression odds

    3. Education: Each education level reduces depression risk
    - 12% lower odds per level