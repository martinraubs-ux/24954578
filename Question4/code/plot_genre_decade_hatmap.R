# plot_genre_decade_heatmap
plot_genre_decade_heatmap <- function(titles, top_n = 12) {
  long_df <- titles |>
    explode_list_col("genres", style = "bracket") |>
    rename(genre = genres_single) |>
    filter(!is.na(genre), genre != "", !is.na(release_year)) |>
    mutate(decade = paste0((release_year %/% 10) * 10, "s"))
  
  top_g <- long_df |> count(genre, sort = TRUE) |> slice_head(n = top_n) |> pull(genre)
  totals <- long_df |> distinct(id, decade) |> count(decade, name = "decade_total")
  
  plot_df <- long_df |>
    filter(genre %in% top_g) |>
    count(decade, genre, name = "n") |>
    left_join(totals, by = "decade") |>
    mutate(share = n / decade_total)
  
  ggplot(plot_df, aes(x = decade, y = genre, fill = share)) +
    geom_tile(color = "white") +
    scale_fill_viridis_c(name = "Share within decade", labels = percent) +
    labs(title = "Genre composition by decade", x = "Decade", y = "Genre") +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}
plot_genre_decade_heatmap(titles)
