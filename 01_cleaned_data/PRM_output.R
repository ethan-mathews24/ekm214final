library(tidyverse)
library(dplyr)

source("R/moving-average.R")

PRM <- read_csv("data/RioMameyesPuenteRoto.csv")

PRM_filtered <- PRM |>
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


PRM_avg <- moving_average(PRM_filtered)


mov_long <- PRM_avg |>
  pivot_longer(
    cols = c(k_mgl, ca_mgl, mg_mgl, no3_ugl, nh4_ugl),
    names_to = "nutrient",
    values_to = "concentration"
  )

ggplot(
  data = mov_long,
  mapping = aes(
    x = window_start,
    y = concentration,
    group = nutrient,
    color = nutrient
  )
) +

  geom_line() +

  theme_bw() +

  labs(title = "PRM", x = "Date", y = "Concentration") +

  scale_color_manual(
    name = "Nutrient",
    values = c(
      "ca_mgl" = "red",
      "k_mgl" = "goldenrod",
      "mg_mgl" = "forestgreen",
      "nh4_ugl" = "dodgerblue",
      "no3_ugl" = "deeppink"
    ),
    labels = c(
      "ca_mgl" = "Calcium",
      "k_mgl" = "Potassium",
      "mg_mgl" = "Magnesium",
      "nh4_ugl" = "Ammonium",
      "no3_ugl" = "Nitrate"
    )
  ) +

  facet_wrap(~nutrient, scales = "free")


