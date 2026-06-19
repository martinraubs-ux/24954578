# bubble_plot

library(dplyr)
library(ggplot2)
#library(plotly)

build_pop_culture_plot <- function(baby_names_df, chart_df, hbo_df,
                                   growth_threshold = 1.0,
                                   min_n_threshold = 100) {

    # 1. Format the Billboard chart reference
    # (Adding the 'song' column to pass through as catalyst_detail)
    chart_ref <- chart_df %>%
        group_by(artist) %>%
        arrange(peak_rank, year) %>%
        slice(1) %>%
        ungroup() %>%
        select(name = artist, event_year = year, catalyst_detail = song) %>%
        mutate(source = "Billboard Chart Spike") %>%
        distinct()

    # 2. Format the HBO reference
    # (Adding the movie/show column to pass through as catalyst_detail)
    hbo_ref <- hbo_df %>%
        select(name = character, event_year = release_year, catalyst_detail = title) %>%
        mutate(source = "HBO Influence") %>%
        distinct()

    # 3. Combine references into one lookup table
    pop_culture_events <- bind_rows(hbo_ref, chart_ref)

    # 4. Aggregate baby names, detect spikes, and link to events
    plot_data <- baby_names_df %>%
        group_by(year, name) %>%
        summarise(N = sum(count), .groups = "drop") %>%
        arrange(name, year) %>%
        group_by(name) %>%
        mutate(
            prev_N = lag(N),
            pct_increase = ifelse(prev_N > 0, (N - prev_N) / prev_N, NA),
            is_spike = !is.na(pct_increase) & pct_increase > growth_threshold & N > min_n_threshold
        ) %>%
        ungroup() %>%
        left_join(pop_culture_events, by = "name", relationship = "many-to-many") %>%
        mutate(
            type = case_when(
                is_spike & !is.na(event_year) & (year >= event_year & year <= event_year + 2) ~ source,
                TRUE ~ "Baseline/No Link"
            ),
            # Create a clean, custom text label for Plotly to use
            tooltip_label = paste0(
                "Name: ", name, "\n",
                "Year: ", year, "\n",
                "Total Births: ", N, "\n",
                "Link: ", type,
                # Only add the detail line if there is a pop culture link
                ifelse(!is.na(catalyst_detail) & type != "Baseline/No Link",
                       paste0("\nDetail: ", catalyst_detail), "")
            )
        ) %>%
        # Filter dataset to only names that have at least one pop culture spike
        group_by(name) %>%
        filter(any(type != "Baseline/No Link")) %>%
        ungroup() %>%
        arrange(type)

    # 5. Generate and return the ggplot object
    # Notice we added `text = tooltip_label` to the main aes()
    p <- ggplot(plot_data, aes(x = reorder(name, -N, FUN = max), y = year, text = tooltip_label)) +
        geom_point(aes(size = N, color = type), alpha = 0.8) +
        scale_size_continuous(range = c(1, 12), labels = scales::comma) +
        scale_color_manual(
            values = c(
                "Baseline/No Link"      = "grey85",
                "HBO Influence"         = "#E63946",
                "Billboard Chart Spike" = "#457B9D"
            )
        ) +
        scale_y_reverse(breaks = seq(min(plot_data$year, na.rm = TRUE),
                                     max(plot_data$year, na.rm = TRUE), by = 5)) +
        labs(
            title = "Algorithmically Detected Pop Culture Spikes",
            subtitle = paste0("Highlighting YoY growth >", (growth_threshold * 100),
                              "% occurring within 2 years of a Billboard or HBO milestone"),
            x = "Name",
            y = "Year",
            size = "Total Births (N)",
            color = "Spike Catalyst"
        ) +
        theme_minimal(base_size = 13) +
        theme(
            panel.grid.major.x = element_line(color = "grey92", linetype = "dashed"),
            panel.grid.minor = element_blank(),
            legend.position = "right",
            plot.title = element_text(face = "bold", size = 16),
            axis.text.x = element_text(face = "bold", angle = 90, hjust = 1,size=6)
        )

    return(p)
}

# Generate the plot object
#my_static_plot <- build_pop_culture_plot(Baby_Names, charts, hbo)
#my_static_plot
# Render it interactively, pointing the tooltip specifically to our custom text
#interactive_plot <- ggplotly(my_static_plot, tooltip = "text")

#interactive_plot
