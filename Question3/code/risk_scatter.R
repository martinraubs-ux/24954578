# risk_density
 
 risk_density <- function(data) {
   
   plot_data <- data %>%
     filter(loan_status %in% c("Default", "Fully Paid"), !is.na(int_rate))
   
   p <- ggplot(plot_data, aes(x = int_rate, fill = loan_status)) +
     # Density plot with 50% transparency so you can see where they overlap
     geom_density(alpha = 0.5, color = "black") +
     scale_fill_manual(values = c("Default" = "#c0392b", "Fully Paid" = "#7f8c8d")) +
     labs(
       title = "Interest Rate Distribution: Defaults vs. Paid Loans",
       subtitle = "Defaults are heavily concentrated at the higher end of the pricing spectrum",
       x = "Interest Rate (%)",
       y = "Density (Volume of Loans)",
       fill = "Loan Outcome"
     ) +
     # Remove the Y-axis numbers since "density" math is confusing for business audiences
     theme_minimal() +
     theme(
       axis.text.y = element_blank(),
       legend.position = "bottom"
     )
   
   return(p)
 }


