# emp_length_bar


emp_length_bar <- function(data) {
  
  # Clean and categorize the data
  plot_data <- data %>%
    # Assuming emp_length is numeric or you extract the number. 
    # If it's text like "10+ years", you'd use readr::parse_number(emp_length) first.
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
      
      # Define default indicator (Modify "Charged Off" / "Default" to match your data)
      is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)
    ) %>%
    filter(emp_cat != "Unknown") %>%
    # Summarise data to count observations of defaults
    group_by(emp_cat, is_homeowner) %>%
    summarise(default_count = sum(is_default, na.rm = TRUE), .groups = "drop")
  
  # Generate the plot
  ggplot(plot_data, aes(x = emp_cat, y = default_count, fill = is_homeowner)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("Home Owner" = "steelblue", "Not Home Owner" = "darkorange")) +
    labs(
      title = "Number of Defaults by Employment Length and Home Ownership",
      x = "Employment Length (Years)",
      y = "Count of Defaults",
      fill = "Status"
    ) +
    theme_minimal()
}