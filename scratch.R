# load in packages

library(tidyverse)
library(dplyr)

#

source("R/moving-average.R")


# Read in Data

BQ1 <- read_csv("data/QuebradaCuenca1-Bisley.csv")

BQ2 <- read_csv("data/QuebradaCuenca2-Bisley.csv")

BQ3 <- read_csv("data/QuebradaCuenca3-Bisley.csv")

PRM <- read_csv("data/RioMameyesPuenteRoto.csv")

problems(BQ1)


# filtered BQ1 dataset

BQ1_filtered <- BQ1 |>
  select(
    "Sample_ID",
    "Code",
    "Sample_Date",
    "NO3-N",
    "K",
    "Mg",
    "Ca",
    "NH4-N"
  ) |>
  filter(year(Sample_Date) %in% c(1988:1994))


# Exploratory Data -------------------------------------------------------

# first I want to see how many NA values there are

# print(sum(is.na(clean_combined_data$`Sample_ID`)))
# print(sum(is.na(clean_combined_data$`NO3-N`)))
# print(sum(is.na(clean_combined_data$`K`)))
# print(sum(is.na(clean_combined_data$`Mg`)))
# print(sum(is.na(clean_combined_data$`Ca`)))
# print(sum(is.na(clean_combined_data$`NH4-N`)))

# glimpse(clean_combined_data)

# Finding the Moving Average over 9 Weeks --------------------------------

moving_average(BQ1_filtered)


# THIS Section is for FINAL FIGURE ---------------------------------------

BQ1 <- read_csv("data/QuebradaCuenca1-Bisley.csv") |>
  select(
    "Sample_ID",
    "Code",
    "Sample_Date",
    "NO3-N",
    "K",
    "Mg",
    "Ca",
    "NH4-N"
  ) |>
  filter(year(Sample_Date) %in% c(1988:1994))


BQ2 <- read_csv("data/QuebradaCuenca2-Bisley.csv") |>
  select(
    "Sample_ID",
    "Code",
    "Sample_Date",
    "NO3-N",
    "K",
    "Mg",
    "Ca",
    "NH4-N"
  ) |>
  filter(year(Sample_Date) %in% c(1988:1994))


BQ3 <- read_csv("data/QuebradaCuenca3-Bisley.csv") |>
  select(
    "Sample_ID",
    "Code",
    "Sample_Date",
    "NO3-N",
    "K",
    "Mg",
    "Ca",
    "NH4-N"
  ) |>
  filter(year(Sample_Date) %in% c(1988:1994))


PRM <- read_csv("data/RioMameyesPuenteRoto.csv") |>
  select(
    "Sample_ID",
    "Code",
    "Sample_Date",
    "NO3-N",
    "K",
    "Mg",
    "Ca",
    "NH4-N"
  ) |>
  filter(year(Sample_Date) %in% c(1988:1994))


BQ1_avg <- moving_average(BQ1)

BQ2_avg <- moving_average(BQ2)

BQ3_avg <- moving_average(BQ3)

PRM_avg <- moving_average(PRM)


combined_avg_data <- bind_rows(BQ1_avg, BQ2_avg, BQ3_avg, PRM_avg)


fig3 <- combined_avg_data |>
  pivot_longer(
    cols = c(k_mgl, ca_mgl, mg_mgl, no3_ugl, nh4_ugl),
    names_to = "nutrient",
    values_to = "concentration",
  ) |>
  mutate(
    nutrient = factor(
      nutrient, # this is changing the order in which ions are when they are graphed
      levels = c("k_mgl", "no3_ugl", "mg_mgl", "ca_mgl", "nh4_ugl"),
    )
  ) |>
  mutate(
    Site = factor(
      # this is changing the site name to match figure 3.
      Site,
      levels = c("MPR", "Q1", "Q2", "Q3"),
      labels = c("PRM", "BQ1", "BQ2", "BQ3")
    )
  )


hurricane_date <- as.Date("1989-09-18")


ggplot(
  data = fig3,
  mapping = aes(
    x = window_start,
    y = concentration,
    linetype = Site
  )
) +

  geom_line() +

  geom_vline(
    xintercept = hurricane_date,
    linetype = "dashed",
    linewidth = 0.4
  ) +

  theme_bw() +

  labs(
    title = "Hurricane effects on stream chemistry",
    x = "Years",
    y = NULL,
    linetype = NULL
  ) +

  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +

  theme(
    strip.placement = "outside",
    strip.background = element_blank(),
    strip.text.y.left = element_text(angle = 90),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  ) +

  facet_grid(vars(nutrient), scales = "free_y", switch = "y") +

  theme(strip.placement = "outside") +

  scale_x_date(sec.axis = dup_axis())
