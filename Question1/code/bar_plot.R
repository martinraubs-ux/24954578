# bar_plot
library(tidyverse)

plot_flavor_menu <- function(coffee_df,   title = "Coffee Market supply",
                             subtitle = "Roast levels broken down by flavour profiles",
                             xlab = "Roast Level",
                             ylab = "Number of Coffees",
                             fill_lab = "Flavor Profile") {
  
  # Build and store the plot
  menu_plot <- coffee_df %>%
    # Drop rows where the roast or category is missing to keep the chart clean
    drop_na(roast, category) %>% 
    
    # fct_infreq() is a brilliant trick that automatically sorts bars from tallest to shortest!
    ggplot(aes(x = fct_infreq(roast), fill = category)) +
    
    geom_bar(position = "stack", color = "white", alpha = 0.9) +
    scale_fill_brewer(palette = "YlOrBr") + 
    
    theme_minimal() +
    labs(
      title = title,
      subtitle = subtitle,
      x = xlab,
      y = ylab,
      fill = fill_lab
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 11, face = "bold"),
      legend.position = "right",
      panel.grid.major.x = element_blank() 
    )
  
  # Output the final graphic
  return(menu_plot)
}

plot_flavor_menu(d)





