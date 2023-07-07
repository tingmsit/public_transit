#Comparing ride volume of public transit with rideshare, August 2016
rm(list = ls())

library(dplyr)

austin_data <- read.csv("RideAustin_Weather with dow and hour.csv")
capmetro_stops <- read.csv("Austin capmetro stops.csv")
capmetro_rides <- read.csv("CapMetro ridership all by latlong.csv")
capmetro_dow_hour <- read.csv("CapMetro ridership all by latlong dow hour.csv")

#Shrink dataset to relevant columns
rideshare = subset(austin_data, select = c(completed_on, started_on, distance_travelled, end_location_lat, end_location_long, start_location_lat, start_location_long, started_dow, started_hour, make, model, year))

#Filter rideshare data for rides within general range of public transportation
rideshares_in_range <- rideshare %>%
  filter(start_location_lat > 30 & start_location_lat < 30.6
         & start_location_long > -97.8 & start_location_long < -97.5
         & end_location_lat > 30 & end_location_lat < 30.6
         & end_location_long > -97.8 & end_location_long < -97.5)

#Filter CapMetro data for rides within general range of public transportation (data sometimes include other cities)
capmetro_in_range <- capmetro_rides %>%
  filter(veh_lat_rnd > 30 & veh_lat_rnd < 30.6
         & veh_long_rnd > -97.8 & veh_long_rnd < -97.5)

summary(rideshares_in_range)
summary(capmetro_in_range)

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
totpubtrans <- sum(capmetro_in_range$rides_on)
totpubtrans

#Add pct ridership by lat/long for public transportation
capmetro_in_range$pctpubtrans <- capmetro_in_range$rides_on/totpubtrans

#Join rideshare and public transportation ridership by lat/long
merged_data = merge(x = rides_per_latlong, y = capmetro_in_range, by.x = c("start_location_lat", "start_location_long"), by.y = c("veh_lat_rnd", "veh_long_rnd"), all = TRUE, replace.na = 0)
rownames(merged_data) = NULL


linreg_passgrs <- lm(passgrs~rides_on, merged_data)
summary(linreg_passgrs)
#As expected, highly significant relationship between number of passengers on public transportation and doing ridesharing at a particular location (See adj. R2: about 35% of the variance in rideshare volume across the city is just due to location)

linreg_pctrides <- lm(pctrideshare~pctpubtrans, merged_data)
summary(linreg_pctrides)
#And same result when we translate this to percent of rides/passengers (Adj. R2 = 35%).

#Still, ~65% of the variation between ridership distributions is not simply due to location. Can we improve on this model by adding other factors?


#Adding month and day of week to regression analysis:
#Filter for correct range
capmetro_in_range_dow_hour <- capmetro_dow_hour %>%
  filter(veh_lat_rnd > 30 & veh_lat_rnd < 30.6
         & veh_long_rnd > -97.8 & veh_long_rnd < -97.5)

#Get total and pct of rideshare trips by lat/long pair, day of week, and hour
rides_per_latlong_dow_hour <- rideshares_in_range %>% group_by(start_location_lat, start_location_long, started_dow, started_hour) %>% tally(name="rides")
rides_per_latlong_dow_hour$passgrs <- rides_per_latlong_dow_hour$rides*1.4
rides_per_latlong_dow_hour$pctrideshare <- rides_per_latlong_dow_hour$rides / as.integer(totrides)

#Total riders on public transportation
totpubtrans <- sum(capmetro_in_range_dow_hour$rides_on)
totpubtrans

#Add pct ridership by lat/long for public transportation
capmetro_in_range_dow_hour$pctpubtrans <- capmetro_in_range_dow_hour$rides_on/totpubtrans

#Join rideshare and public transportation ridership by lat/long, month, and day of week
merged_data_dow_hour = merge(x = rides_per_latlong_dow_hour, y = capmetro_in_range_dow_hour, by.x = c("start_location_lat", "start_location_long", "started_dow", "started_hour"), by.y = c("veh_lat_rnd", "veh_long_rnd", "start_time_dayofwk", "start_time_hour"), all = TRUE, replace.na = 0)
rownames(merged_data_dow_hour) = NULL

#Create weekday and workhours variables
merged_data_dow_hour$weekday <- ifelse(merged_data_dow_hour$started_dow > 1 & merged_data_dow_hour$started_dow < 7, 1, 0)
merged_data_dow_hour$workhours <- ifelse(merged_data_dow_hour$started_hour > 6 & merged_data_dow_hour$started_hour < 19, 1, 0)

#Convert variables to categorical
merged_data_dow_hour$started_dow <- as.factor(merged_data_dow_hour$started_dow)
merged_data_dow_hour$weekday <- as.factor(merged_data_dow_hour$weekday)
merged_data_dow_hour$started_hour <- as.factor(merged_data_dow_hour$started_hour)
merged_data_dow_hour$workhours <- as.factor(merged_data_dow_hour$workhours)

#Regression with passengers, day of week, and hour of day
linreg_dow_hour <- lm(passgrs~rides_on + weekday + workhours, merged_data_dow_hour)
summary(linreg_dow_hour)
#All three variables are significant, and there is little correlation between ridesharing and public transportation. This suggests that people are more likely to use ridesharing on weekends and on off hours (even though CapMetro offers late night services in some locations)


