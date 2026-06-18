# dens
library(dplyr)
library(ggplot2)


# 2. Build the wrapper function
plot_fame_density <- function(baby_names_df, chart_df, hbo_df, names_list) {

    # Step A: Find the breakout year in Billboard data
    chart_breakouts <- chart_df %>%
        filter(artist %in% names_list) %>%
        group_by(name = artist) %>%
        summarise(event_year = min(year, na.rm = TRUE), .groups = "drop") %>%
        mutate(source = "Billboard")

    # Step B: Find the breakout year in HBO data
    hbo_breakouts <- hbo_df %>%
        filter(character %in% names_list) %>%
        group_by(name = character) %>%
        summarise(event_year = min(release_year, na.rm = TRUE), .groups = "drop") %>%
        mutate(source = "HBO")

    # Step C: Combine into a single lookup table of 'Fame Years'
    # If someone appears in both, we take their earliest appearance
    fame_years <- bind_rows(chart_breakouts, hbo_breakouts) %>%
        group_by(name) %>%
        slice_min(event_year, n = 1) %>%
        ungroup()

    # Step D: Aggregate baby names and join the fame year
    plot_data <- baby_names_df %>%
        filter(name %in% names_list) %>%
        group_by(year, name) %>%
        summarise(N = sum(count, na.rm = TRUE), .groups = "drop") %>%
        left_join(fame_years, by = "name")

    # Step E: Generate the Faceted Density Plot
    p <- ggplot(plot_data, aes(x = year)) +
        # Use weight = N to build density off birth counts, not rows
        geom_density(aes(weight = N), fill = "#457B9D", alpha = 0.6, color = "#1D3557") +

        # Add the vertical line for the year they became famous
        geom_vline(aes(xintercept = event_year),
                   color = "#E63946", linetype = "dashed", linewidth = 1) +

        # Facet by name, allowing the y-axis to scale independently for each person
        facet_wrap(~ name, scales = "free_y") +

        labs(
            title = "Distribution of Baby Names Over Time",
            subtitle = "Red dashed line indicates the year the individual/character broke into pop culture",
            x = "Year",
            y = "Density"
        ) +
        theme_minimal(base_size = 13) +
        theme(
            strip.text = element_text(face = "bold", size = 12),
            panel.grid.minor = element_blank(),
            axis.text.y = element_blank(), # Hide Y-axis text since density decimals aren't intuitive
            axis.ticks.y = element_blank()
        )

    return(p)
}

#famous_names <- c("Miley", "Billie", "Drake", "Rihanna", "Mariah", "Arya", "Zendaya", "Khaleesi")

# Generate the faceted plot
#fame_plot <- plot_fame_density(Baby_Names, charts, hbo, famous_names)

# View the result
#fame_plot