README
================
Martin Raubenheimer
2026-06-18

# 24954578

# Question 1

\# Categorizing coffees by matching the words SU students used to
describe coffee that they like to reviewer descriptions.

Cleans and translates the map data. I used Claude to map all the origin
regions to country names that I can use that map package.

    ## ⚠️  Unmapped values (extend region_to_country to fix):
    ##  - UNMAPPED: Kahale
    ##  - UNMAPPED: La Providencia
    ##  - UNMAPPED: Alaka District
    ##  - UNMAPPED: Campos Alto District
    ##  - UNMAPPED: Kula
    ##  - UNMAPPED: Northern Province
    ##  - UNMAPPED: Alto Jaramillo
    ##  - UNMAPPED: Yeri Growing Region
    ##  - UNMAPPED: Kibugu Village
    ##  - UNMAPPED: Cerro El Tigre
    ##  - UNMAPPED: Dolores
    ##  - UNMAPPED: El Socorro
    ##  - UNMAPPED: Ka’U Growing Region
    ##  - UNMAPPED: Ka’U
    ##  - UNMAPPED: Bella Vista
    ##  - UNMAPPED: Buenos Aires
    ##  - UNMAPPED: Central Province
    ##  - UNMAPPED: Los Planes
    ##  - UNMAPPED: Chito
    ##  - UNMAPPED: Chinas
    ##  - UNMAPPED: El Soccoro
    ##  - UNMAPPED: Los Angeles
    ##  - UNMAPPED: Finca Santa Teresa
    ##  - UNMAPPED: Sana’A Growing Region
    ##  - UNMAPPED: Sa’Dah Governorate
    ##  - UNMAPPED: Sana’A Governorate
    ##  - UNMAPPED: Cañas Verdes
    ##  - UNMAPPED: Jurutungo
    ##  - UNMAPPED: La Piedra De Rivas
    ##  - UNMAPPED: Ka‘Ū
    ##  - UNMAPPED: Ka‘Ū Growing Region
    ##  - UNMAPPED: Mirado Village
    ##  - UNMAPPED: Eastern Region
    ##  - UNMAPPED: Santa Maria
    ##  - UNMAPPED: Big Island Of Hawai’I
    ##  - UNMAPPED: Hawai’I
    ##  - UNMAPPED: “Big Island” Of Hawaii
    ##  - UNMAPPED: The Democratic Republic Of The Congo
    ##  - UNMAPPED: "Big Island" Of Hawai’I
    ##  - UNMAPPED: “Big Island” Of Hawai’I
    ##  - UNMAPPED: Big Island Of Hawai‘I
    ## 
    ## Saved → regions_with_countries.csv
    ## Columns added: country_1, country_2

Since most rating was the same I made fill average, rating per dollar
![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

I want to show how different coffee’s rating changed based roast and
price categories. - So filtered for the most famous roasts and
facet_wrapped on it. - Cost is important , so cost is on the x axis.
Cost is grouped in categories
![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

Now that we know that that there is a lot of highly rated coffees that
are very cheap, we need to find the sweet spot of quality and
affordability. - Just a normal scatter plot with rating on the x-axis
filtered for good quality ratings. - 5 cheapest options displayed per
rating, with cost on x-axis
![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

## Recommendation tables

I added these tables to provide the entrpreneur of a finite list of
options to choose from.

    ## [1] "figures/5cheap95.png"

    ## [1] "figures/5cheap96.png"

![](figures/5cheap95.png)<!-- -->![](figures/5cheap96.png)<!-- -->

# Question 2

## Introduction

## Persistence analysis

- Combine any duplicate entries and ensure all names and genders are
  capitalized identically.
- Group the data by year and gender, sorting by count to assign a rank
  from 1 to $N$.
- Pull out only the Top 25 names for each year to serve as the baseline
  trend group.
- Look ahead 1, 2, or 3 years. Find where those original names sit in
  the future rankings. Assign a penalty rank to names that disappeared
  completely.
- Use Spearman correlation to assign a metric score ($\rho$) to each
  year’s endurance. Group them before and after 1990 to spot the
  historical shift. ![](Question2/figures/persistence_plot.png)<!-- -->

## Popularity surges

-I took the Billboard and HBO datasets and extracted exactly one
critical year for each artist or character. For Billboard, we grouped
the data by artist and extracted the earliest year they hit their
absolute highest chart rank. This gave us a clean lookup table of “Pop
Culture Catalysts” and the year they occurred.

- I then looked at the baby names. Instead of just looking at raw
  numbers, the code used the lag() function to calculate the
  Year-over-Year (YoY) percentage growth for every single name.

- If a name grew by 5% or 10%, the algorithm ignored it.

- If a name grew by \>100% in a single year (and had at least 100 births
  to filter out statistical noise from rare names), the algorithm
  flagged that specific year as a “Spike.”

- Finally, the code joined the baby name data with the Event Ledger. It
  asked a specific question: Did this detected baby-name spike happen in
  the exact same year, or up to two years after, the artist/character
  peaked in the ledger?

If yes, the code assigned it a Red or Blue color. If no, it remained
Grey.

-I took the Billboard and HBO datasets and extracted exactly one
critical year for each artist or character. For Billboard, we grouped
the data by artist and extracted the earliest year they hit their
absolute highest chart rank. This gave us a clean lookup table of “Pop
Culture Catalysts” and the year they occurred.

- I then looked at the baby names. Instead of just looking at raw
  numbers, the code used the lag() function to calculate the
  Year-over-Year (YoY) percentage growth for every single name.

  - If a name grew by 5% or 10%, the algorithm ignored it.
  - If a name grew by \>100% in a single year (and had at least 100
    births to filter out statistical noise from rare names), the
    algorithm flagged that specific year as a “Spike.”

- Finally, the code joined the baby name data with the Event Ledger. It
  asked a specific question: Did this detected baby-name spike happen in
  the exact same year, or up to two years after, the artist/character
  peaked in the ledger?

If yes, the code assigned it a Red or Blue color. If no, it remained
Grey.

## Density

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

## Genres

![](README_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

# Question 3
