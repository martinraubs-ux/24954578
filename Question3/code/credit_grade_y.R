# credit_grade_y 

# Note: y_var should be passed as a string (e.g., "int_rate" or "is_default")
credit_grade_y <- function(data, y_var, plot_title, plot_subtitle, plot_ylab) {
  
  # Date threshold for "young" classification (e.g., year 2000)
  # Adjust this date cutoff depending on your business logic
  date_threshold <- as.Date("2000-01-01") 
  
  plot_data <- data %>%
    mutate(
      # Ensure earliest_cr_line is a Date object (adjust format if needed)
      # e.g., if it's "Jan-2000", you might need myd() or parse_date_time()
      cr_line_date = as.Date(earliest_cr_line), 
      emp_length_num = as.numeric(str_extract(emp_length, "\\d+")),
      
      # Create secondary group: Young vs Old
      age_group = ifelse(cr_line_date > date_threshold & emp_length_num < 5, "Young", "Old"),
      
      # Create a binary default column in case y_var is intended to be defaults
      is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)
    ) %>%
    # Filter out NAs in critical columns to prevent plotting errors
    filter(!is.na(age_group), !is.na(grade), !is.na(!!sym(y_var))) %>%
    group_by(grade, age_group) %>%
    # Calculate the mean of whatever y_var is passed in
    summarise(y_value = mean(!!sym(y_var), na.rm = TRUE), .groups = "drop")
  
  # Generate the plot
  ggplot(plot_data, aes(x = grade, y = y_value, fill = age_group)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("Young" = "#00BFC4", "Old" = "#F8766D")) +
    labs(
      title = plot_title,
      subtitle = plot_subtitle,
      x = "Credit Grade",
      y = plot_ylab,
      fill = "Credit Age",
      # Explaining how "Young" was created as requested
      caption = paste("Note: 'Young' is defined as earliest_cr_line after", 
                      format(date_threshold, "%Y"), "and employment length < 5 years.")
    ) +
    theme_minimal()
}




# Plot 1: Y-axis is Interest Rate
#plot_interest <- credit_grade_y(
#  data = loan_data, 
#  y_var = "int_rate", 
#  plot_title = "Average Interest Rate by Credit Grade",
#  plot_subtitle = "Segmented by Credit Age Profile",
#  plot_ylab = "Average Interest Rate (%)"
#)
#
# Plot 2: Y-axis is Defaults
# (Assuming you created the `is_default` binary column in your master data beforehand)
#plot_defaults <- credit_grade_y(
#  data = loan_data %>% mutate(is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)), 
#  y_var = "is_default", 
#  plot_title = "Default Rate by Credit Grade",
#  plot_subtitle = "Segmented by Credit Age Profile",
#  plot_ylab = "Default Rate"
#)