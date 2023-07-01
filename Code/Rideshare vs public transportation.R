#Comparing ride volume of public transit with rideshare, August 2016
rm(list = ls())

library(dplyr)

austin_data <- read.csv("RideAustin_Weather.csv")
capmetro_stops <- read.csv("Austin capmetro stops.csv")
capmetro_rides <- read.csv("CapMetro ridership August 2016 by latlong.csv")

#Shrink dataset to relevant columns
rideshare = subset(austin_data, select = c(completed_on, started_on, distance_travelled, end_location_lat, end_location_long, start_location_lat, start_location_long, make, model, year))

#Filter rideshare data for rides within general range of public transportation
rideshares_in_range <- rideshare %>%
  filter(start_location_lat > 30 & start_location_lat < 30.6
         & start_location_long > -97.8 & start_location_long < -97.5
         & end_location_lat > 30 & end_location_lat < 30.6
         & end_location_long > -97.8 & end_location_long < -97.5)


summary(rideshares_in_range)

#Total number of rideshare trips
totrides = count(rideshares_in_range)
totrides
totpassgrs = totrides*1.4 #Avg number of people per rideshare trip (https://www.proquest.com/openview/e72295e320ad0316f0bfbe8a1102bdd7/1?cbl=36781&pq-origsite=gscholar&parentSessionId=X1bHyMnX3sD0okvHEK2hrOW8xWLrsmS3KLUF61sWfg8%3D)
totpassgrs

#Get total and pct of rideshare trips by lat/long pair
rides_per_latlong <- rideshares_in_range %>% group_by(start_location_lat, start_location_long) %>% tally(name="rides")
rides_per_latlong$passgrs <- rides_per_latlong$rides*1.4
rides_per_latlong$pctrideshare <- rides_per_latlong$rides / as.integer(totrides)


#Total riders on public transportation
totpubtrans <- sum(capmetro_rides$ons)
totpubtrans

#Add pct ridership by lat/long for public transportation
capmetro_rides$pctpubtrans <- capmetro_rides$ons/totpubtrans

#Join rideshare and public transportation ridership by lat/long
merged_data = merge(x = rides_per_latlong, y = capmetro_rides, by.x = c("start_location_lat", "start_location_long"), by.y = c("veh_lat_rnd", "veh_long_rnd"), all = TRUE, replace.na = 0)
rownames(merged_data) = NULL


linreg_passgrs <- lm(passgrs~ons, merged_data)
summary(linreg_passgrs)
#As expected, highly significant relationship between number of passengers on public transportation and doing ridesharing at a particular location (See adj. R2: about 31% of the variance in rideshare volume across the city is just due to location)

linreg_pctrides <- lm(pctrideshare~pctpubtrans, merged_data)
summary(linreg_pctrides)
#And same result when we translate this to percent of rides/passengers (Adj. R2 = 31%).

#Still, ~70% of the variation between ridership distributions is not simply due to location. Can we improve on this model by adding other factors?




