# year_rank_table
# Full national rank table for one year + gender
year_rank_table <- function(nat_names, yr, sex) {
  nat_names %>%
    filter(year == yr, gender == sex) %>%
    arrange(desc(count)) %>%
    mutate(rank = row_number()) %>%
    select(name, rank)
}
