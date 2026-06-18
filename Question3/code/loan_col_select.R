#loan_col_select
library(tidyverse)
library(stringr)

loan_col_select <- function(filepath){
  
  d <- readRDS(filepath) %>% 
    mutate(
      # Overwrite loan_status with clean, grouped categories
      loan_status = case_when(
        # Grouping the losses
        loan_status %in% c("Charged Off", "Default") ~ "Default",
        
        # Keeping the successes
        loan_status == "Fully Paid" ~ "Fully Paid",
        
        # Keeping the active, up-to-date loans
        loan_status == "Current" ~ "Current",
        
        # Grouping the messy "in-progress but failing" categories
        str_detect(loan_status, "Late|Grace") ~ "Late",
        
        # Catch-all just in case
        TRUE ~ "Other"
      )
     ) %>% 
       
     filter(loan_status %in% c("Default", "Fully Paid")) %>%
    
    select(
      loan_status,       
      home_ownership,    
      emp_length,        
      term,              
      addr_state,        
      dti,               
      grade,             
      earliest_cr_line,  
      int_rate,
      avg_cur_bal,
      total_acc,
      sub_grade,
      emp_title,
      installment)       

    }

#loan_col_select()