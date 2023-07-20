library(dplyr)
library(tidyr)
library(tidyverse)

rides <- read.csv("RideAustin_Weather.csv")
vehicles <- read.csv("vehicles.csv")
#View(vehicles)
#View(rides) #distance traveled is in meters

vinfo <- vehicles[, c('year', 'make', 'model', 'barrels08', 'barrelsA08', 'city08', 'cityA08', 'co2', 'co2A')]
#CO2 grams per mile, barrels in barrels per mile, city miles per gallon

vinfo2 <- vinfo %>% group_by(year, make, model) %>% sample_n(1)
#Due to multiple lines in the vehicles data set take a random sample of one type of year, make, model and assign it to the ride

df <- left_join(rides, vinfo2, by=c('year', 'make', 'model'))
#Vehicle data has multiple types of cars with same year, make, and model

numrows <- nrow(df)
numNA <- sum(is.na(df$co2))

perNa <- numNA/numrows * 100
#43% of data had NA values

#Due to us having such a large sample size comfortable estimating volume based solely on rows with car data
df2 <- df %>% drop_na(co2)

df2$calcco2 = ifelse(df2$co2 > 0 & df2$co2A > 0 , mean(c(df2$co2,df2$co2A)),
                      ifelse(df2$co2 > df2$co2A, df2$co2, df2$co2A))

CO2emmited = df2$distance_travelled*0.000621371 * df2$calcco2 #convert meters to miles
TotalCo2samp <- sum(subset(CO2emmited, CO2emmited >0))*0.001 #Ignore hybrid car rides convert to kilograms

totCO2 = TotalCo2samp / length(df2$distance_travelled)*length(rides$distance_travelled) #Volume adjust back to CO2 Estimate


