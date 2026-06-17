# pie_cat
# pie chart of categories students like
#

library(tidyverse)
library(ggplot2)

pie_cat <- function(d, var, title, subtitle, fill_label) {
  g <- d %>%
    # Calculate the proportions first
    count({{var}}) %>%
    mutate(Percentage = n / sum(n)) %>%
    
    # Build the Plot
    ggplot(aes(x = "", y = Percentage, fill = {{var}})) +
    geom_bar(stat = "identity", width = 1, color = "white") + # White borders look clean
    coord_polar("y", start = 0) + # This turns the bar into a pie!
    theme_void() +
    labs(
      title = title,
      subtitle = subtitle,
      fill = fill_label
    ) +
    scale_fill_brewer(palette = "Set2") # Gives it a nice, modern color palette
  g
}

pie_cat(d, category, 
        title = "Taste profiles of the market",
        subtitle = "Taste profiles are created by Maties Student Flavor Preferences",
        fill_label = "Taste Profile")