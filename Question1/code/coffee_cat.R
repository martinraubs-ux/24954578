# coffee_cat
# Full name: coffee categoriser
#
# The idea is to use the words that student use to describe the coffee
# to catergorize reviewers's descriptions.
#
library(tidyverse)
library(stringr)

coffee_cat <- function(coffee_df, 
                       sweet_words = c("sweet", "chocolate", "cocoa", "honey", "caramel", "molasses", "syrup", "vanilla", "syrupy", "butter"),
                       fruity_words = c("fruit", "tart", "zest", "bright", "juicy", "lemon", "peach", "orange", "grapefruit", "strawberry", "blackberry", "mango", "cherry", "apricot", "currant"),
                       bold_words = c("savory", "spice", "roasted", "dark", "cedar", "tobacco", "baker", "sandalwood", "espresso"),
                       nutty_words = c("almond", "hazelnut", "smooth", "velvety", "rich"),
                       floral_words = c("floral", "jasmine", "lavender", "rose")){
  
  # 1. Collapse the input words into Regex search strings
  profile_sweet  <- paste(sweet_words, collapse = "|")
  profile_fruity <- paste(fruity_words, collapse = "|")
  profile_bold   <- paste(bold_words, collapse = "|")
  profile_nutty  <- paste(nutty_words, collapse = "|")
  profile_floral <- paste(floral_words, collapse = "|")
  
  # 2. Apply the logic to tag the coffees
  Menu_df <- coffee_df %>%
    
    unite(col = "full_description", 
          desc_1, desc_2, desc_3, 
          sep = " ",        
          remove = FALSE,   
          na.rm = TRUE) %>%
    
    mutate(
      # BUG FIX: Standardize full_description to lowercase, not just desc_1!
      desc_clean = str_to_lower(full_description),
      
      # UPGRADE: Count the number of matches instead of just checking True/False
      count_sweet  = str_count(desc_clean, profile_sweet),
      count_fruity = str_count(desc_clean, profile_fruity),
      count_bold   = str_count(desc_clean, profile_bold),
      count_nutty  = str_count(desc_clean, profile_nutty),
      count_floral = str_count(desc_clean, profile_floral)
    ) %>%
    
    # Rowwise magic to find the highest scoring category per coffee
    rowwise() %>%
    mutate(
      max_score = max(c_across(starts_with("count_"))),
      
      # Assign the business-friendly label to your 'category' column
      category = case_when(
        max_score == 0 ~ "Classic / Balanced",
        max_score == count_sweet  ~ "Sweet & Comforting",
        max_score == count_fruity ~ "Fruity & Vibrant",
        max_score == count_nutty  ~ "Smooth & Nutty",
        max_score == count_floral ~ "Floral & Delicate",
        max_score == count_bold   ~ "Bold & Earthy",
        TRUE ~ "Classic / Balanced"
      )
    ) %>%
    ungroup() %>% # Always ungroup after using rowwise!
    
    # Clean up the final table for the entrepreneur
    select(name, roaster, loc_country, Rating, Cost_Per_100g, roast, category, origin_1, origin_2)
  
  return(Menu_df)
}