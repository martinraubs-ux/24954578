# credit_grade_y 
credit_grade_y <- function(data, y_var, plot_title, plot_subtitle, plot_ylab) {
  
  # 1. Prepare the data
  plot_data <- data %>%
    mutate(
      emp_length_num = as.numeric(str_extract(emp_length, "\\d+")),
      
      # Cleaned up the spacing so the legend matches perfectly
      age_group = ifelse(total_acc < 10 & emp_length_num < 5, "Young (proxy)", "Established"),
      
      is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)
    ) %>%
    filter(!is.na(age_group), !is.na(grade), !is.na(!!sym(y_var))) %>%
    group_by(grade, age_group) %>%
    summarise(y_value = mean(!!sym(y_var), na.rm = TRUE), .groups = "drop")
  
  # 2. Generate the plot and explicitly assign it to 'p'
  p <- ggplot(plot_data, aes(x = grade, y = y_value, fill = age_group)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("Young (proxy)" = "#00BFC4", "Established" = "#F8766D")) +
    labs(
      title = plot_title,
      subtitle = plot_subtitle,
      x = "Credit Grade",
      y = plot_ylab,
      fill = "Credit Profile",
      caption = "Note: 'Young (proxy)' is defined as < 10 total accounts AND employment length < 5 years."
    ) +
    theme_minimal()
  
  # 3. Force R to output the plot
  return(p)
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


