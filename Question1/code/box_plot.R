# box_plot
#
library(tidyverse)

plot_binned_boxplot <- function(df, 
                                x_var, 
                                y_var, 
                                facet_var, 
                                median_var,
                                plot_title = "Rating by Cost Categories",
                                plot_subtitle = "Cost segmented into 4 quartiles",
                                x_label = "Cost Category",
                                y_label = "Rating") {
  
  # 1. CLEAN & BIN DATA: Split the continuous x_var into 4 categories
  plot_data <- df %>%
    drop_na({{ x_var }}, {{ y_var }}, {{ facet_var }}, {{ median_var }}) %>%
    mutate(
      x_category = cut_number({{ x_var }}, n = 4, 
                              labels = c("Very Cheap", "Cheap", 
                                         "Medium", "Expensive"))
    )
  
  # 2. PRE-CALCULATION: Find the medians and the highest Y-value for text placement
  label_data <- plot_data %>%
    group_by(x_category, {{ facet_var }}) %>%
    summarise(
      # Calculate the median of whatever variable you input
      med_val = median({{ median_var }}, na.rm = TRUE),
      
      # We need the highest y-value in each group so we know exactly how high 
      # to place the text so it hovers above the box's top whisker
      label_y_pos = max({{ y_var }}, na.rm = TRUE),
      .groups = "drop"
    )
  
  # 3. BUILD THE PLOT
  final_plot <- ggplot(plot_data, aes(x = x_category, y = {{ y_var }})) +
    
    # Build the boxplot
    geom_boxplot(aes(fill = x_category), color = "black", alpha = 0.8) +
    
    # Add the facet wrap
    facet_wrap(vars({{ facet_var }})) +
    
    # Add the median text ABOVE the boxes
    geom_text(
      data = label_data,
      aes(x = x_category, y = label_y_pos, label = round(med_val, 1)),
      vjust = -0.8, # Nudges the text slightly above the maximum y value
      fontface = "bold",
      color = "black"
    ) +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.15))) +
    
    scale_fill_brewer(palette = "YlOrBr") +
    theme_bw() + 
    labs(
      title = plot_title,
      subtitle = plot_subtitle,
      x = x_label,
      y = y_label
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
      legend.position = "none", # Hide legend since the x-axis has the names
      strip.background = element_rect(fill = "#4E342E"), # Dark coffee color for facet headers
      strip.text = element_text(color = "white", face = "bold")
    )
  
  return(final_plot)
}


#plot_binned_boxplot(
#  df         = d, 
#  x_var      = Cost_Per_100g,   # Make sure the 'P' is capitalized if your dataset has it that way!
#  y_var      = Rating,          # The variable for the y-axis
#  facet_var  = roast,           # The variable to split the plots by
#  median_var = Rating           # The variable to calculate the median for
#)