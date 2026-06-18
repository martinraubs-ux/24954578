# risk_scatter


risk_scatter <- function(data) {
  
  # Prepare the data
  plot_data <- data %>%
    mutate(
      # Create a categorical column for Default vs Non-Default
      is_default = ifelse(loan_status %in% c("Charged Off", "Default"), "Default", "Paid/Current")
    ) %>%
    # Filter out NAs for the plotting variables to prevent ggplot warnings
    filter(!is.na(avg_cur_bal), !is.na(dti), !is.na(is_default))
  
  # Generate the scatter plot
  ggplot(plot_data, aes(x = dti, y = avg_cur_bal, color = is_default)) +
    # Using alpha = 0.4 helps visualize density when points overlap
    geom_point(alpha = 0.4, size = 1.5) + 
    # Use distinct colors to highlight defaults (e.g., Red for Default, Grey for others)
    scale_color_manual(values = c("Default" = "#E41A1C", "Paid/Current" = "#999999")) +
    labs(
      title = "Risk Profile: Average Current Balance vs. Debt-to-Income",
      x = "Debt-to-Income Ratio (DTI)",
      y = "Average Current Balance ($)",
      color = "Loan Status"
    ) +
    # Optionally scale the Y-axis to show labels as standard numbers instead of scientific notation
    scale_y_continuous(labels = scales::comma) +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    )
}