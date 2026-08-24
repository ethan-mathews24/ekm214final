
# read in packages 

library(tidyverse)
library(dplyr)


# Read in Data 

BQ1 <- read_csv("data/knb-lter-luq.20.4923064/QuebradaCuenca1-Bisley.csv")

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
  filter(year(Sample_Date) %in% c(1988:1995))




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
  window_start = seq(ymd("1988-01-05"), ymd("1995-12-26"), 
  by = "9 weeks"),
  k_mgl = NA,
  mg_mgl = NA,
  NO3_ugl = NA,
  K_mgl = NA,
  NH4_ugl = NA
)

moving_average

# Step 4. creating a loop
for (i in 1:nrow(moving_average)) {
# i is our iterator
# 1:nrow(qs_smooothed) is our seqeuence
# i will take on those values, one at a time
  
# we need to find out what rows fall within the start and end date
  
  w1 <- qs_smoothed$window_start[i]
  
  w2 <- qs_smoothed$window_start[i] + 9


# what potassium(k) values are inside that window?
  
  pot <- qs_data$k_mgl[qs_data$sample_date >= w1 & qs_data$sample_date < w2]
  mag <- qs_data$mg_mgl[qs_data$sample_date >= w1 & qs_data$sample_date < w2]

  # now we need to calculate the mean
  qs_smoothed$k_mgl[i] <- mean(pot, na.rm = TRUE)
  qs_smoothed$mg_mgl[i] <- mean(mag, na.rm = TRUE)

}



# graph

qs_long <- qs_smoothed |> 
  pivot_longer(
    cols = c(k_mgl, mg_mgl),
    names_to = "nutrient", 
    values_to = "concentration")

ggplot(data = qs_long, mapping = aes(
  x = window_start,
  y = concentration,
  group = nutrient, 
  color =nutrient)) + 
  
  geom_line() +
  
  theme_bw() + 
  
  labs(title = "Moving Averages",
x = "Window Start",
y = "Concentrations") +

  scale_color_manual(values = c("red", "blue"), 
  labels = c("Potassium", "Magnesium"))
  
