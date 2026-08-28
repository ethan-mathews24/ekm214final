library(tidyverse)
library(dplyr)

source("R/moving-average.R")


# Keep only the columns we need and limit each site to the 1988-1994 study
# period so all four datasets match up before combining

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


# Using the function that was created in R/ folder to find the smoothed 9-week moving averages 
# in nutrient concentrations so seasonal/annual trends are easier to see, matching the method 
# described in the study.


BQ1_avg <- moving_average(BQ1)

BQ2_avg <- moving_average(BQ2)

BQ3_avg <- moving_average(BQ3)

PRM_avg <- moving_average(PRM)


# Combine all four sites into one table so they can be compared side by side
combined_avg_data <- bind_rows(BQ1_avg, BQ2_avg, BQ3_avg, PRM_avg)


# Reshape the data and rename/reorder the nutrients and sites to match how
# they were presented in Figure 3
fig3 <- combined_avg_data |>
  pivot_longer(
    cols = c(k_mgl, ca_mgl, mg_mgl, no3_ugl, nh4_ugl),
    names_to = "nutrient",
    values_to = "concentration",
  ) |>
  mutate(
    nutrient = factor(
      nutrient, # Order ions to match the left-to-right sequence used in Figure 3
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

# Save the cleaned data so it can be used to make figures in other scripts
write_csv(fig3, "output/clean_data.csv")
