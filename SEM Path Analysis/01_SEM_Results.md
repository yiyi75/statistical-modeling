# Structural Equation Modeling Path Analysis 
This project demonstrates comprehensive structural equation modeling (SEM) and path analysis skills applied to a longitudinal mindfulness intervention study. In the analysis, I examined how mindfulness processes influence well-being through multiple psychological pathways (e.g., decentering, reappraisal, stress)

## Key Findings (TL;DR)

- **Well-being and decentering were each supported as unidimensional constructs**, with acceptable internal consistency and consistent factor structure across EFA and CFA.
- **Decentering was positively associated with well-being both directly and indirectly**, with reappraisal acting as a partial mediator.
- **Multiple psychological pathways contributed to well-being**, including cognitive (reappraisal) and affective (positive affect, stress) mechanisms, suggesting that improvements in well-being are **multi-determined**, rather than driven by a single mechanism.

## Study Overview

- **Data structure**: 1,079 daily observations nested within 164 participants  
- **Design**: Longitudinal daily intervention study  
- **Timeframe**: Baseline -> Daily intervention -> Post-study
- **Data Sources**: baseline1.csv, intervention_final.csv, poststudy1.csv

## Results Summary
### Construct Validation
Exploratory factor analysis supported a **single-factor structure** for both well-being and decentering. Reliability analyses indicated acceptable internal consistency (ω ≈ .78 for well-being), supporting the use of these constructs in downstream modeling.

Confirmatory factor analysis further validated the measurement models, allowing for both composite and latent-variable approaches in structural analyses.


### Mediation Analysis
Structural equation modeling revealed that **decentering predicts greater well-being partially through increased reappraisal**. While reappraisal explained a meaningful portion of the association, a significant direct effect remained, indicating partial mediation.


### Multiple Mediator Model
When testing multiple mediators simultaneously, decentering influenced well-being through **several parallel pathways**, including:
- Greater use of positive reappraisal
- Higher positive affect
- Lower perceived stress

These results suggest that improvements in well-being are **multi-determined**, rather than driven by a single mechanism.


### Latent Variable SEM
A full latent-variable SEM replicated the observed-variable results, demonstrating that findings were **robust to measurement error** and not dependent on composite scoring decisions.


## Methodological Notes

- Daily data (1,079 observations; 164 participants)
- Missing data handled using full information maximum likelihood (MLR)
- Models estimated using `lavaan`
- Both measurement and structural models are visualized and reproducible


## Takeaway
This project demonstrates an end-to-end **psychological mechanism analysis**, integrating factor analysis, mediation, and full SEM to examine how mindfulness-related processes influence daily well-being over time.
