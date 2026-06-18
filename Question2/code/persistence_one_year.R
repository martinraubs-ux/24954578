# -----------------------------------------------------------------------
# 3. RANK-PERSISTENCE OF POPULAR NAMES (SPEARMAN), OVER TIME
# -----------------------------------------------------------------------
# For year Y: take the top-N names, note their rank in Y (1..N), then look
# up where each of those SAME names ranks `lag` years later, using the full
# national ranking for Y+lag (not just its own top-N). A name that vanishes
# from the SSA file entirely by Y+lag is given a rank one place worse than
# the lowest-ranked name that year, i.e. treated as having fallen further
# than anyone still on the list, rather than being dropped from the
# calculation. Spearman's rho on (rank_now, rank_future) then tells you how
# well the *ordering* of today's favourites survives into the future.

persistence_one_year <- function(names, yr, sex, lag, top_n = 25) {

    nat_names <- names %>%
        group_by(name, year, gender) %>%
        summarise(count = sum(count), .groups = "drop")

    # Ranking names function
    top_n_names <- function(nat_names, yr, sex, n = 25) {

        # Full national rank table for one year + gender
        year_rank_table <- function(nat_names, yr, sex) {
            nat_names %>%
                filter(year == yr, gender == sex) %>%
                arrange(desc(count)) %>%
                mutate(rank = row_number()) %>%
                select(name, rank)
        }
        year_rank_table(nat_names, yr, sex) %>% slice_head(n = n)
    }

    top_now     <- top_n_names(nat_names, yr, sex, top_n)

    rank_future <- year_rank_table(nat_names, yr + lag, sex)
    if (nrow(rank_future) == 0 || nrow(top_now) == 0) return(NULL)

    worst_rank <- max(rank_future$rank) + 1

    merged <- top_now %>%
        rename(rank_now = rank) %>%
        left_join(rank_future %>% rename(rank_future = rank), by = "name") %>%
        mutate(rank_future = ifelse(is.na(rank_future), worst_rank, rank_future))

    rho <- suppressWarnings(cor(merged$rank_now, merged$rank_future, method = "spearman"))
    tibble(year = yr, gender = sex, lag = lag, rho = rho)
}

build_and_plot_persistence <- function(nat_names,
                                       genders = c("F", "M"),
                                       lags = 1:3,
                                       top_n = 25) {

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











build_persistence_timeseries <- function(nat_names,
                                         genders = c("F", "M"),
                                         lags = 1:3,
                                         top_n = 25) {
    years  <- sort(unique(nat_names$year))
    combos <- expand_grid(year = years, gender = genders, lag = lags)

    pmap_dfr(combos, function(year, gender, lag) {
        persistence_one_year(nat_names, year, gender, lag, top_n)
    })
}

plot_persistence_timeseries <- function(ts_df) {
    ts_df <- ts_df %>% mutate(lag_label = paste0("+", lag, " yr"))

    ggplot(ts_df, aes(x = year, y = rho, color = lag_label)) +
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
}

# Direct numeric check of "since the 1990s, persistence has been slower"
test_pre_post_1990 <- function(ts_df) {
    ts_df %>%
        mutate(era = ifelse(year < 1990, "pre_1990", "from_1990")) %>%
        group_by(gender, lag, era) %>%
        summarise(mean_rho = mean(rho, na.rm = TRUE), .groups = "drop") %>%
        pivot_wider(names_from = era, values_from = mean_rho) %>%
        mutate(drop_in_persistence = pre_1990 - from_1990)
    # positive drop_in_persistence => persistence WAS higher pre-1990,
    # i.e. it supports the "names persist less since the 90s" claim
}
