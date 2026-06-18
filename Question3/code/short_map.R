# short_map


short_map <- function(data) {
  
  # 1. Filter for short term loans and calculate state summaries
  state_summary <- data %>%
    # Filter short term (assuming " 36 months" is short term, adjust if necessary)
    filter(str_detect(term, "36")) %>% 
    mutate(is_default = ifelse(loan_status %in% c("Charged Off", "Default"), 1, 0)) %>%
    group_by(addr_state) %>%
    summarise(
      default_rate = mean(is_default, na.rm = TRUE),
      avg_dti = mean(dti, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    # usmap needs a 'state' column for mapping
    rename(state = addr_state) 
  
  # 2. Identify top 5, bottom 5, and Texas for the textbox
  top_5 <- state_summary %>% arrange(desc(default_rate)) %>% slice_head(n = 5)
  bot_5 <- state_summary %>% arrange(default_rate) %>% slice_head(n = 5)
  texas <- state_summary %>% filter(state == "TX")
  
  # Format a helper function for text
  format_text <- function(df) {
    paste(df$state, "- Def Rate:", scales::percent(df$default_rate, 0.1), 
          "| DTI:", round(df$avg_dti, 1), collapse = "\n")
  }
  
  # Combine text for annotation
  annotation_box <- paste0(
    "Highest Defaults:\n", format_text(top_5), "\n\n",
    "Lowest Defaults:\n", format_text(bot_5), "\n\n",
    "Texas Overview:\n", format_text(texas)
  )
  
  # 3. Generate the map (using usmap package)
  plot_usmap(data = state_summary, values = "default_rate", regions = "states") +
    scale_fill_continuous(
      low = "lightblue", high = "darkblue", 
      name = "Default Rate", label = scales::percent
    ) +
    labs(title = "Default Rates for Short-Term Loans by US State") +
    theme(legend.position = "right") +
    # Add the text box to the side of the map
    annotate(
      "label", x = Inf, y = -Inf, label = annotation_box, 
      hjust = 1, vjust = 0, size = 3, fill = "white", alpha = 0.8
    )
}