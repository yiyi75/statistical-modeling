# Generalized Linear Models Case Study
## Modeling Mental and Behavioral Health Outcomes

This project demonstrates the application of generalized linear models (GLMs) to real-world health survey data. The analyses focus on selecting appropriate link functions and distributions based on outcome characteristics, and on interpreting model results using effect sizes and estimated marginal means.

## Research Questions
- Which demographic and behavioral factors predict the likelihood of mental health risk?
- When are Poisson models insufficient for count outcomes?
- How does accounting for overdispersion change substantive conclusions?

## Modeling Strategy
- Logistic regression for binary health outcomes
- Poisson regression for count-based behaviors
- Negative binomial regression to address overdispersion
- Effect coding and predictor centering for interpretability

## Variables used in this project
| Construct                | Variable   |
| ------------------------ | ---------- |
| Depression diagnosis     | `ADDEPEV3` |
| Poor mental health days  | `MENTHLTH` |
| Exercise                 | `EXERANY2` |
| Sex                      | `SEX`      |
| Age                      | `AGE80`    |
| Education                | `EDUCA`    |
| Income                   | `INCOME3`  |
| General health (control) | `GENHLTH`  |
| Smoking status (control) | `SMOKER3`  |
| Survey weight            | `LLCPWT`   |
