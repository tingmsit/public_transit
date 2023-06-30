rm(list = ls())
library(dplyr)
library(ggplot2)
library(gridExtra)
library(plotly)
library(tidyverse)
library(lubridate)
library(chron)

rideshare <- read.csv("../Data/RideAustin_Weather.csv")

summary(rideshare)

rideshare_filter <- rideshare %>%
  filter(distance_travelled < 15000)
rideshare_filter$dist_km <- rideshare_filter$distance_travelled/1000
# Obtain day of week
rideshare_filter$dow <- wday(ymd(rideshare_filter$Date), label = TRUE)
# Obtain month
rideshare_filter$mo <- month(ymd(rideshare_filter$Date), label = TRUE)

# Convert start and end time text into datetime object

rideshare_filter$start_ts <- as.POSIXct(rideshare_filter$started_on,
  tz = Sys.timezone())
rideshare_filter$end_ts <- as.POSIXct(rideshare_filter$completed_on,
  tz = Sys.timezone())

# Obtain hour of the day
rideshare_filter$hour <- rideshare_filter$start_ts %>%
  hour()

# Calculate time traveled
rideshare_filter$ts_travel <- difftime(rideshare_filter$end_ts,
  rideshare_filter$start_ts, units = "mins")

# Limit travel time to be less than 120 minutes
rideshare_ts <- rideshare_filter %>%
  filter(ts_travel > 0 & ts_travel < 120)




dist_travel <- ggplot(rideshare_filter, aes(dist_km)) + geom_histogram(binwidth = 1) +
  labs(title = "Distance Traveled Distribution for ride share trips",
    x = "Distance Traveled (km)", y = "# of Trips")

dist_travel_cum <- ggplot(rideshare_filter, aes(dist_km)) + stat_ecdf(geom = 'step') +
  labs(title = "Cumlative % for ride share trips",
       x = "Distance Traveled (km)", y = "% to total")

grid.arrange(dist_travel, dist_travel_cum, ncol=2)


dist_ts <- ggplot(rideshare_ts, aes(ts_travel)) + stat_ecdf(geom = "step") +
  labs(title = "Time Traveled by ride share trips",
       x = "Time (mins)", y = "% to total")

day_count <- ggplot(rideshare_filter, aes(x = dow)) + geom_bar() +
  labs(title = "Ride share trips distribution by Day",
       x = "Day of Week", y = "# Trip")


weather_fog <- day_count + facet_grid(vars(Fog)) +
  labs(title = "Day distribution conditioned on Fog",
       x = "Day", y = "# Trip")

weather_thunder <- day_count + facet_grid(vars(Thunder)) +
  labs(title = "Day distribution conditioned on Thunder",
       x = "Day", y = "# Trip")

# month_count <- ggplot(rideshare_filter, aes(x = mo)) +
# geom_bar() month_count


hour_count <- ggplot(rideshare_filter, aes(x = hour)) + geom_bar() +
  labs(title = "Time of Day",
       x = "Hour", y = "# of Trip")


grid.arrange(hour_count, dist_ts, day_count, ncol=2, nrow=2)

grid.arrange(weather_fog, weather_thunder, ncol=1, nrow=2)

# rideshare_filter$start_loc <- paste('(',
# as.character(rideshare_filter$start_location_long) ,',',
# as.character(rideshare_filter$start_location_lat),')')
# rideshare_filter$end_loc <- paste('(',
# as.character(rideshare_filter$end_location_long) ,',',
# as.character(rideshare_filter$end_location_lat),')')
# rideshare_filter$from_to <- paste('(',
# as.character(rideshare_filter$start_loc) ,',',
# as.character(rideshare_filter$end_loc),')')

