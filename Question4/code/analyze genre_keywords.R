library(tidytext)
analyze_genre_keywords <- function(titles, genres_of_interest, high_thresh = 7,
                                   low_thresh = 4, top_n = 8) {
  long_df <- titles |>
    explode_list_col("genres", style = "bracket") |>
    rename(genre = genres_single) |>
    filter(genre %in% genres_of_interest, !is.na(imdb_score), !is.na(description)) |>
    mutate(tier = case_when(
      imdb_score >= high_thresh ~ "High rated",
      imdb_score <= low_thresh  ~ "Low rated",
      TRUE ~ NA_character_
    )) |>
    filter(!is.na(tier))
  
  word_counts <- long_df |>
    select(id, genre, tier, description) |>
    distinct() |>
    unnest_tokens(word, description) |>
    anti_join(stop_words, by = "word") |>
    filter(!grepl("^[0-9]+$", word), nchar(word) > 2) |>
    count(genre, tier, word, sort = TRUE) |>
    group_by(genre, tier) |>
    slice_max(n, n = top_n, with_ties = FALSE) |>
    ungroup()
  
  plt <- ggplot(word_counts,
                aes(x = reorder_within(word, n, interaction(genre, tier)), y = n, fill = tier)) +
    geom_col(show.legend = TRUE) +
    scale_x_reordered() +
    coord_flip() +
    facet_wrap(genre ~ tier, scales = "free_y") +
    scale_fill_manual(values = c("High rated" = "#1b9e77", "Low rated" = "#d95f02")) +
    labs(title = "Most frequent description words: high vs. low rated titles",
         x = NULL, y = "Word count", fill = "Rating tier") +
    theme_minimal(base_size = 10)
  
  list(table = word_counts, plot = plt)
}

#analyze_genre_keywords(titles, c("drama","comedy"), high_thresh = 7,low_thresh = 4, top_n = 8)
