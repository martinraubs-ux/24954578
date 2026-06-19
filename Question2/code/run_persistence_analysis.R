# run_persistence_analysis

run_persistence_analysis <- function(babynames,
                                     lags = 1:3,
                                     top_n = 25) {
  library(tidyverse)
  
  # 1. Collapse duplicate names and rank correctly by Year + Gender
  nat_names <- babynames %>%
    rename_with(tolower) %>%
    mutate(name = str_to_title(name), gender = toupper(gender)) %>%
    group_by(year, gender, name) %>%
    summarise(count = sum(count), .groups = "drop") %>%
    group_by(year, gender) %>%
    arrange(desc(count), .by_group = TRUE) %>%
    mutate(rank = row_number()) %>%
    ungroup()
  
  # 2. Extract only the actual top_n names for each year
  top_now <- nat_names %>%
    filter(rank <= top_n) %>%
    select(year, gender, name, rank_now = rank)
  
  # 3. Pre-calculate the worst-case rank placeholder for each year/gender combo
  worst_ranks <- nat_names %>%
    group_by(year, gender) %>%
    summarise(worst_rank = max(rank) + 1, .groups = "drop")
  
  # 4. Vectorized Look-ahead matching (No slow loops!)
  ts_df <- top_now %>%
    cross_join(tibble(lag = lags)) %>% 
    mutate(year_future = year + lag) %>%
    left_join(
      nat_names %>% select(year_future = year, gender, name, rank_future = rank),
      by = c("year_future", "gender", "name")
    ) %>%
    left_join(worst_ranks, by = c("year_future" = "year", "gender")) %>%
    filter(!is.na(worst_rank)) %>% # Drop rows where look-ahead extends past dataset limits
    mutate(rank_future = ifelse(is.na(rank_future), worst_rank, rank_future)) %>%
    group_by(year, gender, lag) %>%
    summarise(
      rho = suppressWarnings(cor(rank_now, rank_future, method = "spearman")),
      .groups = "drop"
    )
  
  # 5. Plotting (Unchanged)
  plt <- ts_df %>%
    mutate(lag_label = paste0("+", lag, " yr")) %>%
    ggplot(aes(x = year, y = rho, color = lag_label)) +
    geom_line(linewidth = 0.6, alpha = 0.5) +
    geom_smooth(se = FALSE, span = 0.3, linewidth = 1.1) +
    geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
    facet_wrap(~gender, labeller = labeller(gender = c(F = "Girls", M = "Boys"))) +
    coord_cartesian(ylim = c(-0.2, 1)) +
    labs(
      title = "Persistence of each year's top-25 baby names into the future",
      subtitle = "Spearman rank correlation: this year's top-25 rank vs. their rank 1-3 years later\n(dashed line marks 1990)",
      x = "Year", y = "Spearman's rho", color = "Look-ahead"
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom")
  
  # 6. Table summary (Unchanged)
  era_comparison <- ts_df %>%
    mutate(era = ifelse(year < 1990, "pre_1990", "from_1990")) %>%
    group_by(gender, lag, era) %>%
    summarise(mean_rho = mean(rho, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = era, values_from = mean_rho) %>%
    mutate(drop_in_persistence = pre_1990 - from_1990)
  
  list(timeseries = ts_df, plot = plt, era_comparison = era_comparison)
}
