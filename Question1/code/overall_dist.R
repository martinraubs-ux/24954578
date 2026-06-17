# overall_dist
#
#
d %>% Cost_
overall_dist <-function(d,var, bar_colour ="795548",xlab = "", ylab = "Number of Coffees"){
  
g <- d %>% 
  ggplot( aes(x = var)) +
  # You might need to tweak binwidth depending on if ratings are 1-100 or 1-10
  geom_histogram(binwidth = 1, fill = bar_colour, color = "white", alpha = 0.9) +
  
  # Add a vertical dashed line to show the mathematical average!
  geom_vline(aes(xintercept = mean(var, na.rm = TRUE)), 
             color = "red", linetype = "dashed", linewidth = 1) +
  
  theme_minimal() +
  labs(
    title = "Distribution of All Coffee Ratings",
    subtitle = "Red dashed line indicates the overall average",
    x = xlab,
    y = ylab
  )

g
}

overall_dist(Coffee,
             Cost_Per_100g)