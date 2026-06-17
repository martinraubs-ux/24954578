# Jitter


# 1. Identify the 5 countries that produced the most coffees in the dataset
most_enoyed_var <- df %>%
  count(loc_country, sort = TRUE) %>%
  slice(1:5) %>%
  pull(loc_country) # Extracts just the names into a vector

# 2. Filter the data and plot
Menu_df %>%
  filter(loc_country %in% top_5_countries) %>%
  
  # reorder() automatically sorts the boxes from lowest to highest median rating!
  ggplot(aes(x = reorder(loc_country, Rating, FUN = median, na.rm = TRUE), y = Rating, fill = loc_country)) +
  
  # outlier.shape = NA stops R from drawing duplicate dots
  geom_boxplot(outlier.shape = NA, alpha = 0.4) + 
  
  # The jitter scatters the dots slightly so they don't overlap into a solid black line
  geom_jitter(width = 0.2, alpha = 0.6, color = "#4E342E", size = 1.5) +
  
  theme_bw() +
  theme(legend.position = "none") + # Hide the legend since the x-axis has the names
  labs(
    title = "Coffee Ratings by Top 5 Sourcing Countries",
    x = "Country of Origin",
    y = "Review Score"
  )