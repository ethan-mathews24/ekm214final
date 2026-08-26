

library(tidyverse)
library(dplyr)

source("R/moving-average.R")



# Read in Data 

BQ1 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca1-Bisley.csv")

BQ2 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca2-Bisley.csv")

BQ3 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca3-Bisley.csv")
  
PRM <- read_csv("data/knb-lter-luq.20.4923064/RioMameyesPuenteRoto.csv")

problems(BQ1)

# combiend the above read data sets into one master data frame
combined_data <- bind_rows(BQ1, BQ2, BQ3, PRM)




# select the important rows 
clean_combined_data <- combined_data |> 
  select("Sample_ID", "Code", "Sample_Date", "NO3-N", "K", "Mg", "Ca", "NH4-N") |> 
  filter(year(Sample_Date) %in% c(1988:1994))

# filtered BQ1 dataset

BQ1_filtered <- BQ1 |> 
  select("Sample_ID", "Code", "Sample_Date", "NO3-N", "K", "Mg", "Ca", "NH4-N") |> 
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



# Sketchy Graph ----------------------------------------------------------


nut_long <- clean_combined_data |> 
  pivot_longer(
    cols = c(K, Ca, Mg, `NO3-N`, `NH4-N`),
    names_to = "nutrient", 
    values_to = "concentration")

ggplot(data = nut_long, 
  mapping = aes(
  x = Sample_Date,
  y = concentration,
  group = nutrient, 
  color = nutrient)) + 
  
  geom_line() +
  
  theme_bw() + 
  
  labs(title = "Trash Plot", 
  x = "Date", 
  y = "Concentration") +
  
  scale_color_manual(
    name = "Nutrient",
    values = c(
      "Ca"    = "red",
      "K"     = "goldenrod",
      "Mg"    = "forestgreen",
      "NH4-N" = "dodgerblue",
      "NO3-N" = "deeppink"
    ),
    labels = c(
      "Ca"    = "Calcium",
      "K"     = "Potassium",
      "Mg"    = "Magnesium",
      "NH4-N" = "Ammonium",
      "NO3-N" = "Nitrate"
    ))



# Finding the Moving Average over 9 Weeks --------------------------------



moving_average(BQ1_filtered)




# Plot for BQ1 -----------------------------------------------------------

mov_long <- moving_average |> 
  pivot_longer(
    cols = c(k_mgl, ca_mgl, mg_mgl, NO3_ugl, NH4_ugl),
    names_to = "nutrient", 
    values_to = "concentration")

ggplot(data = mov_long, 
  mapping = aes(
  x = window_start,
  y = concentration,
  group = nutrient, 
  color = nutrient)) + 
  
  geom_line() +
  
  theme_bw() + 
  
  labs(title = "BQ1", 
  x = "Date", 
  y = "Concentration") +
  
  scale_color_manual(
    name = "Nutrient",
    values = c(
      "ca_mgl"    = "red",
      "k_mgl"     = "goldenrod",
      "mg_mgl"    = "forestgreen",
      "NH4_ugl" = "dodgerblue",
      "NO3_ugl" = "deeppink"
    ),
    labels = c(
      "ca_mgl"    = "Calcium",
      "k_mgl"     = "Potassium",
      "mg_mgl"    = "Magnesium",
      "NH4_ugl" = "Ammonium",
      "NO3_ugl" = "Nitrate"
    )) +
  
  facet_wrap(~nutrient, scales = "free")

