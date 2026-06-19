# genre_spikes

library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(hrbrthemes)


plot_hbo_genres <- function(baby_names_df, hbo_df,
                            growth_threshold = 1.0,
                            min_n_threshold = 100) {

  #library(showtext)
  #  font_add_google("Quicksand", "quicksand")
   # showtext_auto()

    # 1. Clean and unnest the genre lists
    hbo_ref <- hbo_df %>%
        # Select necessary columns (Update 'character' and 'release_year' if needed)
        select(name = character, event_year = release_year, genres) %>%

        # Remove the brackets and single quotes from the strings
        mutate(genres = str_remove_all(genres, "\\[|\\]|'")) %>%

        # Split the comma-separated words and put each genre on its own row
        separate_rows(genres, sep = ",\\s*") %>%

        # Capitalize the first letter for a cleaner chart legend
        mutate(genres = str_to_title(genres)) %>%

        # Remove any accidental blanks and keep distinct combinations
        filter(genres != "" & !is.na(genres)) %>%
        distinct()

    # 2. Detect spikes in the baby names dataset
    plot_data <- baby_names_df %>%
        group_by(year, name) %>%
        summarise(N = sum(count, na.rm = TRUE), .groups = "drop") %>%
        arrange(name, year) %>%
        group_by(name) %>%
        mutate(
            prev_N = lag(N),
            pct_increase = ifelse(prev_N > 0, (N - prev_N) / prev_N, NA),
            is_spike = !is.na(pct_increase) & pct_increase > growth_threshold & N > min_n_threshold
        ) %>%
        ungroup()

    # 3. Match spikes to the HBO release windows and count by genre
    genre_counts <- plot_data %>%
        # Keep only the rows where a spike mathematically occurred
        filter(is_spike == TRUE) %>%
        # Join with our newly separated genre reference table
        inner_join(hbo_ref, by = "name",relationship = "many-to-many") %>%
        # Ensure the spike actually happened during the show's breakout window
        filter(year >= event_year & year <= event_year + 2) %>%

        # Count how many distinct pop-culture spikes belong to each genre
        group_by(genres) %>%
        summarise(total_spikes = n(), .groups = "drop") %>%

        # Sort from highest to lowest
        arrange(desc(total_spikes)) %>%

        # Optional: Limit to the top 15 genres if your dataset is massive
        slice_head(n = 15)

    # 4. Generate the horizontal bar chart
    p <- ggplot(genre_counts, aes(x = reorder(genres, total_spikes), y = total_spikes)) +
        geom_col(fill = "#E63946", alpha = 0.85, width = 0.7) +

        # Add text labels at the end of the bars
        geom_text(aes(label = total_spikes),
                  hjust = -0.3, fontface = "bold", size = 4.5, color = "grey30") +

        # Flip coordinates so genre names are easily readable on the Y-axis
        coord_flip() +

        # Expand the Y-axis limit slightly so the text labels don't get cut off
        scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +

        labs(
            title = "HBO Genres Driving the Most Name Spikes",
            subtitle = paste0("Total >", (growth_threshold * 100), "% YoY growth events triggered within 2 years of a release"),
            x = NULL, # Removed as the genre names explain themselves
            y = "Total Number of Spikes"
        ) +
        theme_minimal(base_size = 14) +
        theme(
            panel.grid.major.y = element_blank(),
            panel.grid.minor = element_blank(),
            plot.title = element_text(face = "bold", size = 16),
            axis.text.y = element_text(face = "bold")
        )

    p + theme_ipsum(
        base_family = "Arial", # Or "Helvetica", "Roboto"
        grid = "Y",                   # Only show horizontal gridlines for bar charts
        plot_title_size = 18,
        subtitle_size = 13,
        axis_title_size = 12
    ) +
        theme(
            plot.title = element_text(face = "bold"),
            plot.margin = margin(20, 20, 20, 20) # Gives the chart room to breathe
        )
    return(p)
}

# Example
# hbo_genres_plot <- plot_hbo_genres(Baby_Names, hbo)
# hbo_genres_plot