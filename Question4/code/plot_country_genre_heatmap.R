# Load necessary libraries
library(tidyverse)
library(tidytext)
library(ggrepel)
library(reshape2)
library(scales)
install.packages("ggrepl")
# HEATMAP: Countries vs. Genres (fill: IMDB Score)


plot_country_genre_heatmap <- function(titles, fill_metric = c("rating", "hours"),
                                       top_countries = 10, top_genres = 10) {
  fill_metric <- match.arg(fill_metric)
  
  long_df <- titles |>
    explode_list_col("genres", style = "bracket") |>
    explode_list_col("production_countries", style = "bracket") |>
    rename(genre = genres_single, country = production_countries_single) |>
    filter(!is.na(genre), genre != "", !is.na(country), country != "")
  
  top_c <- long_df |> count(country, sort = TRUE) |> slice_head(n = top_countries) |> pull(country)
  top_g <- long_df |> count(genre, sort = TRUE) |> slice_head(n = top_genres) |> pull(genre)
  
  plot_df <- long_df |>
    filter(country %in% top_c, genre %in% top_g) |>
    group_by(country, genre) |>
    summarise(
      rating = mean(imdb_score, na.rm = TRUE),
      hours  = sum(runtime, na.rm = TRUE) / 60,
      .groups = "drop"
    )
  
  fill_var <- if (fill_metric == "rating") "rating" else "hours"
  fill_lab <- if (fill_metric == "rating") "Avg IMDb score" else "Total content hours"
  
  ggplot(plot_df, aes(x = genre, y = country, fill = .data[[fill_var]])) +
    geom_tile(color = "white") +
    scale_fill_viridis_c(name = fill_lab, option = "magma") +
    labs(title = paste("Genre x Country heatmap -", fill_lab), x = "Genre", y = "Country") +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plot_country_genre_heatmap(net_d, c("imdb_score")