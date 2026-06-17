# Map
# Map showing the ratings

library(maps)

# 1. Get the geographical map coordinates
world_map <- map_data("world")

# 2. Calculate average rating per country from your coffee data
country_ratings <- d %>%
  select(Rating,Cost_Per_100g,name,country_1,country_2)
  pivot_longer(
    cols = c(country_1,country_2),
    names_to = "Country",
    values_to = "value"
  ) %>%
  filter(!str_detect(value, regex("unmapped", ignore_case = TRUE)))
  
  mutate
  group_by(origin_1) %>%
  summarise(Avg_Rating = median(Rating, na.rm = TRUE))

# 3. Join the coffee data onto the map data
# (Note: R's world map calls the country column "region")
map_data_joined <- world_map %>%
  left_join(country_ratings, by = c("region" = "origin_1"))

# 4. Build the Map Plot
ggplot(map_data_joined, aes(x = long, y = lat, group = group)) +
  # fill = Avg_Rating drives the color!
  geom_polygon(aes(fill = Avg_Rating), color = "white", linewidth = 0.1) +
  
  # Make the low ratings a light tan, and high ratings a dark coffee brown
  scale_fill_gradient(low = "#D7CCC8", high = "#3E2723", na.value = "gray80") +
  theme_void() +
  labs(
    title = "Global Coffee Quality",
    subtitle = "Darker regions indicate higher average review scores",
    fill = "Avg Rating"
  )