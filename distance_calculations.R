
library(tidyverse)
library(lubridate)

rideshare <- read.csv('ride_austin_data.csv') 
bus_stops <- read.csv('austin_stops.csv')

# Make Date column in date format
rideshare$Date <- ymd(rideshare$Date)
# Make started_on column in datetime format
rideshare$started_on <- ymd_hms(rideshare$started_on)
# Column for hour of day
rideshare$hour <- hour(rideshare$started_on)
# Day of the week to group by
rideshare$day <- weekdays(rideshare$started_on)
# Month of the year
rideshare$month <- month(rideshare$started_on)
# Filter distances
rideshare <- rideshare %>%
  filter(distance_travelled < 20000)

# Find the total number of trips for each route starting and ending (x, y)
trips_sum <- rideshare %>%
  group_by(end_location_lat, end_location_long,
           start_location_lat, start_location_long) %>%
  summarise(total_rides = n()) 

# Throwing out infrequent trips
trips_sum_filt <- trips_sum %>%
  filter(total_rides > 9)

# Euclidean distance function, small area so we ignore curvature of Earth
# https://www.usgs.gov/faqs/how-much-distance-does-a-degree-minute-and-second-cover-your-maps#:~:text=One%2Ddegree%20of%20longitude%20equals,one%20second%20equals%2080%20feet.
euclidean <- function(long1, lat1, long2, lat2) {
  # Convert coordinates to feet
  lat1_ft <- lat1 * 364000 # 364000 feet is in a degree roughly for latitude
  lat2_ft <- lat2 * 364000
  long1_ft <- long1 * 316000 # longitude changes based on latitude, at Austin, TX, a 
  long2_ft <- long2 * 316000 # degree of longitude is about 316000 feet
  
  # Return Euclidean distance: https://www.cuemath.com/euclidean-distance-formula/
  sqrt((long2_ft - long1_ft)^2 + (lat2_ft - lat1_ft)^2)
}

start_med <- as.numeric(nrow(trips_sum_filt))
end_med <- as.numeric(nrow(trips_sum_filt))

# Calculate distance from each bus stop for start and end point of rideshare rides
for (i in 1:nrow(trips_sum_filt)) {
  # For each start and end location, calculate distance from every single bus stop in 
  # the bus stop dataset and then find the nearest distances and find the median of
  # those or something, I'm not sure the best way to do it but this calculates the distance
  # using a euclidean function
  start_distance <- euclidean(long1 = trips_sum_filt$start_location_long[i],
                              lat1 = trips_sum_filt$start_location_lat[i], 
                              long2 = bus_stops$LONGITUDE, 
                              lat2 = bus_stops$LATITUDE)
  end_distance <- euclidean(long1 = trips_sum_filt$end_location_long[i],
                            lat1 = trips_sum_filt$end_location_lat[i], 
                            long2 = bus_stops$LONGITUDE, 
                            lat2 = bus_stops$LATITUDE)
  
  # Get median of x nearest distances, we can play around with this, not sure whats good
  start_med[i] <- median(sort(start_distance)[1])#:3])
  end_med[i] <- median(sort(end_distance)[1])#:3])
}

# Add median distance from x nearest bus stops to data frame to match a distance to  
# nearest bus stop from each rideshare pick-up and drop-off coordinate
trips_sum_filt$start_dist_from_bus <- start_med
trips_sum_filt$end_dist_from_bus <- end_med

# Terrible model, just testing it out 
# The interesting thing will be if we can account for some variance in Justin's model
# by including a distance from nearest bus stop distance
model <- lm(total_rides ~ start_dist_from_bus, data = trips_sum_filt)
summary(model)
plot(model)




