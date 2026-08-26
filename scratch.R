
# read in packages 
# Reading in Packages and Data --------------------------------------------



library(tidyverse)
library(dplyr)


# Read in Data 

bq1 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca1-Bisley.csv")

BQ2 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca2-Bisley.csv")

BQ3 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca3-Bisley.csv")
  
PRM <- read_csv("data/knb-lter-luq.20.4923064/RioMameyesPuenteRoto.csv")


# combiend the above read data sets into one master data frame
combined_data <- bind_rows(BQ1, BQ2, BQ3, PRM)
  
  

# GOAL is to create one graph for Bisley1. 
# Time is going to be on the x-axis and then hopefully facet wrap it by the 
# the Ion (NO3-N, K, Mg, Ca, NH4-N)



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



# making a tibble for the moving average

moving_average <- tibble(
  window_start = seq(ymd("1988-01-05"), ymd("1994-12-26"), 
  by = "9 weeks"),
  k_mgl = NA,
  mg_mgl = NA,
  NO3_ugl = NA,
  ca_mgl = NA,
  NH4_ugl = NA
)

moving_average

# w2 <- moving_average$window_start[1]

# Step 4. creating a loop
for (i in 1:nrow(moving_average)) {
# i is our iterator
# 1:nrow(qs_smooothed) is our seqeuence
# i will take on those values, one at a time
  
# we need to find out what rows fall within the start and end date

  w1 <- moving_average$window_start[i]
  
  w2 <- w1 + weeks(9)



# what ion values are inside that window?
  
  pot <- BQ1_filtered$K[BQ1_filtered$Sample_Date >= w1 & BQ1_filtered$Sample_Date < w2]
  mag <- BQ1_filtered$Mg[BQ1_filtered$Sample_Date >= w1 & BQ1_filtered$Sample_Date < w2]
  nit <- BQ1_filtered$`NO3-N`[BQ1_filtered$Sample_Date >= w1 & BQ1_filtered$Sample_Date < w2]
  amon <- BQ1_filtered$`NH4-N`[BQ1_filtered$Sample_Date >= w1 & BQ1_filtered$Sample_Date < w2]
  calc <- BQ1_filtered$Ca[BQ1_filtered$Sample_Date >= w1 & BQ1_filtered$Sample_Date < w2]


  # now we need to calculate the mean
  moving_average$k_mgl[i] <- mean(pot, na.rm = TRUE)
  moving_average$mg_mgl[i] <- mean(mag, na.rm = TRUE)
  moving_average$NO3_ugl[i] <- mean(nit, na.rm = TRUE)
  moving_average$NH4_ugl[i] <- mean(amon, na.rm = TRUE)
  moving_average$ca_mgl[i] <- mean(calc, na.rm = TRUE)
}


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

