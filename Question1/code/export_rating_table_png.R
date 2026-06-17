# table wrapper
library(dplyr)
library(flextable)
library(webshot2)

export_rating_table_png <- function(data, target_rating, output_filename) {
  
  # 1. Filter and extract the top 5 cheapest options (including roast)
  table_data <- data %>%
    filter(Rating == target_rating, 
           roast %in% c("Medium-Light", "Medium", "Light"),
           category %in% c("Sweet & Comforting", "Fruity & Vibrant")) %>%
    arrange(Cost_Per_100g) %>%
    slice_head(n = 5) %>%
    select(name, roaster, roast, Cost_Per_100g, loc_country) # Added roast here
  
  # 2. Build the flextable with custom dark theme + white text
  ft <- flextable(table_data) %>% 
    set_header_labels(
      name = "Name", 
      roaster = "Roaster", 
      roast = "Roast",               # Added column header mapping
      Cost_Per_100g = "Price/100g", 
      loc_country = "Country"
    ) %>%
    # Style the headers
    bg(bg = "#2c3e50", part = "header") %>%
    color(color = "white", part = "header") %>%
    bold(part = "header") %>%
    # Style the body cells
    bg(bg = "#34495e", part = "body") %>%
    color(color = "white", part = "body") %>%
    # Add subtle white gridlines
    border_inner(border = fp_border_default(color = "#ffffff", width = 0.5)) %>%
    border_outer(border = fp_border_default(color = "#ffffff", width = 1)) %>%
    autofit()
  
  # 3. Export as a crisp image
  save_as_image(ft, path = output_filename)
  

}

