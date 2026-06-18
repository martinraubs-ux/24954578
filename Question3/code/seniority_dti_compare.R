#seniority_dti_compare




seniority_dti_compare <- function(data) {
  
  senior_regex <- "(?i)\\b(senior|sr|director|vp|vice president|president|chief|manager|lead|head|exec|executive)\\b"
  
  plot_data <- data %>%
    # Filter out missing values for the variables we are actually using
    filter(!is.na(emp_title), !is.na(dti), !is.na(int_rate)) %>%
    mutate(
      # 1. Create binary seniority category
      seniority = ifelse(
        str_detect(emp_title, senior_regex), 
        "Senior / Management", 
        "Other / Non-Senior"
      ),
      
      # 2. Categorize DTI into 4 discrete levels
      dti_cat = case_when(
        dti < 15 ~ "1. Low DTI (< 15)",
        dti >= 15 & dti < 20 ~ "2. Mid DTI (15-20)",
        dti >= 20 & dti < 30 ~ "3. High DTI (20-30)",
        dti >= 30 ~ "4. Very High DTI (30+)",
        TRUE ~ "Unknown"
      )
    ) %>%
    filter(dti_cat != "Unknown")
  # Note: No group_by() or summarise() needed here! 
  # We want every individual loan's interest rate for the boxplot.
  
  # Generate the boxplot
  ggplot(plot_data, aes(x = seniority, y = int_rate, fill = seniority)) +
    geom_boxplot(alpha = 0.7, outlier.alpha = 0.2, outlier.size = 1) +
    scale_fill_manual(values = c("Senior / Management" = "#2c3e50", "Other / Non-Senior" = "#e74c3c")) +
    # Facet wrap based on the DTI categories
    facet_wrap(~ dti_cat) +
    labs(
      title = "Interest Rates by Job Seniority",
      subtitle = "Distribution of loan interest rates, faceted by DTI tiers",
      x = "Detected Job Seniority Level",
      y = "Interest Rate (%)",
      caption = "Note: Each data point in the boxplot represents an individual loan."
    ) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.spacing = unit(1, "lines")
    )
}




