# helpers.R
# Utility functions for factor analysis and data preparation

# Reverse score an item
#' @param item Vector of item scores to reverse
#' @param max_score Maximum possible score on the scale
#' @return Reverse-scored vector
reverse_score <- function(item, max_score) {
  return(max_score + 1 - item)
}

# Extract items with loadings above cutoff
#' @param loadings Factor loadings matrix from EFA/CFA
#' @param cutoff Threshold for meaningful loadings (default = 0.4)
#' @return List of items for each factor
extract_items <- function(loadings, cutoff = 0.4) {
  apply(abs(loadings) > cutoff, 2, function(x) names(x[x]))
}

# Prepare well-being items for factor analysis
#' @param df Data frame containing original PersonalWB variables
#' @return Data frame with renamed and reverse-scored items
prepare_wellbeing_items <- function(df) {
  wb_items <- df %>%
    dplyr::mutate(
      Angry = reverse_score(PersonalWB_04, 7),
      Sad = reverse_score(PersonalWB_06, 7),
      Anxious = reverse_score(PersonalWB_07, 7),
      Depressed = reverse_score(PersonalWB_09, 7),
      Worried = reverse_score(PersonalWB_10, 7)
    ) %>%
    dplyr::select(
      LifeSatisfaction1 = PersonalWB_01,  # Life satisfaction item 1
      LifeSatisfaction2 = PersonalWB_02,  # Life satisfaction item 2
      LifeSatisfaction3 = PersonalWB_03,  # Life satisfaction item 3
      Angry,
      Sad,
      Anxious,
      Depressed,
      Worried,
      Happy = PersonalWB_08   # Happiness
    ) %>%
    tidyr::drop_na()
  
  return(wb_items)
}