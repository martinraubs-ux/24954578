# clean_csv_import
#
# This function is designed to silently read csv files
# that has characters  that excel struggles to display
#

library(tidyverse)

clean_csv_import <- function(datroot) {
  
  # Do not want to see warnings
  quiet_read <- purrr::quietly(read_csv)
  
  # Run the quiet function with the UTF-8 locale. 
  import_data <- quiet_read(datroot, locale = locale(encoding = "UTF-8"))
  
  # Extract dataset 
  df <- import_data$result
  
  # Sweep all text columns to neutralize any remaining broken bytes
  df <- df %>%
    mutate(across(where(is.character), ~iconv(., to = "UTF-8", sub = "IGNORE")))
  
  df
}

# Example
# Coffee <- clean_csv_import("data/Coffee/Coffee.csv")