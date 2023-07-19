# To be run immediately following Justin's 'Rideshare vs public transportation' script

library(dplyr)

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

# All Austin bus stop locations with coordinates to calculate average of 3 nearest bus stops to 
# each rideshare on
bus_stops <- read.csv('austin_stops.csv') 

start_mean <- as.numeric(nrow(merged_data_dow_hour))

for (i in 1:nrow(merged_data_dow_hour)) {
  # For each start location, calculate distance from every single bus stop in 
  # the bus stop dataset and then find the nearest distances and find the mean of
  # those, I'm not sure the best way to do it but this calculates the distance
  # using a euclidean function
  start_distance <- euclidean(long1 = merged_data_dow_hour$start_location_long[i],
                              lat1 = merged_data_dow_hour$start_location_lat[i], 
                              long2 = bus_stops$LONGITUDE, 
                              lat2 = bus_stops$LATITUDE)
  
  # Get mean of x nearest distances, we can play around with this
  start_mean[i] <- mean(sort(start_distance)[1:3])#:3])
}

# Add mean distance from x nearest bus stops to data frame to match a distance to  
# nearest bus stop from each rideshare pick-up oordinate
merged_data_dow_hour$start_dist_from_bus <- start_mean

merged_data_dow_hour <- merged_data_dow_hour %>%
  mutate(
    start_lat_bin = case_when(
      start_location_lat >= 30 & start_location_lat < 30.12 ~ '1',
      start_location_lat >= 30.12 & start_location_lat < 30.24 ~ '2',
      start_location_lat >= 30.24 & start_location_lat < 30.36 ~ '3',
      start_location_lat >= 30.36 & start_location_lat < 30.48 ~ '4',
      start_location_lat >= 30.48 & start_location_lat <= 30.6 ~ '5'
    ),
    start_long_bin = case_when(
      start_location_long >= -97.8 & start_location_long < -97.74 ~ 'A',
      start_location_long >= -97.74 & start_location_long < -97.68 ~ 'B',
      start_location_long >= -97.68 & start_location_long < -97.62 ~ 'C',
      start_location_long >= -97.62 & start_location_long < -97.56 ~ 'D',
      start_location_long >= -97.56 & start_location_long <= -97.5 ~ 'E'
    ),
    start_grid_cell = interaction(start_lat_bin, start_long_bin, sep = '-')
  )


linreg_dow_hour <- lm(passgrs ~ rides_on + weekday + workhours + start_dist_from_bus,
                      merged_data_dow_hour)
summary(linreg_dow_hour)

write.csv(merged_data_dow_hour, 'master_data_file.csv')