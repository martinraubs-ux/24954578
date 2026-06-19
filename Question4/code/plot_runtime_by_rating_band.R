#plot_runtime_by_rating_band

plot_runtime_by_rating_band <- function(titles, breaks = seq(7, 10, by = 0.5)) {
  df <- titles |>
    filter(!is.na(imdb_score), !is.na(runtime),
           imdb_score >= min(breaks), imdb_score <= max(breaks)) |>
    mutate(rating_band = cut(imdb_score, breaks = breaks, right = FALSE,
                             include.lowest = TRUE, dig.lab = 2))
  
  ggplot(df, aes(x = rating_band, y = runtime, fill = rating_band)) +
    geom_boxplot(outlier.alpha = 0.4, show.legend = FALSE) +
    scale_fill_viridis_d(option = "viridis") +
    labs(title = "Runtime across high IMDb-score bands (7.0-10.0)",
         x = "IMDb score band", y = "Runtime (minutes)") +
    theme_minimal(base_size = 11)
}
#plot_runtime_by_rating_band(titles, breaks = seq(7, 10, by = 0.5))
