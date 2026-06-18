run_persistence_analysis <- function(babynames,
                                     lags = 1:3,
                                     top_n = 25) {

    nat_names <- babynames %>%
        rename_with(tolower) %>%
        mutate(name = str_to_title(name), gender = toupper(gender)) %>%
        group_by(name, year, gender) %>%
        summarise(count = sum(count), .groups = "drop")

    years   <- sort(unique(nat_names$year))
    genders <- c("F", "M")
    combos  <- expand_grid(year = years, gender = genders, lag = lags)

    ts_df <- pmap_dfr(combos, function(year, gender, lag) {
        yr  <- year
        sex <- gender
        lg  <- lag

        top_now <- nat_names %>%
            filter(year == yr, gender == sex) %>%
            arrange(desc(count)) %>%
            mutate(rank = row_number()) %>%
            slice_head(n = top_n)

        rank_future <- nat_names %>%
            filter(year == yr + lg, gender == sex) %>%
            arrange(desc(count)) %>%
            mutate(rank = row_number())

        if (nrow(rank_future) == 0 || nrow(top_now) == 0) return(NULL)

        worst_rank <- max(rank_future$rank) + 1

        merged <- top_now %>%
            select(name, rank_now = rank) %>%
            left_join(rank_future %>% select(name, rank_future = rank), by = "name") %>%
            mutate(rank_future = ifelse(is.na(rank_future), worst_rank, rank_future))

        rho <- suppressWarnings(cor(merged$rank_now, merged$rank_future, method = "spearman"))
        tibble(year = yr, gender = sex, lag = lg, rho = rho)
    })

    plt <- ts_df %>%
        mutate(lag_label = paste0("+", lag, " yr")) %>%
        ggplot(aes(x = year, y = rho, color = lag_label)) +
        geom_line(linewidth = 0.6, alpha = 0.5) +
        geom_smooth(se = FALSE, span = 0.3, linewidth = 1.1) +
        geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
        facet_wrap(~gender, labeller = labeller(gender = c(F = "Girls", M = "Boys"))) +
        coord_cartesian(ylim = c(-0.2, 1)) +
        labs(
            title = "Persistence of each year's top-25 baby names into the future",
            subtitle = "Spearman rank correlation: this year's top-25 rank vs. their rank 1-3 years later\n(dashed line marks 1990)",
            x = "Year", y = "Spearman's rho", color = "Look-ahead"
        ) +
        theme_minimal(base_size = 12) +
        theme(legend.position = "bottom")

    era_comparison <- ts_df %>%
        mutate(era = ifelse(year < 1990, "pre_1990", "from_1990")) %>%
        group_by(gender, lag, era) %>%
        summarise(mean_rho = mean(rho, na.rm = TRUE), .groups = "drop") %>%
        pivot_wider(names_from = era, values_from = mean_rho) %>%
        mutate(drop_in_persistence = pre_1990 - from_1990)

    list(timeseries = ts_df, plot = plt, era_comparison = era_comparison)
}

# run_persistence_analysis(Baby_Names)
