library(dplyr)
library(tidyr)
library(tidyverse)

#function to select one fuel or the other
true_var <- function(x, y) {
  if (x > 0 & y > 0){
    ans <- mean(c(x, y))
  
  }else if (x > y){
    ans <- x
  
  }else{
    ans <- y
  }
return(ans)
}


rides <- read.csv("RideAustin_Weather.csv")
vehicles <- read.csv("vehicles.csv")
View(vehicles)
View(rides) #distance traveled is in meters


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



