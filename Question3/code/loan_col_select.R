#loan_col_select


loan_col_select <- function(filepath){
  
  d <- readRDS(filepath) %>% 
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
      avg_cur_bal)       
}

#loan_col_select()