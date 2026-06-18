plot_persistence <- function(nat_names,
                                       genders = c("F", "M"),
                                       lags = 1:3,
                                       top_n = 25) {

    # Full national rank table for one year + gender
    year_rank_table <- function(nat_names, yr, sex) {
        nat_names %>%
            filter(year == yr, gender == sex) %>%
            arrange(desc(count)) %>%
            mutate(rank = row_number()) %>%
            select(name, rank)
    }

    # 1. Build the combinations to iterate over
    years  <- sort(unique(nat_names$year))
    combos <- expand_grid(year = years, gender = genders, lag = lags)

    # 2. Generate the timeseries data frame
    ts_df <- pmap_dfr(combos, function(year, gender, lag) {
        persistence_one_year(nat_names, year, gender, lag, top_n)
    })

    # 3. Add the lag labels for the plot legend
    ts_df <- ts_df %>%
        mutate(lag_label = paste0("+", lag, " yr"))

    # 4. Generate and return the ggplot
    ggplot(ts_df, aes(x = year, y = rho, color = lag_label)) +
        geom_line(linewidth = 0.6, alpha = 0.5) +
        geom_smooth(se = FALSE, span = 0.3, linewidth = 1.1) +
        geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
        facet_wrap(~gender, labeller = labeller(gender = c(F = "Girls", M = "Boys"))) +
        coord_cartesian(ylim = c(-0.2, 1)) +
        labs(
            title = paste0("Persistence of each year's top-", top_n, " baby names into the future"),
            subtitle = paste0("Spearman rank correlation: this year's top-", top_n, " rank vs. their rank 1-3 years later\n(dashed line marks 1990)"),
            x = "Year",
            y = "Spearman's rho",
            color = "Look-ahead"
        ) +
        theme_minimal(base_size = 12) +
        theme(legend.position = "bottom")
}


# Example
plot_persistence(national_names)

