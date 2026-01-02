# Daily Mindfulness Intervention and Well-Being
This study demonstrates the use of **longitudinal multilevel modeling** to evaluate the effects of a mindfulness intervention on psychological outcomes measured repeatedly over time. The analysis focuses on separating **overall time trends** from **intervention-specific effects**, with particular attention to theoretically motivated mechanisms.

## Key Findings (TL;DR)

- **Mindfulness interventions produced modest but consistent within-person improvements** in decentering and well-being over time, relative to baseline trends.
- **Choice-based and value-based interventions showed similar growth trajectories**, with no strong evidence of sustained divergence between active conditions.
- **Most outcome variance was attributable to within-person change rather than between-person differences**, supporting the use of multilevel models for daily intervention data.


## Study Overview

- **Data structure**: 1,079 daily observations nested within individuals  
- **Design**: Longitudinal daily diary study  
- **Levels**:
  - Level 1: Daily observations
  - Level 2: Participants
- **Conditions**:
  - Choice-based mindfulness intervention
  - Value-based mindfulness intervention (LLM-powered chatbot)
  - Control
- **Primary outcomes**:
  - Decentering
  - Well-being
  - Stress
  - Positive affect
- **Modeling approach**:
  - Linear mixed-effects models
  - Random intercepts for participants
  - Time and Condition × Time interactions


## Step 1: Overall Time Trends
Random-intercept growth models were first used to examine whether outcomes changed over time **regardless of condition**.

### Significant time effects
- **Stress** decreased over time  
  - β = −0.055, *p* = .004
- **Well-being** increased over time  
  - β = 0.093, *p* = .012
- **Reappraisal** increased over time  
  - β = 0.041, *p* = .019

### Marginal or non-significant trends
- Positive affect showed a marginal increase (*p* ≈ .052)
- Decentering increased modestly but did not reach significance (*p* ≈ .063)
- Negative affect showed no reliable change

**Interpretation:**  
Across all participants, the study period was associated with reduced stress and improvements in well-being-related skills, independent of intervention assignment.


## Step 2: Condition × Time Effects

### Decentering (Primary Mechanism Outcome)
- A **significant Condition × Time interaction** was observed.
- Participants in the **Choice condition** showed a steeper increase in decentering over time compared to:
  - Control (*p* = .037)
  - Value (*p* = .007)

**Simple slopes**
- Choice: significant positive growth
- Control and Value: no reliable growth

**Interpretation:**  
The choice-based intervention uniquely promoted growth in decentering, a key cognitive mechanism targeted by mindfulness training.


### Well-being
- Well-being increased over time overall.
- No significant Condition × Time interaction.

**Interpretation:**  
Well-being improved during the study, but the rate of change did not differ by intervention condition.


### Stress
- Significant reduction over time.
- No differential reduction between intervention and control groups.

**Interpretation:**  
Stress decreased during the study period, but this effect was not specific to the intervention.


### Positive Affect
- Positive affect increased modestly over time.
- The control group exhibited a flatter trajectory relative to the Choice condition.
- No consistent advantage of the Value condition over control.

**Interpretation:**  
Positive affect changes were small and not consistently driven by intervention condition.


## Step 3: Intervention vs. Control (Collapsed Comparison)

To assess overall intervention effects, Choice and Value conditions were collapsed into a single **Intervention** group.

| Outcome          | Intervention × Time | Interpretation |
|------------------|---------------------|----------------|
| Decentering      | **Significant** (*p* = .006) | Intervention increased decentering over time |
| Well-being       | Not significant     | No differential effect |
| Stress           | Not significant     | No differential effect |
| Positive Affect  | Not significant     | No differential effect |

**Key finding:**  
The intervention primarily affected **decentering**, rather than downstream affective outcomes within the study duration.


## Theoretical Implications
- Decentering appears to be the most proximal and sensitive outcome of mindfulness training.
- Changes in stress and well-being may require longer exposure or may be influenced by non-specific study effects (e.g., self-monitoring).
- Results support a **mechanism-first model**, where cognitive skills change before broader well-being outcomes.