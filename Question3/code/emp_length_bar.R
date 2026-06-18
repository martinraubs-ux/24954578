# emp_length_bar

emp_length_bar <- function(data) {
  
  # Clean and categorize the data
  plot_data <- data %>%
    mutate(
      emp_length_num = as.numeric(str_extract(emp_length, "\\d+")),
      # Create the 6 categories requested
      emp_cat = case_when(
        emp_length_num < 2 ~ "<2",
        emp_length_num >= 2 & emp_length_num < 4 ~ "2<4",
        emp_length_num >= 4 & emp_length_num < 6 ~ "4<6",
        emp_length_num >= 6 & emp_length_num < 8 ~ "6<8",
        emp_length_num >= 8 & emp_length_num < 10 ~ "8<10",
        emp_length_num >= 10 ~ "10<",
        TRUE ~ "Unknown"
      ),
      # Ensure proper ordering of the x-axis factors
      emp_cat = factor(emp_cat, levels = c("<2", "2<4", "4<6", "6<8", "8<10", "10<", "Unknown")),
      
      # Define Home Owner vs Not Home Owner
      is_homeowner = ifelse(home_ownership %in% c("MORTGAGE", "OWN"), "Home Owner", "Not Home Owner"),
      
      # Define default indicator (1 for default, 0 for paid/current)
      is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)
    ) %>%
    filter(emp_cat != "Unknown") %>%
    # Group by employment category and home ownership
    group_by(emp_cat, is_homeowner) %>%
    # Calculate the percentage of defaults (Default Rate) instead of a pure count
    summarise(default_pct = mean(is_default, na.rm = TRUE), .groups = "drop")
  
  # Generate the plot
  ggplot(plot_data, aes(x = emp_cat, y = default_pct, fill = is_homeowner)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("Home Owner" = "steelblue", "Not Home Owner" = "darkorange")) +
    # Format the Y-axis to show percentages (e.g., 15.0%)
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    labs(
      title = "Default Rate by Employment Length and Home Ownership",
      x = "Employment Length (Years)",
      y = "Default Rate (%)",
      fill = "Status"
    ) +
    theme_minimal()
}


