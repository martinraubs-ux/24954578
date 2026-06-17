# Global Value for money heatmap
#

library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(maps)

coffee_value_map <- function(d) {
  producer_counts <- d %>%
    select(name, Rating, Cost_Per_100g, country_1, country_2) %>%
    pivot_longer(
      cols = c(country_1, country_2),
      names_to = "origin_col",
      values_to = "country"
    ) %>%
    
    # Remoivng unmapped and coffea from multiple countries
    filter(
      !is.na(country),
      !str_detect(country, regex("unmapped", ignore_case = TRUE)),
      !str_detect(country, regex("multi-country", ignore_case = TRUE)),
      country != "Unknown",
      Cost_Per_100g > 0
    ) %>%
    distinct(name, country, .keep_all = TRUE) %>%
    mutate(value_ratio = Rating / Cost_Per_100g) %>%
    group_by(country) %>%
    summarise(avg_value = mean(value_ratio, na.rm = TRUE), .groups = "drop")
  
  # fixing names for map package
  name_patch <- c(
    "USA (Hawaii)" = "USA",
    "Democratic Republic of Congo" = "Democratic Republic of the Congo",
    "East Timor" = "Timor-Leste"
  )
  
  producer_counts <- producer_counts %>%
    mutate(country = recode(country, !!!name_patch))
  
  world_map <- map_data("world")
  
  map_joined <- world_map %>%
    left_join(producer_counts, by = c("region" = "country"))
  
  ggplot(map_joined, aes(x = long, y = lat, group = group)) +
    geom_polygon(
      aes(fill = avg_value),
      colour = "white",
      linewidth = 0.1
    ) +
    scale_fill_gradient(
      low = "#D7CCC8",
      high = "#3E2723",
      na.value = "grey85",
      name = "Avg Rating\n/ Price",
      labels = scales::number_format(accuracy = 0.1)
    ) +
    coord_fixed(1.3) +
    theme_void() +
    labs(
      title = "Coffee Value-for-Money by Origin",
      subtitle = "Darker = higher average rating per dollar spent"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 15, margin = margin(b = 4)),
      plot.subtitle = element_text(colour = "grey45", size = 10, margin = margin(b = 8)),
      legend.position = "bottom",
      legend.key.width = unit(2, "cm"),
      legend.title.align = 0.5
    )
}