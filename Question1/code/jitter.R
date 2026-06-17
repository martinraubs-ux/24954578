library(ggplot2)

jitter_plot <- function(data, x_var, y_var) {
  
  # --- Input validation ---
  if (!is.data.frame(data)) stop("`data` must be a data frame.")
  
  resolve_col <- function(var, data, arg_name) {
    if (is.character(var) && length(var) == 1 && var %in% names(data)) {
      return(var)
    } else if (length(var) == nrow(data)) {
      matched <- names(data)[sapply(data, function(col) identical(col, var))]
      if (length(matched) == 0) stop(paste0("Could not match `", arg_name, "` to a column in `data`."))
      return(matched[[1]])
    } else {
      stop(paste0("`", arg_name, "` must be a column name string or a column from `data`."))
    }
  }
  
  x_var <- resolve_col(x_var, data, "x_var")
  y_var <- resolve_col(y_var, data, "y_var")
  
  data[[x_var]] <- as.factor(data[[x_var]])
  
  p <- ggplot(data, aes(x = .data[[x_var]], y = .data[[y_var]], colour = .data[[x_var]])) +
    
    # Violin layer
    geom_violin(
      aes(fill = .data[[x_var]]),
      alpha     = 0.15,
      colour    = NA,
      width     = 0.7
    ) +
    
    # Whiskers only  — 1.5 × IQR
    stat_boxplot(
      geom      = "errorbar",
      width     = 0.25,
      linewidth = 0.5,
      colour    = "grey40"
    ) +
    
    # Jitter layer
    geom_jitter(
      width  = 0.18,
      height = 0,
      size   = 2.2,
      alpha  = 0.75
    ) +
    
    # Median crossbar
    stat_summary(
      fun       = median,
      geom      = "crossbar",
      width     = 0.35,
      linewidth = 0.6,
      colour    = "grey20"
    ) +
    
    scale_colour_brewer(palette = "Set2", guide = "none") +
    scale_fill_brewer(palette = "Set2", guide = "none") +
   
    labs(
      title    = "Coffea Bean Ratings by Flavour Profile",
      subtitle = "Each point represents one bean; whiskers = 1.5 × IQR, crossbar = median",
      x        = gsub("_", " ", tools::toTitleCase(x_var)),
      y        = gsub("_", " ", tools::toTitleCase(y_var))
    ) +
    
    theme_minimal(base_size = 13) +
    theme(
      plot.title         = element_text(face = "bold", size = 15, margin = margin(b = 4)),
      plot.subtitle      = element_text(colour = "grey45", size = 10, margin = margin(b = 12)),
      axis.text.x = element_text(face = "bold", angle = 30, hjust = 1),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank()
    )
  
  return(p)
}

#jitter_plot(d, "category","Rating")
