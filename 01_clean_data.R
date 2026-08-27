

library(tidyverse)
library(dplyr)

source("R/moving-average.R")


# Read in Data

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
  mutate(nutrient = factor(nutrient,  # this is changing the order in which ions are when they are graphed
    levels = c("k_mgl", "no3_ugl", "mg_mgl", "ca_mgl", "nh4_ugl"),
)) |> 
  mutate(Site = factor( # this is changing the site name to match figure 3.
  Site,
  levels = c("MPR", "Q1", "Q2", "Q3"),        
  labels = c("PRM", "BQ1", "BQ2", "BQ3")      
))


write_csv(fig3, "output/clean_data.csv")

