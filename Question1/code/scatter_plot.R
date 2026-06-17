#scatter_price_per_rating 


library(dplyr)
library(ggplot2)

scatter_price_per_rating <- function(data, 
                                     ratings = 90:97, 
                                     roasts = c("Medium-Light", "Medium", "Light"), 
                                     categories = c("Sweet & Comforting", "Fruity & Vibrant"), 
                                     n_cheapest = 5, 
                                     title = "5 Cheapest Coffees per Rating Level", 
                                     color_palette = "Dark2") {
  
  # 1. Dynamically filter and slice the data based on arguments
  plot_data <- data %>% 
    filter(Rating %in% ratings) %>% 
    filter(roast %in% roasts) %>% 
    filter(category %in% categories) %>% 
    group_by(Rating) %>% 
    arrange(Cost_Per_100g, .by_group = TRUE) %>% 
    slice_head(n = n_cheapest) %>% 
    ungroup()
  
  # 2. Generate the plot mapping your custom title and palette
  p <- ggplot(plot_data, aes(x = Rating, y = Cost_Per_100g, color = roast)) +
    geom_point(size = 3, alpha = 0.8) +
    scale_color_brewer(palette = color_palette) + 
    scale_x_continuous(breaks = ratings) + # Makes sure every rating in your vector shows up
    labs(
      title = title,
      x = "Rating",
      y = "Cost per 100g ($)",
      color = "Roast Type"
    ) +
    theme_minimal()
  
  return(p)
}

